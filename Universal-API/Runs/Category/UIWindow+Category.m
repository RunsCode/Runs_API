//
//  UIWindow+Category.m
//  OU_iPad
//
//  Created by runs on 2017/12/18.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UIWindow+Category.h"

@implementation UIWindow (Category)

+ (UIView *)rs_topView {
    return self.rs_topViewController.view;
}

+ (UIView *)rs_topNavigationControllerView {
    return self.rs_topNavigationController.view;
}

+ (UIWindow *)rs_topWindow {
    return UIApplication.sharedApplication.delegate.window;
}

+ (UIViewController *)rs_topViewController {
    UIWindow *window = [UIApplication.sharedApplication.delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:UINavigationController.class] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:UITabBarController.class]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

+ (UITabBarController *)rs_topTabBarController {
    UIWindow *window = [UIApplication.sharedApplication.delegate window];
    UIViewController *topViewController = [window rootViewController];
    if ([topViewController isKindOfClass:UITabBarController.class]) {
        return (UITabBarController *)topViewController;
    }else if (topViewController.childViewControllers.count > 0) {
        __block BOOL isContainTabBarTabBarController = NO;
        __block NSUInteger index = 0;
        [topViewController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UITabBarController.class]) {
                isContainTabBarTabBarController = YES;
                index = idx;
                *stop = YES;
            }
        }];
        
        if (isContainTabBarTabBarController) {
            UITabBarController *controller = (UITabBarController *)topViewController.childViewControllers[index];
            return controller;
        }
        
    }
    return nil;
}

+ (UINavigationController *)rs_topNavigationController {
    UIWindow *window = [UIApplication.sharedApplication.delegate window];
    UIViewController *topViewController = [window rootViewController];
    if ([topViewController isKindOfClass:UINavigationController.class]) {
        return (UINavigationController *)topViewController;
    }
    if ([topViewController isKindOfClass:UITabBarController.class]) {
        UITabBarController *tabBarController = (UITabBarController *)topViewController;
        if ([tabBarController.selectedViewController isKindOfClass:UINavigationController.class]) {
            return (UINavigationController *)tabBarController.selectedViewController;
        }
    } else if (topViewController.childViewControllers.count > 0) {
        __block BOOL isContainTabBarTabBarController = NO;
        __block NSUInteger index = 0;
        [topViewController.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:UITabBarController.class]) {
                isContainTabBarTabBarController = YES;
                index = idx;
                *stop = YES;
            }
        }];
        
        if (isContainTabBarTabBarController) {
            UITabBarController *controller = (UITabBarController *)topViewController.childViewControllers[index];
            UIViewController *child = controller.selectedViewController;
            if ([child isKindOfClass:UINavigationController.class]) {
                return (UINavigationController *)child;
            }
        }
        
    }
    return nil;
}


@end
