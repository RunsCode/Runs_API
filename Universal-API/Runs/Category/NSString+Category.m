//
//  NSString+Category.m
//  OU_iPhone
//
//  Created by runs on 2017/10/30.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)
- (NSString *)rs_nonNull {
    if (self.length <= 0) {
        return NON_STRING;
    }
    return self;
}
@end
