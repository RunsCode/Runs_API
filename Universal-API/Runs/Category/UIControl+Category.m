//
//  UIControl+Category.m
//  OU_iPad
//
//  Created by runs on 2017/9/25.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UIControl+Category.h"
#import <objc/runtime.h>
#import "UIView+Toast.h"

@implementation UIControl (Category)
static const char *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";

- (NSTimeInterval)rs_acceptEventInterval {
    return  [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

- (void)setRs_acceptEventInterval:(NSTimeInterval)rs_acceptEventInterval {
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(rs_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static const char *UIControl_acceptEventTime = "UIControl_acceptEventTime";

- (NSTimeInterval)rs_acceptEventTime {
    return  [objc_getAssociatedObject(self, UIControl_acceptEventTime) doubleValue];
}

- (void)setRs_acceptEventTime:(NSTimeInterval)rs_acceptEventTime {
    objc_setAssociatedObject(self, UIControl_acceptEventTime, @(rs_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// 在load时执行hook
+ (void)load {
    Method before = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method after  = class_getInstanceMethod(self, @selector(rs_sendAction:to:forEvent:));
    method_exchangeImplementations(before, after);
}

- (void)rs_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {

    if ([NSDate date].timeIntervalSince1970 - self.rs_acceptEventTime < self.rs_acceptEventInterval) {
        [UIApplication.sharedApplication.keyWindow makeToast:@"点击的频率太快了" duration:0.5 position:CSToastPositionBottom];
        return;
    }
    
    if (self.rs_acceptEventInterval > 0) {
        self.rs_acceptEventTime = [NSDate date].timeIntervalSince1970;
    }
    
    [self rs_sendAction:action to:target forEvent:event];
}
@end
