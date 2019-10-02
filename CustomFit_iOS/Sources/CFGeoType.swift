//
//  CFGeoType.swift
//  CustomFit
//
//  Created by Rajtharan G on 15/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

public struct CFGeoType: Codable {
    
    private var lat: Float?
    private var lon: Float?
    
    public init(lat: Float, lon: Float) {
        self.lat = lat
        self.lon = lon
    }
    
    public func getLat() -> Float? {
        return lat
    }
    
    public mutating func setLat(lat: Float) {
        self.lat = lat
    }
    
    public func getLon() -> Float? {
        return lon
    }
    
    public mutating func setLon(lon: Float) {
        self.lon = lon
    }

}
