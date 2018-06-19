//
//  UIAlertController+Category.m
//  OU_iPad
//
//  Created by runs on 2017/9/19.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UIAlertController+Category.h"

@implementation UIAlertController (Category)

+ (instancetype)rs_showNormalAlertTitle:(NSString *)title massage:(NSString *)message buttonName:(NSString *)name {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:nil]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    return alert;
}

@end
