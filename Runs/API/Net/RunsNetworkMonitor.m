//
//  RunsNetworkMonitor.m
//  OU_iPad
//
//  Created by runs on 2017/10/12.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsNetworkMonitor.h"
@interface RunsNetworkMonitor()
@end

@implementation RunsNetworkMonitor

static Reachability *reachability = nil;
static UIAlertView *stAlert = nil;

+ (Reachability *)reachability {
    if (reachability) return reachability;
    reachability = [Reachability reachabilityForInternetConnection];
    return reachability;
}

+ (BOOL)isReachable {
    return self.reachability.isReachable;
}

+ (BOOL)isReachableViaWWAN {
    return self.reachability.currentReachabilityStatus == ReachableViaWWAN;
}

+ (BOOL)isReachableViaWiFi {
    return self.reachability.currentReachabilityStatus == ReachableViaWiFi;
}

+ (BOOL)NetworkIsReachableWithShowTips:(BOOL)isShow {
    if (!self.reachability.isReachable && isShow) {
        [self showAlert];
    }
    return self.reachability.isReachable;
}

+ (void)NetWorkMonitorWithReachableBlock:(NetworkReachable)reachable unreachableBlock:(NetworkUnreachable)unreachable {
    self.reachability.reachableBlock = ^(Reachability *reachability) {
        RunsLogEX(@"网络恢复连接")
        if (reachable) {
            reachable(reachability);
        }
        
        [NSObject rs_safeMainThreadAsync:^{
            if (stAlert) {
                [stAlert dismissWithClickedButtonIndex:0 animated:YES];
                stAlert = nil;
            }
        }];
    };
    self.reachability.unreachableBlock = ^(Reachability *reachability) {
        RunsLogEX(@"网络断开连接")
        if (unreachable) {
            unreachable(reachability);
        }
        [NSObject rs_safeMainThreadAsync:^{
            [self showAlert];
        }];
    };
    [reachability startNotifier];
}

+ (void)showAlert {
    if (stAlert) {
        [stAlert show];
        return;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"您的网络似乎不通" message:@"请您检查你的网络设置是否已经断开" delegate:self cancelButtonTitle:@"去设置" otherButtonTitles:nil];
    [alertView show];
    //
    stAlert = alertView;
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSURL *url = [NSURL URLWithString:@"App-Prefs:root=WIFI"];//
    if ([UIApplication.sharedApplication canOpenURL:url]) {
        if ([UIApplication.sharedApplication openURL:url])  return;
    }
    if (@available(iOS 10.0, *)) {
        [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
    }
}

@end
