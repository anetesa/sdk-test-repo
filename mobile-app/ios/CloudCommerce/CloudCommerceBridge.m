//
//  CloudCommerceBridge.m
//  Arise
//
//  Created by Alexandr on 20.06.2025.
//
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(CloudCommerceModule, NSObject)

RCT_EXTERN_METHOD(prepare:(NSString *)token
                  merchantDict:(NSDictionary *)merchant
                  isProd:(BOOL)isProd
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(resume:(NSString *)token
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(performTransaction:(NSDictionary *)detailsDict
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(showTapToPayEducationScreens:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
