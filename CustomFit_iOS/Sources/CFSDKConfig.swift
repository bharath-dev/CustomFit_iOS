//
//  CFSDKConfig.swift
//  CustomFit
//
//  Created by Rajtharan G on 23/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import Foundation

public struct CFSDKConfig {
    
    private static var CONFIG_REFRESH_DURATION_KEY: String = "cf_android_sdk_config_refresh_duration"
    private static var CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_KEY: String = "cf_android_sdk_config_refresh_duration_additional_random_add"
    private static var API_RETRY_COUNT_KEY: String = "cf_android_sdk_api_retry_count"
    private static var PERIODIC_EVENT_PROCESSOR_INTERVAL_KEY: String = "cf_android_sdk_config_periodic_event_processor_interval"
    private static var EVENT_QUEUE_POLL_DURATION_KEY: String = "cf_android_sdk_config_event_queue_poll_duration"
    private static var EVENT_QUEUE_SIZE_KEY: String = "cf_android_sdk_config_event_queue_size"
    private static var CONFIG_REQUEST_SUMMARY_QUEUE_POLL_DURATION_KEY: String = "cf_android_sdk_config_config_fetch_summary_queue_poll_duration"
    private static var CONFIG_REQUEST_SUMMARY_QUEUE_SIZE_KEY: String = "cf_android_sdk_config_config_fetch_summary_queue_size"
    private static var API_EXPONENTIAL_BACKOFF_DELAY_KEY: String = "cf_android_sdk_exponential_backoff_time"
    
    private static var CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_VALUE: Int = 300000
    private static var CONFIG_REFRESH_DURATION_VALUE: Int = Int(43200000 + arc4random_uniform(UInt32(CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_VALUE)))
    private static var API_RETRY_COUNT_VALUE: Int = 10
    private static var PERIODIC_EVENT_PROCESSOR_INTERVAL_VALUE: Int = 900000
    private static var EVENT_QUEUE_POLL_DURATION_VALUE: Int = 900000
    private static var EVENT_QUEUE_SIZE_VALUE: Int = 50
    private static var CONFIG_REQUEST_SUMMARY_QUEUE_POLL_DURATION_VALUE: Int = 900000
    private static var CONFIG_REQUEST_SUMMARY_QUEUE_SIZE_VALUE: Int = 50
    private static var API_EXPONENTIAL_BACKOFF_DELAY_VALUE: Int = 15000
    
    private static var initialized: Bool = false
    private static var sdkConfigs: [String : String]?
    private static var SDK_CONFIG_FETCHER_WORKER_NAME: String = "SDK_CONFIG_FETCHER_WORKER_NAME"
    private static var sdkConfigFetchWorkRequest: DispatchWorkItem?
    private static var CONFIGURED_EVENT_FETCHER_WORKER_NAME: String = "CONFIGURED_EVENTS_FETCHER"
    private static var configuredEventFetchWorkRequest: DispatchWorkItem?
    public static var SDK_CONFIG_FETCHER_WORKER_MAX_RETRIES: Int = 0
    public static var CONFIGURED_EVENT_FETCHER_WORKER_MAX_RETRIES: Int = 0
    //
    init() {
        if !CFSDKConfig.initialized {
            CFSDKConfig.sdkConfigs = CFSharedPreferences.shared.getSdkConfigs()
            fetchSdkConfigs()
            fetchConfiguredEvents()
            CFSDKConfig.initialized = true
        }
    }
    //
    public static func reset() {
        if initialized {
            cancelConfiguredEventFetchWorkRequest()
            cancelSdkConfigFetchRequest()
            initialized = false
        }
    }
    
    public func fetchSdkConfigs() {
        CFSDKConfig.SDK_CONFIG_FETCHER_WORKER_MAX_RETRIES = CFSDKConfig.getApiRetryCount()
        APIClient.shared.getSdkConfigs { (configs, error) in
            if let config = configs {
                CFSharedPreferences.shared.setSdkConfigs(configList: config)
            } 
        }
    }
    //
    public func fetchConfiguredEvents() {
        CFSDKConfig.CONFIGURED_EVENT_FETCHER_WORKER_MAX_RETRIES = CFSDKConfig.getApiRetryCount()
        APIClient.shared.getConfiguredEvents { (configuredEvents, error) in
            if let configEvents = configuredEvents {
                CFSharedPreferences.shared.setConfiguredEvents(events: configEvents)
            } 
        }
    }
    
    public static func cancelSdkConfigFetchRequest() {
        if let workRequest = sdkConfigFetchWorkRequest {
            workRequest.cancel()
        }
    }
    
    public static func cancelConfiguredEventFetchWorkRequest() {
        if let workRequest = configuredEventFetchWorkRequest {
            workRequest.cancel()
        }
    }
    
    public static func getConfigRefershDurationRandomAdd() -> Int {
        return getInteger(CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_KEY, CONFIG_REFRESH_DURATION_ADDITIONAL_RANDOM_ADD_VALUE)
    }
    //
    public static func getConfigRefershDuration() -> Int {
        let refreshDuration = getInteger(CONFIG_REFRESH_DURATION_KEY, CONFIG_REFRESH_DURATION_VALUE)
        if (refreshDuration != CONFIG_REFRESH_DURATION_VALUE) {
            let rand = getConfigRefershDurationRandomAdd()
            return refreshDuration + Int(arc4random_uniform(UInt32(rand)))
        }
        return refreshDuration
    }
    //
    public static func getApiRetryCount() -> Int {
        return getInteger(API_RETRY_COUNT_KEY, API_RETRY_COUNT_VALUE)
    }
    
    public static func getPeriodicEventProcessorInterval() -> Int {
        return getInteger(PERIODIC_EVENT_PROCESSOR_INTERVAL_KEY, PERIODIC_EVENT_PROCESSOR_INTERVAL_VALUE)
    }
    
    public static func getEventQueuePollDuration() -> Int {
        return getInteger(EVENT_QUEUE_POLL_DURATION_KEY, EVENT_QUEUE_POLL_DURATION_VALUE)
    }
    
    public static func getEventQueueSize() -> Int {
        return 1
        return getInteger(EVENT_QUEUE_SIZE_KEY, EVENT_QUEUE_SIZE_VALUE)
    }
    
    public static func getConfigRequestSummaryQueuePollDuration() -> Int {
        return getInteger(CONFIG_REQUEST_SUMMARY_QUEUE_POLL_DURATION_KEY, CONFIG_REQUEST_SUMMARY_QUEUE_POLL_DURATION_VALUE)
    }
    
    public static func getConfigRequestSummaryQueueSize() -> Int {
        return getInteger(CONFIG_REQUEST_SUMMARY_QUEUE_SIZE_KEY,CONFIG_REQUEST_SUMMARY_QUEUE_SIZE_VALUE)
    }
    
    public static func getApiExponentialBackoffDelay() -> Int {
        return getInteger(API_EXPONENTIAL_BACKOFF_DELAY_KEY,API_EXPONENTIAL_BACKOFF_DELAY_VALUE)
    }
    
    public static func getString(key: String, fallbackValue: String) -> String {
        if let value = sdkConfigs?[key] {
            return value
        }
        return fallbackValue
    }
    
    public static func getInteger(_ key: String, _ fallbackValue: Int) -> Int {
        if let value = sdkConfigs?[key], let intValue = Int(value) {
            return intValue
        }
        return fallbackValue
    }
    
    public static func isInteger(s: String) -> Bool {
        if let _ = Int(s) {
            return true
        } else {
            return false
        }
    }
    
}
