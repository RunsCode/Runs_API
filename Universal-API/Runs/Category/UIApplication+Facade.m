//
//  UIApplication+Facade.m
//  OU_iPhone
//
//  Created by runs on 2018/4/8.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "UIApplication+Facade.h"

@implementation UIApplication (Facade)

- (void)rs_horizontalScreen {
    UIDeviceOrientation orientation = UIDevice.currentDevice.orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        return;
    }
    UIDeviceOrientation orientationOfDevice = UIDeviceOrientationLandscapeLeft;
    if (UIDeviceOrientationLandscapeRight == orientation || UIDeviceOrientationLandscapeRight == UIDeviceOrientationLandscapeLeft) {
        orientationOfDevice = orientation;
    }
    [UIDevice.currentDevice setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
    [UIDevice.currentDevice setValue:@(orientationOfDevice) forKey:@"orientation"];
    RunsLog(@"屏幕旋转：%@", orientationOfDevice == UIDeviceOrientationLandscapeLeft ? @"UIDeviceOrientationLandscapeLeft" : @"UIDeviceOrientationLandscapeRight"  )
}

- (void)rs_verticalScreen {
    [UIApplication.sharedApplication setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [UIDevice.currentDevice setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
}

@end
