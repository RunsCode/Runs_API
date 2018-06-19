//
//  NSURLSessionTask+Category.m
//  OU_iPhone
//
//  Created by runs on 2017/11/21.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSURLSessionTask+Category.h"
#define DEFAULT_MAX_RETRY_COUNT (3)

static const NSString * RSRetryCountKey = @"RSRetryCountKey";
static const NSString * RSRetryMaxCountKey = @"RSRetryMaxCountKey";


@implementation NSURLSessionTask (Category)

- (void)rs_retry:(void(^)(void))completd {
    
    NSNumber *number = (NSNumber *)objc_getAssociatedObject(self, &RSRetryCountKey);
    NSInteger maxCount = self.maxRetryCount;
    NSInteger count = number.integerValue;
    if (count >= maxCount) {
        if (completd) {
            completd();
        }
        return;
    }
    [self cancel];
    [self resume];
    count++;
    objc_setAssociatedObject (self, &RSRetryCountKey, @(count), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMaxRetryCount:(NSInteger)maxRetryCount {
    objc_setAssociatedObject (self, &RSRetryMaxCountKey, @(maxRetryCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)maxRetryCount {
    NSNumber *number = (NSNumber *)objc_getAssociatedObject(self, &RSRetryMaxCountKey);
    NSInteger maxCount = number.integerValue;
    if (!number || maxCount <= 0) {
        maxCount = DEFAULT_MAX_RETRY_COUNT;
    }
    return maxCount;
}

@end
