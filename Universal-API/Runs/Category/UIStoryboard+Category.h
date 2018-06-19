//
//  UIStoryboard+Category.h
//  OU_iPhone
//
//  Created by runs on 2018/5/16.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIStoryboard (Category)

/**
 在 mainBundle 获取storyboard

 @param storyboardName storyboardName
 @return UIStoryboard
 */
+ (instancetype)rs_storyboardInMainBundleWithName:(NSString *)storyboardName;

/**
 在 mainBundle 获取对应ViewController 实例

 @param cls 类class  结构体
 @return 类实例
 */
+ (UIViewController *)rs_instantiateViewControllerWithClass:(Class)cls;
@end
