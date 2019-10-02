//
//  swift
//  CustomFit
//
//  Created by Rajtharan G on 14/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit
import FirebaseInstanceID
import UserNotifications
import FirebaseMessaging

public protocol CFConfigChangeObserver {
    func onChanged(key:String)
}

public enum ConfigFetchState {
    case idle, inProgress
}

public class CustomFit: NSObject {
    
    private var application: UIApplication? = nil
    private var deviceInstanceId: String? = ""
    private var configChangeObservers: Dictionary<String, Array<CFConfigChangeObserver>>? = Dictionary()
    public var configFetchState: ConfigFetchState = ConfigFetchState.idle
    private let NOTIFICATION_SENDER: String = "ai"
    private let REFRESH_CONFIG_MSG_TYPE: String = "refresh_configs"
    private let CF_MSG_TYPE: String = "customfit_message_type"
    private let CF_MAX_RESYNC_TIME_STR: String = "max_resync_time"
    private var fetchConfigWorkRequest: DispatchWorkItem? = nil
    private var addDeviceRequest: DispatchWorkItem? = nil
    private var sharedPrefSdkConfig: String!
    public var clientKey: String?
    public var user: CFUser!
    private var periodicWorkRequest: DispatchWorkItem? = nil
    private let WORKER_NAME: String = "CUSTOMFIT_CONFIG_FETCHER"
    private let ADD_DEVICE_WORKER_NAME: String = "CUSTOMFIT_ADD_DEVICE_WORKER"
    private let PERIODIC_EVENT_PROCESSOR_WORKER_NAME: String =  "CUSTOMFIT_PERIODIC_EVENT_PROCESSOR_WORKER_NAME"
    private var device_registered: Bool = false
    public static var instance: CustomFit? = nil
    static var CONFIG_FETCH_WORKER_MAX_RETRIES: Int = 0
    public static var ADD_DEVICE_WORKER_MAX_RETRIES: Int  = 0

