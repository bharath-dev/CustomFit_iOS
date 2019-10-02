//
//  CFLifeCycleDetector.swift
//  CustomFit
//
//  Created by Bharath R on 28/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

class CFLifeCycleDetector {
    
    static let shared = CFLifeCycleDetector()
    
    private init() {
        addObservers()
    }
    
    deinit {
        removeObservers()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func reset() {
        removeObservers()
    }
    
    @objc public func didEnterForeground() {
        CustomFit.instance?.handleAppForeground()
    }
    
    
    @objc public func didEnterBackground() {
        CustomFit.instance?.handleAppBackground()
    }
    
}
