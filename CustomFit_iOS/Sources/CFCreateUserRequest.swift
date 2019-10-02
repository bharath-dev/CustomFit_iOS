//
//  CFCreateUserRequest.swift
//  CustomFit
//
//  Created by Bharath R on 24/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

class CFCreateUserRequest: NSObject {
    
    private var user: CFUser?
    
    public init(user: CFUser) {
        super.init()
        self.user = user
    }
    
    public func getUser() -> CFUser? {
        return user
    }
    
    public func setUser(user: CFUser) {
        self.user = user
    }
}
