//
//  CFEvent.swift
//  CustomFit
//
//  Created by Rajtharan G on 22/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

struct CFEvent: Codable {
    
    private var eventProperties: [String: JSON]?
    private var eventId: JSON?
    private var eventTimeStamp: String?

    enum CodingKeys: String, CodingKey {
        case eventProperties = "data"
        case eventId = "event_customer_id"
        case eventTimeStamp = "event_timestamp"
    }
    
    init(eventID: String?, eventProperties: [String: JSON]?) {
        self.eventProperties = eventProperties
        let displayString = CFUtil.getSupportedDateFormat().string(from: Date())
        self.eventTimeStamp = displayString
        self.eventId = eventID == nil ? nil : JSON(stringLiteral: eventID!)
    }
    
    init(builder: Builder?) {
        self.eventTimeStamp = CFUtil.getSupportedDateFormat().string(from: Date())
        
        if let eventID = builder?.eventId {
            self.eventId = JSON(stringLiteral: eventID)
        } else {
            self.eventId = nil
        }
        
        if let eventProperties = builder?.eventProperties {
            self.eventProperties = eventProperties
        } else {
            self.eventProperties = nil
        }
    }
    
    public func getEventProperties() -> [String: JSON]? {
        return eventProperties
    }
    
    public func getEventId() -> JSON? {
        return eventId
    }
    
    public func getEventIdAsString() -> String {
        if let eventID = eventId?.stringValue {
            return eventID
        } else {
            return ""
        }
    }
    
}

public class Builder {
    public var eventId: String?
    public var eventProperties: [String: JSON]?
    
    //
    init(id: String) {
        self.eventId = id
        self.eventProperties = [:]
    }
    
    public func eventId(s: String) -> Builder {
        self.eventId = s
        return self
    }
    
    public func eventProperty(k: String, v: String) -> Builder {
        return eventProperty(map: &eventProperties, k: k, v: JSON(stringLiteral: v))
    }
    
    public func eventProperty(k: String, v: Date) -> Builder {
        return eventProperty(map: &eventProperties, k: k, v: CFUtil.getSupportedDateFormat().string(from: v))
    }
    
    public func eventProperty(k: String, v: CFGeoType) -> Builder {
        return eventProperty(map: &eventProperties, k: k, v: CFUtil.toString(geoType: v))
    }
    
    private func eventProperty<T>(map:inout [String: T]?, k: String?, v: Any?) -> Builder {
        if let k = k, let v = v {
            map?[k] = v as? T
        }
        return self
    }
    
    public func eventProperty(k: String, n: NSNumber) -> Builder {
        return eventProperty(map: &eventProperties, k: k, v: JSON(integerLiteral: n.intValue))
    }
    
    public func eventProperty(k: String, b: Bool) -> Builder {
        return eventProperty(map: &eventProperties, k: k, v: JSON(booleanLiteral: b))
    }
    
    public func eventPropertyString(k: String, vs: [String]) -> Builder {
        return eventProperty(map: &eventProperties, k: k, v: vs)
    }
    
    private func eventPropertyString(map: inout [String: JSON]?, k: String, vs: [String?]) -> Builder {
        var array: [JSON] = []
        
        for v in vs {
            if let v = v {
                array.append(JSON(stringLiteral: v))
            }
        }
        map?[k] = JSON(array: array)
        return self
    }
    
    public func eventPropertyNumber(k: String, vs: [NSNumber]) -> Builder {
        return eventPropertyNumber(map: &eventProperties, k: k, vs: vs)
    }
    
    private func eventPropertyNumber(map:inout [String: JSON]?, k: String, vs: [NSNumber?]) -> Builder {
        var array: [JSON] = []
        
        for v in vs {
            if let v = v {
                array.append(JSON(integerLiteral: v.intValue))
            }
        }
        map?[k] = JSON(array: array)
        return self
    }
    
    public func eventPropertyDate(k: String, vs: [Date]) -> Builder {
        return eventPropertyDate(map: &eventProperties, k: k, vs: vs)
    }
    
    private func eventPropertyDate(map:inout [String: JSON]?, k: String, vs: [Date?]) -> Builder {
        var array: [JSON] = []
        for v in vs {
            if let v = v {
                array.append(JSON(stringLiteral: CFUtil.getSupportedDateFormat().string(from: v)))
            }
        }
        map?[k] = JSON(array: array)
        return self
    }
    
    public func eventPropertyGeoPoint(k: String, vs: [CFGeoType]) -> Builder {
        return eventPropertyGeoPoint(map: &eventProperties, k: k, vs: vs)
    }
    
    private func eventPropertyGeoPoint(map:inout [String: JSON]?, k: String, vs: [CFGeoType?]) -> Builder {
        var array: [JSON] = []
        for v in vs {
            if let v = v {
                array.append(JSON(stringLiteral: CFUtil.toString(geoType: v)))
            }
        }
        map?[k] = JSON(array: array)
        return self
    }
    
    func build() -> CFEvent {
        return CFEvent.init(eventID: eventId, eventProperties: eventProperties)
    }
    
}
