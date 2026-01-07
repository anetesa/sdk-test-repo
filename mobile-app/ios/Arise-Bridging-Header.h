//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TapToPhoneModule, NSObject)

RCT_EXTERN_METHOD(isTapToPaySupported:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(initializeReader:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(startPaymentSession:(double)amount resolve:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(endSession:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end