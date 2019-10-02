//
//  CFUser.swift
//  CustomFit
//
//  Created by Rajtharan G on 14/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

fileprivate let DEVICE: String = "device"
fileprivate let OS: String = "os"
fileprivate let IP: String = "ip"
fileprivate let EMAIL: String = "email"
fileprivate let PHONE_NUMBER: String = "phone_number"
fileprivate let FIRST_NAME: String = "first_name"
fileprivate let LAST_NAME : String = "last_name"
fileprivate let COUNTRY: String = "country"
fileprivate let COUNTRY_CODE: String = "country_code"
fileprivate let TIME_ZONE: String = "time_zone"
fileprivate let ANONYMOUS: String = "anonymous"
fileprivate let GENDER: String = "gender"
fileprivate let DOB: String = "dob"
fileprivate let DEFAULT_LOCATION: String = "default_location"

public struct CFUser: Codable {
    
    fileprivate var id: String?
    fileprivate var anonymous: Bool?
    fileprivate var ip: String?
    fileprivate var email: String?
    fileprivate var phoneNumber: String?
    fileprivate var country: String?
    fileprivate var countryCode: String?
    fileprivate var defaultLocation: CFGeoType?
    fileprivate var gender: CFGender?
    fileprivate var dob: Date?
    fileprivate var firstName: String?
    fileprivate var lastName: String?
    fileprivate var timeZone: String?
    fileprivate var tags: [String: String]?
    fileprivate var customProperties: [String: String]?
    fileprivate var privatePropertyNames: PrivatePropertyNames?
    fileprivate var deviceId: String?
    fileprivate var cfUserId: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "user_customer_id"
        case anonymous
        case ip
        case email
        case phoneNumber = "phone_number"
        case countryCode = "country_code"
        case defaultLocation = "default_location"
        case gender
        case dob
        case firstName = "first_name"
        case lastName = "last_name"
        case country
        case timeZone = "time_zone"
        case tags
        case customProperties = "properties"
        case privatePropertyNames = "private_fields"
        case deviceId
        case cfUserId = "user_id"
    }
    
    public init(builder: UserBuilder?) {
        if let id = builder?.id as? String, !id.isEmpty {
            self.id = id
            self.anonymous = builder?.anonymous
        } else {
            print("CustomFit.ai","User was created with null/empty ID. Using device-unique anonymous user id: " + CustomFit.getUniqueUserInstanceId())
            self.id = CustomFit.getUniqueUserInstanceId()
            self.anonymous = true
        }
        
        self.ip = builder?.ip
        self.country = builder?.country
        self.firstName = builder?.firstName
        self.lastName = builder?.lastName
        self.email = builder?.email
        self.phoneNumber = builder?.phoneNumber
        self.timeZone = builder?.timeZone as? String
        self.customProperties = builder?.customProperties as? [String : String]
        self.privatePropertyNames = builder?.privatePropertyNames
        self.countryCode = builder?.countryCode
        self.gender = builder?.gender
        self.defaultLocation = builder?.defaultLocation
        if let builderTags = builder?.tags {
            for tag in builderTags {
                if var tags = self.tags {
                    tags[tag] = ""
                } else {
                    self.tags = [:]
                    self.tags?[tag] = ""
                }
            }
        }
        self.dob = builder?.dob
    }
    
    public mutating func clear() {
        self.id = nil
        self.anonymous = nil
        self.ip = nil
        self.country = nil
        self.firstName = nil
        self.lastName = nil
        self.email = nil
        self.phoneNumber = nil
        self.timeZone = nil
        self.customProperties = nil
        self.privatePropertyNames = nil
        self.countryCode = nil
        self.gender = nil
        self.defaultLocation = nil
        self.tags = nil
        self.dob = nil
    }
    
    func getId() -> Any? {
        return self.id
    }
    //
    func getIdAsString() -> String {
        if  let id = id {
            return "\(id)"
        } else {
            return ""
        }
    }
    
    public func  _getDeviceId() -> String? {
        return self.deviceId
    }
    
    public mutating func _setDeviceId(deviceId: String) {
        self.deviceId = deviceId
    }
    
    public func _getCfUserId() -> String {
        return self.cfUserId ?? ""
    }
    
    public mutating func _setCfUserId(cfUserId: String) {
        self.cfUserId = cfUserId
    }
    
    func getPrivatePropertyNames() -> PrivatePropertyNames? {
        return self.privatePropertyNames
    }
    
    func getPrivateTags() -> [String]? {
        return self.privatePropertyNames?.tags
    }
    
    public func getFirstName() -> String? {
        return self.firstName
    }
    
    public func getLastName() -> String? {
        return self.lastName
    }
    
    public func getCountry() -> String? {
        return self.country
    }
    
    public func getTimeZone() -> Any? {
        return self.timeZone
    }
    
    public func getTags() -> [String: String]? {
        return self.tags
    }
    
    public func getDob() -> Date? {
        return self.dob
    }
    
    public func getCustomProperties() -> [String: Any]? {
        return self.customProperties
    }
    
    public func getIp() -> String? {
        return self.ip
    }
    
    public func getEmail() -> String? {
        return self.email
    }
    
    public func getPhoneNumber() -> String? {
        return self.phoneNumber
    }
    
    public func getDefaultLocation() -> CFGeoType? {
        return self.defaultLocation
    }
    
    public func isAnonymous() -> Bool {
        if let anonymous = self.anonymous {
            return anonymous
        } else {
            return false
        }
    }
}

