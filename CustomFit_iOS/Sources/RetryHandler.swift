//
//  RetryHandler.swift
//  Example
//
//  Created by Rajtharan G on 10/09/19.
//  Copyright © 2019 CustomFit. All rights reserved.
//

import Foundation
import Alamofire

class RetryHandler: RequestAdapter, RequestRetrier {
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: RequestRetryCompletion) {
        if let urlString = request.task?.currentRequest?.url?.absoluteString {
            if urlString.contains("sdk/configs") {
                CFSDKConfig.SDK_CONFIG_FETCHER_WORKER_MAX_RETRIES -= 1
                if (CFSDKConfig.SDK_CONFIG_FETCHER_WORKER_MAX_RETRIES > 0) {
                    let retryAfter = fib(request.retryCount)
                    completion(true, TimeInterval(retryAfter))
                } else {
                    completion(false, 0)
                }
            } else if urlString.contains("events") {
                CFSDKConfig.CONFIGURED_EVENT_FETCHER_WORKER_MAX_RETRIES -= 1
                if (CFSDKConfig.CONFIGURED_EVENT_FETCHER_WORKER_MAX_RETRIES > 0) {
                    let retryAfter = fib(request.retryCount)
                    completion(true, TimeInterval(retryAfter))
                } else {
                    completion(false, 0)
                }
            } else if urlString.contains("users/configs") {
                CustomFit.CONFIG_FETCH_WORKER_MAX_RETRIES -= 1
                if (CustomFit.CONFIG_FETCH_WORKER_MAX_RETRIES > 0) {
                    let retryAfter = fib(request.retryCount)
                    completion(true, TimeInterval(retryAfter))
                } else {
                    completion(false, 0)
                }
            } else if urlString.contains("summary") {
                CFSummaryExporter.shared.SUMMARY_EVENT_DISPATCH_WORKER_MAX_RETRIES -= 1
                if (CFSummaryExporter.shared.SUMMARY_EVENT_DISPATCH_WORKER_MAX_RETRIES > 0) {
                    let retryAfter = fib(request.retryCount)
                    completion(true, TimeInterval(retryAfter))
                } else {
                    completion(false, 0)
                }
            } else if urlString.contains("track") {
                CFTracker.EVENT_DISPATCH_WORKER_MAX_RETRIES -= 1
                if (CFTracker.EVENT_DISPATCH_WORKER_MAX_RETRIES > 0) {
                    let retryAfter = fib(request.retryCount)
                    completion(true, TimeInterval(retryAfter))
                } else {
                    completion(false, 0)
                }
            } else if urlString.contains("devices") {
                CustomFit.ADD_DEVICE_WORKER_MAX_RETRIES -= 1
                if (CustomFit.ADD_DEVICE_WORKER_MAX_RETRIES > 0) {
                    let retryAfter = fib(request.retryCount)
                    completion(true, TimeInterval(retryAfter))
                } else {
                    completion(false, 0)
                }
            }
        }
        completion(false, 0)
    }
    
    func fib(_ n: UInt) -> UInt {
        guard n > 1 else { return n }
        return fib(n-1) + fib(n-2)
    }
    
}
