//
//  CFTracker.swift
//  CustomFit
//
//  Created by Bharath R on 28/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

private enum EventDispatchState {
    case idle, inProgress
}

public class CFTracker {
    
    private var events: CFQueue<CFEvent>?
    private var lastPushTime: Date?
    private var EVENT_DISPATCHER_WORKER_NAME: String = "CUSTOMFIT_EVENT_DISPATCHER"
    private var instance: CFTracker?
    private var eventDispatchWorkRequest: DispatchWorkItem? = nil
    private static var eventDispatchState: EventDispatchState = .idle
    public static var EVENT_DISPATCH_WORKER_MAX_RETRIES: Int = 0
    
    public static var instance: CFTracker?
    
    //
    init() {
        if instance == nil {
            events = CFSharedPreferences.shared.getEvent()
            if events == nil {
                events = CFQueue<CFEvent>(elements: [])
            }
        }
        
        lastPushTime = CFSharedPreferences.shared.getLastEventStoredDateTime()
        if lastPushTime == nil {
            lastPushTime = Date()
        }
        
        CFTracker.eventDispatchState = .idle
        cancelEventDispatchWorkRequest()
        flushEvents()
        CFTracker.instance = self
    }
    
    //
    public func reset() {
        if instance != nil {
            forceFlush()
            cancelEventDispatchWorkRequest()
            eventDispatchWorkRequest = nil
            CFTracker.eventDispatchState = .idle
            instance = nil
        }
    }
    
    /**
     *The trackEvent method allows you to track events that occur on your app
     * @param event event_id of the event.
     *              The event_id is used to uniquely identify the event
     *
     */
    func trackEvent(event: CFEvent?) {
        if events == nil {
            return
        }
        
        if let event = event {
            events?.enqueue(event)
            CFSharedPreferences.shared.setEvents(events: events)
            flushEvents()
        }
    }
    
    private func _flushEvents() {
        if events != nil && events?.size ?? 0 > 0 {
            if CFTracker.eventDispatchState != .inProgress {
                cancelEventDispatchWorkRequest()
                CFTracker.EVENT_DISPATCH_WORKER_MAX_RETRIES = CFSDKConfig.getApiRetryCount()
                CFTracker.eventDispatchState = .inProgress
                eventDispatchWorkRequest = DispatchWorkItem {
                    if (self.events == nil) {
                        self.events = CFSharedPreferences.shared.getEvent()
                    }
                    let dispatchEventNumbers: Int = self.events?.size ?? 0
                    if (dispatchEventNumbers <= 0) {
                        return
                    }
                    var eventsToDispatch = Array<CFEvent>()
                    eventsToDispatch = self.events?.elements ?? []
                    self.events = CFQueue<CFEvent>(elements: [])
                    APIClient.shared.trackEvents(registerEvents: CFRegisterEvents(user: CFSharedPreferences.shared.getUser(), events: eventsToDispatch)) { (error) in
                        if error != nil {
                            for event in eventsToDispatch {
                                self.events?.enqueue(event)
                            }
                            CFTracker.eventDispatchState = .idle
                            self.lastPushTime = Date()
                            CFSharedPreferences.shared.setEvents(events: self.events)
                            CFSharedPreferences.shared.setEventsFlushDate(date: self.lastPushTime)
                        } else {
                            CFSharedPreferences.shared.setEvents(events: self.events)
                            CFTracker.eventDispatchState = .idle
                        }
                    }
                }
                eventDispatchWorkRequest?.perform()
            }
        }
    }
    
    func cancelEventDispatchWorkRequest() {
        if let eventDispatchWorkRequest = eventDispatchWorkRequest {
            eventDispatchWorkRequest.cancel()
        }
        CFTracker.eventDispatchState = .idle
    }
    
    func flushEvents() {
        let currentDate = Date()
        if (events != nil && events?.size ?? 0 >= CFSDKConfig.getEventQueueSize()) || (Int(((currentDate.timeIntervalSinceNow) - (lastPushTime?.timeIntervalSinceNow ?? 0))) >= CFSDKConfig.getEventQueuePollDuration()) {
            _flushEvents()
        }
    }
    
    public func forceFlush() {
        if(events != nil && events?.size ?? 0 > 0) {
            _flushEvents()
        }
    }
    
    public func handleAppForeground() {
        flushEvents()
    }
    
    public func handleAppBackground() {
        _flushEvents()
    }
    
    public func isUsedInExperience(eventId: String, vendor: String) -> Bool {
        if let configuredEventMap = CFSharedPreferences.shared.getConfiguredEvents(), let configuredEvent = configuredEventMap[eventId] {
            if configuredEvent.experiences != nil && configuredEvent.experiences?.count ?? 0 > 0 && configuredEvent.vendors != nil {
                /*for(String cVendor : configuredEventMap.get(eventId).getVendors()) {
                 if(vendor.equals(cVendor)) {
                 return true
                 }
                 }*/
                return true
            }
        }
        
        return false
    }
    
}
