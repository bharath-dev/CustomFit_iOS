//
//  CFExperience.swift
//  CustomFit
//
//  Created by Bharath R on 24/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

struct CFExperience: Codable {
    
    private var experienceName: String?
    private var experienceId: String?
    
    enum CodingKeys: String, CodingKey {
        case experienceName = "experience_customer_id"
        case experienceId = "experience_id"
    }
    
    init(experienceName: String, experienceId: String) {
        self.experienceName = experienceName
        self.experienceId = experienceId
    }
    
}
