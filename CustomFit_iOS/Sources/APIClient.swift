//
//  APIClient.swift
//  CustomFit
//
//  Created by Rajtharan G on 20/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Alamofire

class APIClient {
    
    static let shared = APIClient()
    private let TAG: String = "CusfomFit.ai"
    private let BASE_URL: String = "https://api.customfit.ai"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private var sessionManager: SessionManager!
    let headers: HTTPHeaders = ["Authorization": "Bearer \(CFSharedPreferences.shared.getClientKey()!)"]
    typealias HTTPHeaders = [String: String]
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func getSdkConfigs(completion: @escaping ([String: String]?, Error?) -> Void) {
        addRetryMechanism()
        if let url = URL(string: "\(BASE_URL)/v1/sdk/configs") {
            sessionManager.request(URLRequest(url: url)).validate().responseJSON { response in
                CustomFit.instance?.configFetchState = .idle
                guard let data = response.data else {
                    print(self.TAG, "Error in getConfigs: No data to decode \(response.error?.localizedDescription ?? "")")
                    completion(nil, response.error)
                    return
                }
                guard let sdkConfig = try? self.decoder.decode([String: String].self, from: data) else {
                    print(self.TAG, "Error in getConfigs: No data to decode \(response.error?.localizedDescription ?? "")")
                    completion(nil, response.error)
                    return
                }
                completion(sdkConfig, response.error)
            }
        }
    }
    
    func getConfigs(cfUser: CFUser, completion: @escaping (CFGetUserConfigsResponse?, Error?) -> Void) {
        addRetryMechanism()
        if let url = URL(string: "\(BASE_URL)/v1/users/configs") {
            if let encodedObject = try? encoder.encode(cfUser) {
                do {
                    if let user = try JSONSerialization.jsonObject(with: encodedObject, options: []) as? [String: Any] {
                        let userJson = ["user": user]
                        postRequest(url: url, body: userJson, shouldParse: true) { data, response, error in
                            CustomFit.instance?.configFetchState = .idle
                            guard let data = data else {
                                print(self.TAG, "Error in getConfigs: No data to decode \(error?.localizedDescription ?? "")")
                                completion(nil, error)
                                return
                            }
                            do {
                                let userConfig = try self.decoder.decode(CFGetUserConfigsResponse.self, from: data)
                                completion(userConfig, error)
                            } catch let error {
                                print(self.TAG, "Error in getConfigs: No data to decode \(error.localizedDescription)")
                                completion(nil, error)
                            }
                        }
                    }
                } catch {
                    print(TAG, "Error in getConfigs: No data to decode \(error.localizedDescription)")
                }
            }
        }
    }
    
    func addDevice(cfUserId: String, instanceId: String, anonymous: Bool, completion: @escaping (String? , String?, Error?) -> Void) {
        addRetryMechanism()
        if let url = URL(string: "\(BASE_URL)/v1/users/\(cfUserId)/devices") {
            var jsonArr: Array<Dictionary<String, Any>> = Array()
            var device_customer_id: Dictionary<String, Any> = Dictionary()
            var add_devices: Dictionary<String, Any> = Dictionary()
            device_customer_id["device_customer_id"] = instanceId
            jsonArr.append(device_customer_id)
            add_devices["add_devices"] = jsonArr
            add_devices["anonymous"] = anonymous
            postRequest(url: url, body: add_devices, shouldParse: false) { data, response, error in
                CustomFit.instance?.configFetchState = .idle
                completion(cfUserId, instanceId, error)
            }
        }
    }
    
    func trackEvents(registerEvents: CFRegisterEvents, completion: @escaping (Error?) -> Void) {
        addRetryMechanism()
        if let url = URL(string: "\(BASE_URL)/v1/events/track") {
            if let encodedObject = try? encoder.encode(registerEvents) {
                do {
                    if let events = try JSONSerialization.jsonObject(with: encodedObject, options: []) as? [String: Any] {
                        postRequest(url: url, body: events, shouldParse: false) { data, response, error in
                            CustomFit.instance?.configFetchState = .idle
                            if let error = error {
                                print(self.TAG, "Error in trackEvents: \(error.code) \(error.localizedDescription)")
                                completion(error)
                            } else {
                                completion(nil)
                            }
                        }
                    }
                } catch {
                    print(TAG, "Error in getConfigs: No data to decode \(error.localizedDescription)")
                }
            }
        }
    }
    //
    func pushConfigRequestSummaryEvents(events: Array<CFConfigRequestSummary>, completion: @escaping (Error?) -> Void) {
        addRetryMechanism()
        if let url = URL(string: "\(BASE_URL)/v1/config/request/summary") {
            if let encodedObject = try? encoder.encode(events) {
                do {
                    if let events = try JSONSerialization.jsonObject(with: encodedObject, options: []) as? [Any] {
                        postRequest(url: url, body: events, shouldParse: false) { data, response, error in
                            CustomFit.instance?.configFetchState = .idle
                            if let error = error {
                                print(self.TAG, "Error in pushConfigRequestSummary: \(error.code) \(error.localizedDescription)")
                                completion(error)
                            } else {
                                completion(nil)
                            }
                        }
                    }
                } catch {
                    print(TAG, "Error in getConfigs: No data to decode \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getConfiguredEvents(completion: @escaping ([String: CFConfiguredEvent]?, Error?) -> Void) {
        addRetryMechanism()
        if let url = URL(string: "\(BASE_URL)/v1/events") {
            sessionManager.request(URLRequest(url: url)).validate().responseJSON { response in
                CustomFit.instance?.configFetchState = .idle
                guard let data = response.data else {
                    print(self.TAG, "Error in getConfiguredEvents: No data to decode \(response.error?.localizedDescription ?? "")")
                    completion(nil, response.error)
                    return
                }
                do {
                    var events:[String: CFConfiguredEvent] = [:]
                    let eventListView = try self.decoder.decode(CFEventListView.self, from: data)
                    if let eventList = eventListView.configuredEventList {
                        for event in eventList {
                            events[event.eventCustomerId!] = event
                        }
                        completion(events, response.error)
                    } else {
                        completion(nil, response.error)
                    }
                } catch let error {
                    print(self.TAG, "Error in getConfiguredEvents: No data to decode \(error.localizedDescription)")
                    completion(nil, error)
                }
            }
        }
    }
    
    func postRequest(url:URL, body:Any, shouldParse: Bool, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try! JSONSerialization.data(withJSONObject: body, options: [])
        request.httpBody = jsonData
        if shouldParse {
            sessionManager.request(request).validate().responseJSON { response in
                completionHandler(response.data, response.response, response.error)
            }
        } else {
            sessionManager.request(request).validate().response { response in
                completionHandler(response.data, response.response, response.error)
            }
        }
    }
    
    func addRetryMechanism() {
        sessionManager.retrier = RetryHandler()
        sessionManager.adapter = RetryHandler()
        CustomFit.instance?.configFetchState = .inProgress
    }

}

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
