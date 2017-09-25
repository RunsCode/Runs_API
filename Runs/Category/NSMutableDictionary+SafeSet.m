//
//  NSMutableDictionary+SafeSet.m
//  OU_iPad
//
//  Created by runs on 2017/8/22.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSMutableDictionary+SafeSet.h"

@implementation NSMutableDictionary (SafeSet)

- (void)rs_setInt:(NSInteger)intValue forInt:(NSInteger)key {
    [self rs_setObject:@(intValue) forKey:@(key)];
}

- (void)rs_setInt:(NSInteger)intValue forFloat:(CGFloat)key {
    [self rs_setObject:@(intValue) forKey:@(key)];
}

- (void)rs_setFloat:(CGFloat)floatValue forInt:(NSInteger)key {
    [self rs_setObject:@(floatValue) forKey:@(key)];
}

- (void)rs_setFloat:(CGFloat)floatValue forFloat:(CGFloat)key {
    [self rs_setObject:@(floatValue) forKey:@(key)];
}

- (void)rs_setObject:(id)anObj forFloat:(CGFloat)key {
    [self rs_setObject:anObj forKey:@(key)];
}

- (void)rs_setObject:(id)anObj forInt:(NSInteger)key {
    [self rs_setObject:anObj forKey:@(key)];
}

- (void)rs_setObject:(id)anObj forKey:(id<NSCopying>)key {
    if(key) {
        if(anObj) {
            [self setObject:anObj forKey:key];
        }else{
            RunsLog(@"字典插入对象为空 key = %@",key);
        }
    }else{
        RunsLog(@"字典插入key为空");
    }
}


- (id)rs_objectForInt:(NSInteger)intValue {
    return self[@(intValue)];
}

- (id)rs_objectForFloat:(CGFloat)floatValue {
    return self[@(floatValue)];
}

- (void)rs_removeObjectForInt:(NSInteger)intValue {
    [self removeObjectForKey:@(intValue)];
}

- (void)rs_removeObjectForFloat:(CGFloat)floatValue {
    [self removeObjectForKey:@(floatValue)];
}

@end