struct PrivatePropertyNames: Codable {
    
    public var fields: [String]?
    public var properties: [String]?
    public var tags: [String]?
    
    enum CodingKeys: String, CodingKey {
        case fields = "user_fields"
        case properties = "properties"
        case tags = "tags"
    }
    
    public init() {
        fields = Array()
        properties = Array()
        tags = Array()
    }
    
}

public class UserBuilder: NSObject {
    fileprivate var id: Any?
    fileprivate var anonymous: Bool?
    fileprivate var ip: String?
    fileprivate var firstName: String?
    fileprivate var lastName: String?
    fileprivate var email: String?
    fileprivate var timeZone: Any?
    fileprivate var gender: CFGender?
    fileprivate var phoneNumber: String?
    fileprivate var dob: Date?
    fileprivate var countryCode: String?
    fileprivate var defaultLocation: CFGeoType?
    fileprivate var country: String?
    fileprivate var customProperties: [String: Any]?
    fileprivate var privatePropertyNames: PrivatePropertyNames?
    fileprivate var tags: [String]?
    
    public init(id: String) {
        self.id = id
        self.customProperties = Dictionary()
        self.customProperties?[OS] = UIDevice.current.systemVersion
        self.customProperties?[DEVICE] = "\(UIDevice.current.name) \(UIDevice.current.model)"
        self.privatePropertyNames = PrivatePropertyNames()
        self.tags = Array()
    }
    
    public init(user: CFUser) {
        if let _ = user.getId() {
            self.id = user.getIdAsString()
        } else {
            self.id = nil
        }
        self.ip = user.getIp()
        self.firstName = user.getFirstName()
        self.lastName = user.getLastName()
        self.phoneNumber = user.getPhoneNumber()
        self.timeZone = user.getTimeZone()
        self.email = user.getEmail()
        self.country = user.getCountry()
        self.customProperties = user.getCustomProperties()
        self.tags = Array(user.getTags()?.keys ?? [:].keys)
        self.privatePropertyNames = user.getPrivatePropertyNames()
        self.dob = user.getDob()
        self.defaultLocation = user.getDefaultLocation()
    }
    
    public func id(s: String) -> UserBuilder {
        self.id = s
        return self
    }
    
    /**
     * Sets the flag for making user as anonymous.
     * Default value is false.
     * The anonymous user does not get created on CustomFit.ai
     */
    public func anonymous(s: Bool) -> UserBuilder {
        self.anonymous = s
        return self
    }
    
    /**
     * Sets the IP address of user.
     * @param ip Ip address of user
     * @return the builder
     */
    public func ip(ip: String) -> UserBuilder {
        self.ip = ip
        return self
    }
    
