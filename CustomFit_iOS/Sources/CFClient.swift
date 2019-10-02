//
//  CFClient.swift
//  CustomFit
//
//  Created by Rajtharan G on 20/08/19.
//  Copyright © 2019 Custom Fit. All rights reserved.
//

import UIKit

//public protocol GetConfigCallbacks {
//    func onGetConfigSuccess(cfGetUserConfigsResponse: CFGetUserConfigsResponse)
//    func onGetConfigFaliure(error: Int)
//}
//
//public protocol GetSdkConfigCallbacks {
//    func onGetSdkConfigSuccess(configs: [String: String])
//    func onGetSdkConfigFaliure(errorCode: Int)
//}
//
//public protocol AddDeviceCallBack {
//    func onAddDeviceSuccess(cfUserId: String, instanceId: String)
//    func onAddDeviceFailure(cfUserId: String, instanceId: String, errorCode: Int)
//}
//
//public protocol TrackEventsCallBack {
//    func onTrackEventsSuccess()
//    func onTrackEventsFailure(errorCode: Int)
//}
//
//public protocol PushConfigRequestSummaryEventsCallBack {
//    func onPushSuccess()
//    func onPushFailure(errorCode: Int)
//}
//
//public protocol GetConfiguredEventsCallBack {
//    func onGetConfiguredEventsSuccess(events: [String: CFConfiguredEvent])
//    func onGetConfiguredEventsFailure(errorCode: Int)
//}

public class CFClient: NSObject {
    
    static let TAG: String = "CusfomFit.ai"
    
    public class func trackEventsSync(events: Any?) -> Bool {
        //TODO: Fill the class
        
        return false
    }
    
//    public static func getSdkConfigs(callbacks: GetSdkConfigCallbacks) {
//        
//    }
//    
////    try {
//    APIClient.api().getSdkConfigs()
//    .enqueue(new Callback<Map<String,String>>() {
//    @Override
//    public void onResponse(Call<Map<String,String> > call,
//    final Response<Map<String,String>> response) {
//    if(response.isSuccessful()) {
//    if(callbacks != null)
//    callbacks.onGetSdkConfigSuccess(response.body());
//    } else {
//    Log.w(TAG, "Error in getConfigs: "+response.code()+" "+response.errorBody());
//    if(callbacks != null)
//    callbacks.onGetSdkConfigFaliure(response.code());
//    }
//    }
//
//    @Override
//    public void onFailure(Call< Map <String,String> > call, Throwable t) {
//    Log.w(TAG, "Error in getConfigs");
//    if(callbacks != null)
//    callbacks.onGetSdkConfigFaliure(-1);
//    }
//    });
//    } catch (Exception e) {
//    Log.w(TAG,"Error in getConfigs",e);
//    }

}
