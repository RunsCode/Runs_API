//
//  NSArray+Format.m
//  Hey
//
//  Created by wang on 2017/6/4.
//  Copyright © 2017年 Giant Inc. All rights reserved.
//

#import "NSArray+Format.h"
#import "NSObject+RuntimeLog.h"
@implementation NSArray (Format)

- (NSString *)toString {
    NSString *string = @"";
    for (int i = 0; i < self.count; i++) {
        string = [NSString stringWithFormat:@"%@ \n ---------------------------------------------------------- \n index =  %d", string, i];
        string = [NSString stringWithFormat:@"%@ \n %@", string, self[i]];
        NSUInteger length = ((NSObject *)self[i]).rs_propertyCount;
        NSArray *keys = [self[i] rs_fetchPropertyWithLength:length];
        NSDictionary *map = [self[i] dictionaryWithValuesForKeys:keys];
        string = [NSString stringWithFormat:@"%@ \n %@", string, map];
    }
    return string;
}

- (BOOL)isEmpty {
    return self.count <= 0;
}

@end
