//
//  NSString+NSURL_FOR_HTTP.m
//  OU_iPad
//
//  Created by runs on 2017/8/3.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSString+NSURL_FOR_HTTP.h"

@implementation NSString (NSURL_FOR_HTTP)

- (NSURL *)composeURLWithKeyValue:(NSDictionary *)parameters {
    __block NSString *blockUrl = self;
    NSArray<NSString *> *keys = [parameters allKeys];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *keyPath = [NSString stringWithFormat:@"{%@}",obj];
        if ([blockUrl containsString:keyPath]) {
            NSString *value = parameters[obj];
            if ([value isKindOfClass:NSNumber.class]) {
                value = [NSString stringWithFormat:@"%ld",(long)value.integerValue];
            }
            blockUrl = [blockUrl stringByReplacingOccurrencesOfString:keyPath withString:value];
        }
    }];
    blockUrl = [blockUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:blockUrl];
    return url;
}
@end
