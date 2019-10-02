//
//  CFConfigRequestSummary.swift
//  CustomFit
//
//  Created by Rajtharan G on 22/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

public struct CFConfigRequestSummary: Codable {
    
    private var configId: String?
    private var version: Int?
    private var requestedTime: String?
    private var variationName: String?
    private var userId: String?
    private var cfUserId: String?
    private var eventType: CFEventType?
    private var experienceId: String?
    private var behaviour: String?
    
    enum CodingKeys: String, CodingKey {
        case configId = "config_id"
        case version
        case requestedTime = "requested_time"
        case variationName = "variation_name"
        case userId = "user_customer_id"
        case cfUserId = "user_id"
        case eventType = "event_type"
        case experienceId = "experience_id"
        case behaviour = "behaviour"
    }

    public func getConfigId() -> String? {
        return configId
    }
    
    public mutating func setConfigId(configId: String) {
        self.configId = configId
    }
    
    public func getVersion() -> Int? {
        return version
    }
    
    public mutating func setVersion(version: Int) {
        self.version = version
    }
    
    public func getRequestedTime() -> String? {
        return requestedTime
    }
    
    public mutating func setRequestedTime(requestedTime: String) {
        self.requestedTime = requestedTime
    }
    
    public func getVariationName() -> String? {
        return variationName
    }
    
    public mutating func setVariationName(variationName: String) {
        self.variationName = variationName
    }
    
    public func getUserId() -> String? {
        return userId
    }
    
    public mutating func setUserId(userId: String) {
        self.userId = userId
    }
    
    public func getEventType() -> CFEventType? {
        return eventType
    }
    
    public mutating func setEventType(eventType: CFEventType) {
        self.eventType = eventType
    }
    
    public func getExperienceId() -> String? {
        return experienceId
    }
    
    public mutating func setExperienceId(experienceId: String) {
        self.experienceId = experienceId
    }
    
    public func getBehaviour() -> String? {
        return behaviour
    }
    
    public mutating func setBehaviour(behaviour: String) {
        self.behaviour = behaviour
    }
    
    public func getCfUserId() -> String? {
        return cfUserId
    }
    
    public mutating func setCfUserId(cfUserId: String) {
        self.cfUserId = cfUserId
    }
    
    public init(config: CFConfig) {
        self.configId = config.getConfigId()
        self.eventType = CFEventType.configSummary
        self.requestedTime = CFUtil.getSupportedDateFormat().string(from: Date())
        self.userId =  CFSharedPreferences.shared.getUser()?.getIdAsString()
        self.cfUserId = CFSharedPreferences.shared.getUser()?._getCfUserId()
        self.version = config.getVersion()
        self.variationName = config.getVariationName()
        if(config.experienceBehaviourResponse != nil) {
            self.behaviour = config.experienceBehaviourResponse?.behaviour
            self.experienceId = config.experienceBehaviourResponse?.experienceId
        }
    }
    
}
