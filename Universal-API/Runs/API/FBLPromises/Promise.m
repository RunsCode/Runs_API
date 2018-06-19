//
//  Promise.m
//  OU_iPhone
//
//  Created by runs on 2018/6/5.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "Promise.h"

@implementation Promise

@end

@implementation Promise (DotSyntaxAdditions)

+ (Promise* (^)(id __nullable))resolve {
    return ^(id resolution) {
        return [self resolvedWith:resolution];
    };
}

@end
