//
//  CFConfiguredEvent.swift
//  CustomFit
//
//  Created by Rajtharan G on 20/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

struct CFConfiguredEvent: Codable {
    
    private var eventId: String?
    var eventCustomerId: String?
    private var description: String?
    private var name: String?
    private var version: Int?
    private var created: String?
    var experiences: [CFExperience]?
    var vendors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case eventCustomerId = "event_customer_id"
        case description
        case name
        case version
        case created = "created_at"
        case experiences
        case vendors
    }
    
}
