//
//  CFRegisterEvents.swift
//  CustomFit
//
//  Created by Rajtharan G on 27/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

struct CFRegisterEvents: Codable {
    
    private var events: Array<CFEvent>?
    private var user: CFUser?
    
    enum CodingKeys: String, CodingKey {
        case events
        case user
    }
    
    init(user: CFUser?, events: Array<CFEvent>?) {
        self.user = user
        self.events = events
    }
    
}
