//
//  CFVariationDataType.swift
//  CustomFit
//
//  Created by Rajtharan G on 14/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

public enum CFVariationDataType: String, Codable {
    case string = "STRING", number = "NUMBER", json = "JSON", boolean = "BOOLEAN", list = "LIST", image = "IMAGE", lambda = "LAMBDA", color = "COLOR", localization = "LOCALIZATION", richtext = "RICHTEXT"
}
