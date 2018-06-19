//
//  NSString+Assistant.m
//  OU_iPad
//
//  Created by runs on 2017/12/7.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSString+Assistant.h"
#import <objc/runtime.h>

static const NSString * RSRunsHttpAssistantKey = @"RSRunsHttpAssistantKey";

@implementation NSString (Assistant)


- (void)setHttpAssistant:(RunsHttpAssistant *)httpAssistant {
    objc_setAssociatedObject (self, &RSRunsHttpAssistantKey, httpAssistant, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RunsHttpAssistant *)httpAssistant {
    return objc_getAssociatedObject(self, &RSRunsHttpAssistantKey);
}

- (void)rs_relaseAssisant {
    objc_setAssociatedObject (self, &RSRunsHttpAssistantKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
