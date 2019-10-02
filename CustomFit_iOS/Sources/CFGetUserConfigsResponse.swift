//
//  CFGetUserConfigsResponse.swift
//  CustomFit
//
//  Created by Rajtharan G on 20/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

public struct CFGetUserConfigsResponse: Codable {
    
    private var cfUserId: String?
    private var id: String?
    private var configs: Dictionary<String, CFConfig>?
    
    enum CodingKeys: String, CodingKey {
        case cfUserId = "user_id"
        case id = "user_customer_id"
        case configs
    }
    //
    public func getCfUserId() -> String? {
        return self.cfUserId
    }
    
    public mutating func setCfUserId(cfUserId: String) {
        self.cfUserId = cfUserId
    }
    
    public func getId() -> String? {
        return self.id
    }
    
    public mutating func setId(id: String?) {
        self.id = id
    }
    
    public func getConfigs() -> Dictionary<String, CFConfig>? {
        return self.configs
    }
    
    public mutating func setConfigs(configs: Dictionary<String, CFConfig>?) {
        self.configs = configs
    }

}
