//
//  CFSummaryExporter.swift
//  CustomFit
//
//  Created by Rajtharan G on 24/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

class CFSummaryExporter {
    
    static let shared = CFSummaryExporter()
    
    private var events: CFQueue<CFConfigRequestSummary>?
    private var lastPushTime: Date?
    private let EVENT_DISPATCHER_WORKER_NAME: String = "CUSTOMFIT_SUMMARY_EVENT_DISPATCHER"
    private var eventDispatchWorkRequest: DispatchWorkItem?
    private var eventDispatchState: EventDispatchState  = EventDispatchState.idle
    var SUMMARY_EVENT_DISPATCH_WORKER_MAX_RETRIES: Int  = 0
    
    private enum EventDispatchState {
        case idle, inProgress
    }
    
    init() {
        events = CFSharedPreferences.shared.getConfigRequestSummaryEvents()
        if(events == nil) {
            events = CFQueue(elements: Array())
        }
        
        lastPushTime = CFSharedPreferences.shared.getLastConfigRequestSummaryStoredDateTime()
        if(lastPushTime == nil) {
            lastPushTime = Date()
        }
        eventDispatchState = EventDispatchState.idle
        cancelEventDispatchWorkRequest()
        _flushEvents()
    }
    
    func reset() {
        forceFlush()
        cancelEventDispatchWorkRequest()
        eventDispatchWorkRequest = nil
        eventDispatchState = EventDispatchState.idle
    }
    
    //
    func _flushEvents() {
        if let events = events, events.size > 0 {
            if (eventDispatchState != EventDispatchState.inProgress) {
                cancelEventDispatchWorkRequest()
                SUMMARY_EVENT_DISPATCH_WORKER_MAX_RETRIES = CFSDKConfig.getApiRetryCount()
                eventDispatchState = EventDispatchState.inProgress
                eventDispatchWorkRequest = DispatchWorkItem {
                    if (self.events == nil) {
                        self.events = CFSharedPreferences.shared.getConfigRequestSummaryEvents()
                    }
                    if (self.events == nil) {
                        // Success
                    }
                    let dispatchEventNumbers = self.events?.elements.count
                    if (dispatchEventNumbers ?? 0 <= 0) {
                        // Success
                    }
                    var eventsToDispatch =  Array<CFConfigRequestSummary>()
                    eventsToDispatch = self.events?.elements ?? []
                    self.events = nil
                    APIClient.shared.pushConfigRequestSummaryEvents(events: eventsToDispatch, completion: { (error) in
                        if error != nil {
                            for event in eventsToDispatch {
                                self.events?.enqueue(event)
                            }
                            CFSharedPreferences.shared.setConfigRequestSummary(events: events.elements)
                            self.eventDispatchState = EventDispatchState.idle
                        } else {
                            self.eventDispatchState = EventDispatchState.idle
                            self.lastPushTime = Date()
                            CFSharedPreferences.shared.setConfigRequestSummary(events: events.elements)
                            CFSharedPreferences.shared.setConfigRequestSummaryFlushDate(date: self.lastPushTime)
                        }
                    })
                }
                eventDispatchWorkRequest?.perform()
            }
        }
    }
    
    func pushConfigRequestEvent(config: CFConfig?) {
        if let config = config, let events = events {
            events.enqueue(CFConfigRequestSummary(config: config))
            CFSharedPreferences.shared.setConfigRequestSummary(events: events.elements)
            flushEvents()
        }
    }
    
    func cancelEventDispatchWorkRequest() {
        if let eventDispatchWorkRequest = eventDispatchWorkRequest {
            eventDispatchWorkRequest.cancel()
        }
        eventDispatchState = .idle
    }
    
    func flushEvents() {
        let currentDate = Date()
        if let events = events {
            if events.size > CFSDKConfig.getConfigRequestSummaryQueueSize() || CFSharedPreferences.shared.getLastConfigRequestSummaryStoredDateTime() != nil &&
                (currentDate.seconds(from: CFSharedPreferences.shared.getLastConfigRequestSummaryStoredDateTime()!)
        >= CFSDKConfig.getConfigRequestSummaryQueuePollDuration()) {
                _flushEvents()
            }
        }
    }
    
    func forceFlush() {
        if let events = events, events.size > 0 {
            _flushEvents()
        }
    }
    
    func handleAppForeground() {
        flushEvents()
    }
    
    func handleAppBackground() {
        _flushEvents()
    }
    
}