    /**
     * Sets the IP address of user.
     * But values are not stored in CustomFit.ai
     * @param ip - Ip address of user
     * @return the builder
     */
    public func privateIp(ip: String) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(IP)
        return self.ip(ip: ip)
    }
    
    /**
     * Sets the country of user.
     * @param country Country of user
     * @return the builder
     */
    public func country(country: String) -> UserBuilder {
        self.country = country
        return self
    }
    
    /**
     * Sets the country of user.
     * But values are not stored in CustomFit.ai
     * @param country Country of user.
     * @return the builder
     */
    public func privateCountry(country: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(COUNTRY)
        return self.country(country: country)
    }
    
    /**
     * Sets the default location of user.
     * @param defaultLocation Default location of user.
     *                        i.e., latitude and longitude
     * @return the builder
     */
    public func defaultLocation(defaultLocation: CFGeoType) -> UserBuilder {
        self.defaultLocation = defaultLocation
        return self
    }
    
    /**
     * Sets the default location of user.
     * But values are not stored in CustomFit.ai
     * @param defaultLocation Default location of user.
     *                        i.e., latitude and longitude
     * @return the builder
     */
    public func privateDefaultLocation(defaultLocation: CFGeoType) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(DEFAULT_LOCATION)
        return self.defaultLocation(defaultLocation: defaultLocation)
    }
    
    /**
     * Sets the country code of user.
     * @param countryCode Country code of user
     * @return the builder
     */
    public func countryCode(countryCode: String) -> UserBuilder {
        self.countryCode = countryCode
        return self
    }
    
    /**
     * Sets the country code of user.
     * But values are not stored in CustomFit.ai
     * @param countryCode Country code of user
     * @return
     */
    public func privateCountryCode(countryCode: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(COUNTRY_CODE)
        return self.countryCode(countryCode: countryCode)
    }
    
    /**
     * Sets the timezone of user.
     * @param timeZone Timezone of user
     * @return the builder
     */
    public func timeZone(timeZone: String) -> UserBuilder {
        self.timeZone = timeZone
        return self
    }
    
    /**
     * Sets the timezone of user.
     * But values are not stored in CustomFit.ai
     * @param timeZone Timezone of user.
     * @return the builder
     */
    public func privateTimeZone(timeZone: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(TIME_ZONE)
        return self.timeZone(timeZone: timeZone)
    }
    
    /**
     * Sets the gender of user.
     * @param gender - Gender of user
     * @return the builder
     *
     */
    public func gender(gender: String?) -> UserBuilder {
        guard let gender = gender else {
            return self
        }
        if gender.elementsEqual("MALE") {
            self.gender = CFGender.male
        } else if gender.elementsEqual("FEMALE") {
            self.gender = CFGender.female
        } else {
            self.gender = CFGender.other
        }
        return self
    }
    
    /**
     * Sets the gender of user.
     * But values are not stored in CustomFit.ai
     * @param gender Gender of user
     * @return the builder
     */
    public func privateGender(gender: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(GENDER)
        return self.gender(gender: gender)
    }
    
    /**
     * Sets the phone number of user.
     * @param phoneNumber - Phone number of user
     * @return the builder
     *
     */
    public func phoneNumber(phoneNumber: String) -> UserBuilder {
        self.phoneNumber = phoneNumber
        return self
    }
    
    
    /**
     * Sets the phone number of user.
     * But values are not stored in CustomFit.ai
     * @param phoneNumber Phone number of user
     * @return the builder
     */
    public func privatePhoneNumber(phoneNumber: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(PHONE_NUMBER)
        return self.phoneNumber(phoneNumber: phoneNumber)
    }
    
    /**
     * Sets the tags of user.
     * @param s List of tags related to user
     * @return the builder
     *
     */
    public func tags(s: [String]) -> UserBuilder {
        self.tags = s
        return self
    }
    
    /**
     * Sets the tags of user.
     * But values are not stored in CustomFit.ai
     * @param s List of tags related to user
     * @return the builder
     *
     */
    public func privateTags(s: [String]) -> UserBuilder {
        self.privatePropertyNames?.tags = s
        return self
    }
    
    /**
     * Sets the first name of user.
     * @param firstName First name of user
     * @return the builder
     */
    public func firstName(firstName: String) -> UserBuilder {
        self.firstName = firstName
        return self
    }
    
    /**
     * Sets the first name of user.
     * But values are not stored in CustomFit.ai
     * @param firstName First name of user
     * @return the builder
     */
    public func privateFirstName(firstName: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(FIRST_NAME)
        return self.firstName(firstName: firstName)
    }
    
    /**
     * Sets the last name of user.
     * @param lastName Last name of user
     * @return the builder
     */
    public func lastName(lastName: String) -> UserBuilder {
        self.lastName = lastName
        return self
    }
    
    /**
     * Sets the last name of user.
     * But values are not stored in CustomFit.ai
     * @param lastName Last name of user
     * @return the builder
     */
    public func privateLastName(lastName: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(LAST_NAME)
        return self.lastName(lastName: lastName)
    }
    
    /**
     * Sets the date of birth of user.
     * @param dob Date of birth of user
     * @return the builder
     */
    public func dob(dob: Date) -> UserBuilder {
        self.dob = dob
        return self
    }
    
    /**
     * Sets the date of birth of user.
     * But values are not stored in CustomFit.ai
     * @param dob Date of birth of user
     * @return the builder
     */
    public func privateDoB(dob: Date) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(DOB)
        return self.dob(dob: dob)
    }
    
    /**
     * Sets the email of user.
     * @param email Email of user
     * @return the builder
     */
    public func email(email: String) -> UserBuilder {
        self.email = email
        return self
    }
    
    /**
     * Sets the email of user.
     * But values are not stored in CustomFit.ai
     * @param email Email of user
     * @return the builder
     */
    public func privateEmail(email: String) -> UserBuilder {
        self.privatePropertyNames?.fields?.append(EMAIL)
        return self.email(email: email)
    }
    
    /**
     * If the custom string property is not there then it gets created at CustomFit.ai
     * Sets the custom string property of user.
     * @param key Key for custom string property
     * @param value Value for custom string property
     * @return the builder
     */
    public func customProperty(key: String, value: String) -> UserBuilder {
        return customProperty(map: customProperties, k: key, v: value)
    }
    
    /**
     * If the custom string property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom string property
     * @param value Value for custom string property
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: String) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return self.customProperty(key: key, value: value)
    }
    
    /**
     * If the custom date property is not there then it gets created at CustomFit.ai
     * Sets the custom date property of user.
     * @param key Key for custom date property
     * @param value Value for custom date property
     * @return the builder
     */
    public func customProperty(key: String, value: Date) -> UserBuilder {
        let dateString = CFUtil.getSupportedDateFormat().string(from: value)
        return customProperty(map: customProperties, k: key, v: CFUtil.getSupportedDateFormat().date(from: dateString))
    }
    
    /**
     * If the custom date property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom date property
     * @param value Value for custom date property
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: Date) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return self.customProperty(key: key, value: value)
    }
    
    /**
     * If the custom geo point property is not there then it gets created at CustomFit.ai
     * Sets the custom geo point property of user.
     * @param key Key for custom geo point property
     * @param value Value for custom geo pointproperty
     * @return the builder
     */
    public func customProperty(key: String, value: CFGeoType) -> UserBuilder {
        return customProperty(map: customProperties, k: key, v: value)
    }
    
    /**
     * If the custom geo point property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom geo point property
     * @param value Value for custom geo pointproperty
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: CFGeoType) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return customProperty(key: key, value: value)
    }
    
    private func customProperty<T>(map: [String: T]?, k: String?, v: T?) -> UserBuilder {
        if let k = k, let v = v { // hack for integer like Age, sinc Any is not codable
            if v is Int64 {
                customProperties?[k] = "\(v)"
            } else {
                customProperties?[k] = v
            }
        }
        return self
    }
    
    /**
     * If the number custom property is not there then it gets created at CustomFit.ai
     * Sets the number custom property of user.
     * @param key Key for number custom property
     * @param value Value for number custom property
     * @return the builder
     */
    
    public func customProperty(key: String, value: Int64) -> UserBuilder {
        return self.customProperty(map: customProperties, k: key, v: value)
    }
    
    /**
     * If the number custom property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for number custom property
     * @param value Value for number custom property
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: Int64) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return customProperty(key: key, value: value)
    }
    
    /**
     * If the custom boolean property is not there then it gets created at CustomFit.ai
     * Sets the custom boolean property of user.
     * @param key Key for custom boolean property
     * @param value Value for custom boolean property
     * @return the builder
     */
    public func customProperty(key: String, value: Bool) -> UserBuilder {
        return customProperty(map: customProperties, k: key, v: value)
    }
    
    
    /**
     * If the custom boolean property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom boolean property
     * @param value Value for custom boolean property
     * @return the builder
     */
    public func privateCustomProperty(key: String, value: Bool) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return self.customProperty(key: key, value: value)
    }
    
    /**
     * If the custom list string property is not there then it gets created at CustomFit.ai
     * Sets the custom list string property of user.
     * @param key Key for custom list string property
     * @param values List of values for custom list string property
     * @return the builder
     */
    public func customPropertyString(key: String, values: [String]) -> UserBuilder {
        return customProperty(map: customProperties, k: key, v: values)
    }
    
    /**
     * If the custom list string property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom list string property
     * @param values List of values for custom list string property
     * @return the builder
     */
    public func privateCustomPropertyString(key: String, values: [String]) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return customPropertyString(key: key, values: values)
    }
    
    private func customProperty(map: [String: Any], k: String, vs: [String?]) -> UserBuilder {
        var array = Array<String>()
        for v in vs {
            if let v = v {
                array.append(v)
            }
        }
        customProperties?[k] = array
        return self
    }
    
    /**
     * If the custom list number property is not there then it gets created at CustomFit.ai
     * Sets the custom list number property of user.
     * @param key Key for custom list number property
     * @param values Value for custom list number property
     * @return the builder
     */
    public func customPropertyNumber(key: String, values: [Int64]) -> UserBuilder {
        return self.customPropertyNumber(map: customProperties, k: key, vs: values)
    }
    
    /**
     * If the custom list number property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom list number property
     * @param values Value for custom list number property
     * @return the builder
     */
    public func privateCustomPropertyNumber(key: String, values: [Int64]) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return self.customPropertyNumber(key: key, values: values)
    }
    
    private func customPropertyNumber(map: [String: Any?]?, k: String, vs: [Int64?]) -> UserBuilder {
        var array = Array<Int64>()
        for v in vs {
            if let v = v {
                array.append(v)
            }
        }
        customProperties?[k] = array
        return self
    }
    
    /**
     * If the custom list date property is not there then it gets created at CustomFit.ai
     * Sets the custom list date property of user.
     * @param key Key for custom list date property
     * @param values Value for custom list date property
     * @return the builder
     */
    public func customPropertyDate(key: String, values: [Date]) -> UserBuilder {
        return customPropertyDate(map: customProperties, k: key, vs: values)
    }
    
    
    /**
     * If the custom list date property is not there then it gets created at CustomFit.ai
     * But values are not stored in CustomFit.ai
     * @param key Key for custom list date property
     * @param values Value for custom list date property
     * @return the builder
     */
    public func privateCustomPropertyDate(key: String, values: [Date]) -> UserBuilder {
        self.privatePropertyNames?.properties?.append(key)
        return customPropertyDate(key: key, values: values)
    }
    
    private func customPropertyDate(map: [String: Any?]?, k: String, vs: [Date?]) -> UserBuilder {
        var array = Array<Date>()
        for v in vs {
            if let v = v {
                let dateString = CFUtil.getSupportedDateFormat().string(from: v)
                array.append(CFUtil.getSupportedDateFormat().date(from: dateString)!)
            }
        }
        customProperties?[k] = array
        return self
    }
    
    private func customPropertyGeoPoint(map: [String: Any?], k: String, vs: [CFGeoType?]) -> UserBuilder {
        var array = Array<CFGeoType>()
        for v in vs {
            if let v = v {
                array.append(v)
            }
        }
        customProperties?[k] = array
        return self
    }
    
    public func build() -> CFUser {
        return CFUser(builder: self)
    }
    
}
