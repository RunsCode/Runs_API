//
//  UIControl+Category.h
//  OU_iPad
//
//  Created by runs on 2017/9/25.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (Category)
@property (nonatomic, assign) NSTimeInterval rs_acceptEventInterval; // 重复点击的间隔
@property (nonatomic, assign) NSTimeInterval rs_acceptEventTime;

@end
