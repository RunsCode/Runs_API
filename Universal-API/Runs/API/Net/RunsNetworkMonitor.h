//
//  RunsNetworkMonitor.h
//  OU_iPad
//
//  Created by runs on 2017/10/12.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString * const RunsNetworkMonitorDidChangeMessage; //object NSNumber(NetworkStatus)

typedef void(^RunsNetworkChangeCallback)(NetworkStatus status);

@interface RunsNetworkMonitor : NSObject
+ (BOOL)isReachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;
+ (BOOL)NetworkIsReachableWithShowTips:(BOOL)isShow;
+ (void)NetWorkMonitorWithReachableBlock:(NetworkReachable)reachable unreachableBlock:(NetworkUnreachable)unreachable;
@end
