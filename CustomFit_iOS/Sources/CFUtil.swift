//
//  CFUtil.swift
//  CustomFit
//
//  Created by Rajtharan G on 14/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

class CFUtil {
    
    static let LOG_TAG: String = "CustomFit.ai"
    
    static func getSupportedDateFormat() -> DateFormatter {
        let supportedDateFormat = DateFormatter()
        supportedDateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        return supportedDateFormat
    }
    
    static func toString(geoType: CFGeoType) -> String {
        return String(describing: geoType)
    }

}
