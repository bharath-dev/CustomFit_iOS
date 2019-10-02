//
//  CFExperienceBehaviourResponse.swift
//  CustomFit
//
//  Created by Rajtharan G on 23/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

struct CFExperienceBehaviourResponse: Codable {
    
    var experienceId: String?
    var behaviour: String?
    
    enum CodingKeys: String, CodingKey {
        case experienceId = "experience_id"
        case behaviour
    }
    
}
