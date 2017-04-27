//
//  WebServiceConfig.m
//  Weather
//
//  Created by Slaheddine on 23/10/13.
//  Copyright (c) 2013 Slaheddine. All rights reserved.
//

#import "WebServiceConfig.h"
#import "Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

@implementation WebServiceConfig

static NSString *token = 0;
static bool isShowin = NO;

+ (void)setMessageIsShowin:(bool)b;
{ isShowin = b; }

+ (bool)getMessageIsShowin {
  return isShowin;
}

+ (NSString *)getToken {
  return token;
}

+ (void)setToken:(NSString *)new_token {
  token = new_token;
}

+ (bool)thersIsConnetion {
  Reachability *networkReachability =
      [Reachability reachabilityForInternetConnection];
  NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
  if (networkStatus == NotReachable) {
    return NO;
  } else {
    return YES;
  }
}

/*
 +(bool) myConnectionIsFast
 {
 CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
 NSLog(@"Current Radio Access Technology: %@",
 telephonyInfo.currentRadioAccessTechnology);
 [NSNotificationCenter.defaultCenter
 addObserverForName:CTRadioAccessTechnologyDidChangeNotification
 object:nil
 queue:nil
 usingBlock:^(NSNotification *note)
 {
 NSLog(@"New Radio Access Technology: %@",
 telephonyInfo.currentRadioAccessTechnology);


 }];


 }*/

- (BOOL)myConnectionIsFast:(NSString *)radioAccessTechnology {

  if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
    return NO;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyEdge]) {
    return NO;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyWCDMA]) {
    return YES;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyHSDPA]) {
    return YES;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyHSUPA]) {
    return YES;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
    return YES;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
    return YES;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
    return YES;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
    return YES;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyeHRPD]) {
    return YES;
  } else if ([radioAccessTechnology
                 isEqualToString:CTRadioAccessTechnologyLTE]) {
    return YES;
  }

  return YES;
}

@end
