//
//  CFconfig.swift
//  CustomFit
//
//  Created by Rajtharan G on 21/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

public struct CFConfig: Codable {
    
    private var configId: String?
    private var userId: String?
    private var customerId: String?
    private var variation: JSON?
    private var version: Int?
    private var variationName: String?
    private var variationDataType: CFVariationDataType?
    var experienceBehaviourResponse: CFExperienceBehaviourResponse?
    
    enum CodingKeys: String, CodingKey {
        case configId = "config_id"
        case userId = "user_id"
        case customerId = "config_customer_id"
        case variation
        case version
        case variationName = "variation_name"
        case variationDataType = "variation_data_type"
        case experienceBehaviourResponse = "experience_behaviour_response"
    }

    public func getVariationName() -> String? {
        return variationName
    }
    
    public mutating func setVariationName(variationName: String) {
        self.variationName = variationName
    }
    
    public func getVersion() -> Int? {
        return version
    }
    
    public mutating func setVersion(version: Int) {
        self.version = version
    }
    
    public func getConfigId() -> String? {
        return configId
    }
    
    public mutating func setConfigId(configId: String) {
        self.configId = configId
    }
    
    public func getCustomerId() -> String? {
        return customerId
    }
    
    public mutating func setCustomerId(customerId: String) {
        self.customerId = customerId
    }
    
    public func getVariation() -> JSON? {
        return variation
    }
    
    public mutating func setVariation(variation: JSON) {
        self.variation = variation
    }
    
    public func getUserId() -> String? {
        return userId
    }
    
    public mutating func setUserId(userId: String) {
        self.userId = userId
    }
    
    public func getVariationDataType() -> CFVariationDataType? {
        return variationDataType
    }
    
    public mutating func setVariationDataType(variationDataType: CFVariationDataType) {
        self.variationDataType = variationDataType
    }

}
