//
//  NSMutableDictionary+SafeSet.m
//  OU_iPad
//
//  Created by runs on 2017/8/22.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSMutableDictionary+SafeSet.h"

@implementation NSMutableDictionary (SafeSet)

- (BOOL)rs_setInt:(NSInteger)intValue forInt:(NSInteger)key {
    return [self rs_setObject:@(intValue) forKey:@(key)];
}

- (BOOL)rs_setInt:(NSInteger)intValue forFloat:(CGFloat)key {
    return [self rs_setObject:@(intValue) forKey:@(key)];
}

- (BOOL)rs_setInt:(NSInteger)intValue forKey:(id<NSCopying>)key {
    return [self rs_setObject:@(intValue) forKey:key];
}

- (BOOL)rs_setFloat:(CGFloat)floatValue forInt:(NSInteger)key {
    return [self rs_setObject:@(floatValue) forKey:@(key)];
}

- (BOOL)rs_setFloat:(CGFloat)floatValue forFloat:(CGFloat)key {
    return [self rs_setObject:@(floatValue) forKey:@(key)];
}

- (BOOL)rs_setFloat:(CGFloat)floatValue forKey:(id<NSCopying>)key {
    return [self rs_setObject:@(floatValue) forKey:key];
}

- (BOOL)rs_setObject:(id)anObj forFloat:(CGFloat)key {
    return [self rs_setObject:anObj forKey:@(key)];
}

- (BOOL)rs_setObject:(id)anObj forInt:(NSInteger)key {
    return [self rs_setObject:anObj forKey:@(key)];
}

- (BOOL)rs_setObject:(id)anObj forKey:(id<NSCopying>)key {
    if(key) {
        if(anObj) {
            @synchronized(self) {
                [self setObject:anObj forKey:key];
                return YES;
            }
        }else{
            RunsLog(@"字典插入对象为空 key = %@",key);
            return NO;
        }
    }else{
        RunsLog(@"字典插入key为空");
        return NO;
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


- (BOOL)isEmpty {
    return self.count <= 0;
}
@end