    public init(app: UIApplication, key: String, cfUser: CFUser) {
        super.init()
        if CustomFit.instance == nil {
            application = app
            device_registered = false
            clientKey = key
            user = cfUser
            _ = CFSharedPreferences.shared
            configFetchState = ConfigFetchState.idle
            cancelFetchConfigWorkRequest()
            _ = CFSDKConfig()
            scheduleFetchConfigJobIfNeeded()
            CFSummaryExporter.shared.reset()
            _ = CFSummaryExporter()
            _ = CFTracker()
            CFTracker.instance?.reset()
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instange ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")
                    self.registerDevice(instanceId: result.token)
                }
            }
            schedulePeriodicEventProcessorJob()
            _ = CFLifeCycleDetector.shared
            CustomFit.instance = self
        }
    }
    //
    public func reset() {
        if CustomFit.instance != nil {
            configChangeObservers = nil
            cancelFetchConfigWorkRequest()
            cancelPeriodicWorkRequest()
            CFLifeCycleDetector.shared.reset()
            CFTracker.instance?.reset()
            CFSummaryExporter.shared.reset()
            CFSDKConfig.reset()
            CFSharedPreferences.shared.reset()
            fetchConfigWorkRequest = nil
            periodicWorkRequest = nil
            configFetchState = ConfigFetchState.idle
            CustomFit.instance = nil
        }
    }
    //
    private func cancelFetchConfigWorkRequest() {
        if let workRequest = fetchConfigWorkRequest {
            workRequest.cancel()
        }
    }
    //
    private func cancelAddDeviceWorkRequest() {
        if let addDeviceRequest = addDeviceRequest {
            addDeviceRequest.cancel()
        }
    }
    //
    private func cancelPeriodicWorkRequest() {
        if let periodicWorkRequest = periodicWorkRequest {
            periodicWorkRequest.cancel()
        }
    }
    //
    private func scheduleFetchConfigJobIfNeeded() {
        let currentTime = Date()
        let configNextFetchedTime = CFSharedPreferences.shared.getConfigNextFetchDateTime()
        if configFetchState != ConfigFetchState.inProgress && (getConfigs() == nil || configNextFetchedTime != nil || currentTime.seconds(from: configNextFetchedTime!) >= 0) {
            scheduleFetchConfigJob(delay: 0)
        }
    }
    
    public func schedulePeriodicEventProcessorJob() {
        cancelPeriodicWorkRequest()
        CFSummaryExporter.shared.flushEvents()
        scheduleFetchConfigJobIfNeeded()
        CFTracker.instance?.flushEvents()
    }
    //
    public func scheduleFetchConfigJob(delay: Int) {
        if configFetchState != ConfigFetchState.inProgress {
            cancelFetchConfigWorkRequest()
            CustomFit.CONFIG_FETCH_WORKER_MAX_RETRIES = CFSDKConfig.getApiRetryCount()
            fetchConfigWorkRequest = DispatchWorkItem {
            self.fetchConfigs(completion: { (isSuccess) in
                    if isSuccess {
                        // Success
                    }
                })
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + TimeInterval(delay)) {
                self.fetchConfigWorkRequest?.perform()
            }
        }
    }
    //
    private func fetchConfigs(completion: @escaping (Bool) -> Void) {
        APIClient.shared.getConfigs(cfUser: CFSharedPreferences.shared.getUser()!) { (cfGetUserConfigsResponse, error) in
            if let newConfigMap = cfGetUserConfigsResponse?.getConfigs() {
                if let oldConfigMap = CFSharedPreferences.shared.getConfigs() {
                    if (newConfigMap == oldConfigMap) { // Condition for dictionary comparison between old and new
                        CFSharedPreferences.shared.setConfigs(configList: newConfigMap)
                        self.notifyObservers(newConfigs: newConfigMap, oldConfigs: oldConfigMap)
                    } else {
                        let configNextFetchDateTime = Date()
                        CFSharedPreferences.shared.setConfigNextFetchDateTime(date: configNextFetchDateTime.addingTimeInterval(TimeInterval(CFSDKConfig.getConfigRefershDuration())))
                    }
                } else {
                    CFSharedPreferences.shared.setConfigs(configList: newConfigMap)
                    self.notifyObservers(newConfigs: newConfigMap, oldConfigs: nil)
                }
            }
            if (!self.device_registered && self.deviceInstanceId != nil && !(self.deviceInstanceId ?? "").isEmpty) {
                self.registerDevice(instanceId: self.deviceInstanceId)
            }
            var user = self.getUser()
            if !(cfGetUserConfigsResponse?.getCfUserId() == user?._getCfUserId()) {
                user?._setCfUserId(cfUserId: cfGetUserConfigsResponse?.getCfUserId() ?? "")
                CFSharedPreferences.shared.setUserInfo(cfUser: user)
            }
            if error != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    public func registerConfigChange(config: String, cbObj: CFConfigChangeObserver?) {
        if let cbObj = cbObj {
            if var config = configChangeObservers?[config] {
                config.append(cbObj)
            } else {
                configChangeObservers?[config] = [cbObj]
            }
        }
    }
    
    public func unregisterConfigChange(configId: String, cbObj: CFConfigChangeObserver?) {
        if cbObj != nil {
            if (configChangeObservers?[configId]) != nil {
                //Remove cobj here
                //configId.removeAll(where: {$0 == cbObj})
            }
        }
    }
    
    private func getConfigs() -> Dictionary<String, CFConfig>? {
        return CFSharedPreferences.shared.getConfigs()
    }

    public func getConfigs() -> Dictionary<String, CFConfig> {
        return CFSharedPreferences.shared.getConfigs()!
    }
    
    public func registerDevice(app: UIApplication, instanceId: String?) {
        CFSharedPreferences.shared.initFromCache()
        registerDevice(instanceId: instanceId)
    }
    //
    public func registerDevice(instanceId: String?) {
        deviceInstanceId = instanceId
        if(CFSharedPreferences.shared.getUser() == nil || instanceId == nil) {
            /* Wait for init */
            print("ai","CustomFit not yet initialized")
            return
        }
        if let instanceId = instanceId {
            if !instanceId.isEmpty {
                var user = getUser()
                if !(instanceId == user?._getDeviceId()) {
                    user?._setDeviceId(deviceId: instanceId)
                    CFSharedPreferences.shared.setUserInfo(cfUser: user)
                }
                cancelAddDeviceWorkRequest()
                CustomFit.ADD_DEVICE_WORKER_MAX_RETRIES = CFSDKConfig.getApiRetryCount()
                addDeviceRequest = DispatchWorkItem {
                    APIClient.shared.addDevice(cfUserId: (CFSharedPreferences.shared.getUser()?.getIdAsString())!, instanceId: self.deviceInstanceId!, anonymous: (CFSharedPreferences.shared.getUser()?.isAnonymous())!, completion: { (cfUserId, instanceId, error) in
                        if let _ = error {
                            // Retry here
                        } else {
                            self.device_registered = true
                        }
                    })
                }
                addDeviceRequest?.perform()
            }
        }
    }
    
    public func getDeviceInstanceId() -> String? {
        return deviceInstanceId
    }
    
    public func isCFMessage(message: [String: String]?) -> Bool {
        if let message = message, let sender = message["sender"], NOTIFICATION_SENDER == sender {
            return true
        }
        return false
    }
    
    public func handleCFMessage(app: UIApplication, message: [String: String]) {
        CFSharedPreferences.shared.initFromCache()
        if isCFMessage(message: message) && message[CF_MSG_TYPE] != nil && REFRESH_CONFIG_MSG_TYPE == message[CF_MSG_TYPE] {
            var max_time_to_resync = 0, random_delay = 0
            if(message[CF_MAX_RESYNC_TIME_STR] != nil) {
                max_time_to_resync =  Int(message[CF_MAX_RESYNC_TIME_STR] ?? "") ?? 0
            }
            if (max_time_to_resync > 0) {
                random_delay  = Int(arc4random_uniform(UInt32(max_time_to_resync * 1000)))
            }
            if(random_delay > 0) {
                let configNextFetchDateTime = Date().addingTimeInterval(TimeInterval(random_delay))
                CFSharedPreferences.shared.setConfigNextFetchDateTime(date: configNextFetchDateTime)
                scheduleFetchConfigJob(delay: random_delay)
            } else {
                fetchConfigs { (isSuccess) in
                    
                }
            }
        }
    }
    
    public func showPopup(viiewController: UIViewController) {
        // Show alert here
    }
    //
    public func getUser() -> CFUser? {
        return CFSharedPreferences.shared.getUser()
    }
    
    /**
     * Gets the config value of type number
     * @param key Config id of type number
     * @param fallbackValue The value which will be returned when the given config id does not exists or
     *                      when the app is launched for the first time
     *
     */
    public func getNumber(key: String, fallbackValue: Int) -> Int {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.number {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return Int(getConfigs()[key]?.getVariation()?.doubleValue ?? Double(fallbackValue))
    }
    
   
    public func getLong(key: String, fallbackValue: Double) -> Double {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.number {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return getConfigs()[key]?.getVariation()?.doubleValue ?? fallbackValue
    }
    
    
    
    /**
     * Gets the config value of type string
     * @param key Config id of type string
     * @param fallbackValue The value which will be returned when the given config id does not exists or
     *                      when the app is launched for the first time
     *
     */
    public func getString(key: String, fallbackValue: String) -> String {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.string {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return getConfigs()[key]?.getVariation()?.stringValue ?? fallbackValue
    }
    
    /**
     * Gets the config value of type boolean
     * @param key Config id of type boolean
     * @param fallbackValue The value which will be returned when the given config id does not exists or
     *                      when the app is launched for the first time
     *
     */
    public func getBoolean(key: String, fallbackValue: Bool) -> Bool {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.boolean {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return getConfigs()[key]?.getVariation()?.boolValue ?? fallbackValue
    }
    
    /**
     * Gets the config value of type image
     * @param key Config id of type image
     * @param fallbackValue The value which will be returned when the given config id does not exists or
     *                      when the app is launched for the first time
     *
     */
    public func getImage(key: String, fallbackValue: String) -> String {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.image {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return getConfigs()[key]?.getVariation()?.stringValue ?? fallbackValue
    }
    
    /**
     * Gets the config value of type list
     * @param key Config id of type list
     * @param fallbackValue The value which will be returned when the given config id does not exists or
     *                      when the app is launched for the first time
     *
     */
    public func getList(key: String, fallbackValue: Array<String>) -> Array<String> {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.list {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return getConfigs()[key]?.getVariation()?.arrayValue?.compactMap({$0.stringValue}) ?? fallbackValue
    }
    
    /**
     * Gets the config value of type color
     * @param key Config id of type color
     * @param fallbackValue The value which will be returned when the given config id does not exists or
     *                      when the app is launched for the first time
     *
     */
    public func getColor(key: String, fallbackValue: UIColor) -> UIColor {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.color {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return UIColor(hexString: getConfigs()[key]?.getVariation()?.stringValue ?? "")
    }
    
    
    /**
     * Gets the config value of type rich text
     * @param key Config id of type rich text
     * @param fallbackValue The value which will be returned when the given config id does not exists or
     *                      when the app is launched for the first time
     *
     */
    public func getRichText(key: String, fallbackValue: NSAttributedString) -> NSAttributedString {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.richtext {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return getConfigs()[key]?.getVariation()?.stringValue?.htmlToAttributedString ?? fallbackValue
    }
    
    /**
     * Gets the config value of type json
     * @param key Config id of type json
     * @param fallbackValue The value which will be returned when the given config id does not exists or
     *                      when the app is launched for the first time
     *
     */
    public func getJson(key: String, fallbackValue: Dictionary<String, Any>) -> Dictionary<String, Any> {
        if getConfigs() == nil {
            return fallbackValue
        } else if getConfigs()[key] == nil {
            return fallbackValue
        } else if getConfigs()[key]?.getVariationDataType() != CFVariationDataType.json {
            return fallbackValue
        }
        CFSummaryExporter.shared.pushConfigRequestEvent(config: getConfigs()[key])
        return getConfigs()[key]?.getVariation()?.objectValue ?? fallbackValue
    }
    
    public func handleAppForeground() {
        scheduleFetchConfigJobIfNeeded()
        CFTracker.instance?.handleAppForeground()
        CFSummaryExporter.shared.handleAppForeground()
    }
    
    public func handleAppBackground() {
        CFSharedPreferences.shared.initFromCache()
        scheduleFetchConfigJobIfNeeded()
        CFTracker.instance?.handleAppBackground()
        CFSummaryExporter.shared.handleAppBackground()
    }
    
    class public func getUniqueUserInstanceId() -> String {
        return UUID().uuidString
    }
    //
    func notifyObservers(newConfigs: Dictionary<String, CFConfig>?, oldConfigs: Dictionary<String, CFConfig>?) {
        if let configChangeObservers = configChangeObservers {
            for (_, value) in configChangeObservers.enumerated() {
                let observers = value.value
                let configKey = value.key
                if observers.count > 0 {
                    let newConfig = newConfigs?[configKey]
                    let oldConfig = oldConfigs?[configKey]
                    if ((newConfig != nil && oldConfig != nil &&
                        !false) ||
                        (newConfig != nil && oldConfig == nil) || (newConfig == nil && oldConfig != nil)) {
                        for observer in observers {
                            DispatchQueue.main.async {
                                observer.onChanged(key: configKey)
                            }
                        }
                    }
                }
            }
            
        }
    }

}


extension Dictionary where Value: Any {
    
    func isEqual<T: Equatable>(type: T.Type, a: Any, b: Any) -> Bool? {
        guard let a = a as? T, let b = b as? T else { return nil }
        return a == b
    }
    
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}


extension CustomFit {
    //MARK: - Custom methods
    
    func registerForPushNotification(application: UIApplication) {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
}

extension CustomFit: UNUserNotificationCenterDelegate {
    //MARK: - UNUserNotificationCenterDelegate methods
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([])
    }
    
}
