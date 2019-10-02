//
//  CFMessagingService.swift
//  CustomFit
//
//  Created by Bharath R on 28/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit
import FirebaseMessaging

class CFMessagingService: NSObject {
    
    static let shared = CFMessagingService()
    
    private override init() {
        
    }
    
}

extension CFMessagingService: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        if remoteMessage.appData.count > 0 && (CustomFit.instance?.isCFMessage(message: remoteMessage.appData as? [String : String]))! {
            CustomFit.instance?.handleCFMessage(app: UIApplication.shared, message: remoteMessage.appData as! [String : String])
        }
    }
    
}
