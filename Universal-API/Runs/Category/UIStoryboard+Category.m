//
//  UIStoryboard+Category.m
//  OU_iPhone
//
//  Created by runs on 2018/5/16.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "UIStoryboard+Category.h"

@implementation UIStoryboard (Category)

+ (instancetype)rs_storyboardInMainBundleWithName:(NSString *)storyboardName {
    return [UIStoryboard storyboardWithName:storyboardName bundle:NSBundle.mainBundle];
}

+ (UIViewController *)rs_instantiateViewControllerWithClass:(Class)cls {
    NSString *storyName = NSStringFromClass(cls);
    UIStoryboard *storyboard = [UIStoryboard rs_storyboardInMainBundleWithName:storyName];
    return [storyboard instantiateViewControllerWithIdentifier:storyName];
}
@end
