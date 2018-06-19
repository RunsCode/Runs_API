//
//  UIWindow+Category.h
//  OU_iPad
//
//  Created by runs on 2017/12/18.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (Category)
+ (UIView *)rs_topView;
+ (UIWindow *)rs_topWindow;
+ (UIView *)rs_topNavigationControllerView;
+ (UIViewController *)rs_topViewController;
+ (UITabBarController *)rs_topTabBarController;
+ (UINavigationController *)rs_topNavigationController;
@end
