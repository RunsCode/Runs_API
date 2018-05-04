//
//  NSMutableDictionary+SafeSet.h
//  OU_iPad
//
//  Created by runs on 2017/8/22.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SafeSet)
- (void)rs_setInt:(NSInteger)intValue forInt:(NSInteger)key;
- (void)rs_setInt:(NSInteger)intValue forFloat:(CGFloat)key;
- (void)rs_setInt:(NSInteger)intValue forKey:(id<NSCopying>)key;
//
- (void)rs_setFloat:(CGFloat)floatValue forInt:(NSInteger)key;
- (void)rs_setFloat:(CGFloat)floatValue forFloat:(CGFloat)key;
- (void)rs_setFloat:(CGFloat)floatValue forKey:(id<NSCopying>)key;
//
- (void)rs_setObject:(id)anObj forInt:(NSInteger)key;
- (void)rs_setObject:(id)anObj forFloat:(CGFloat)key;
- (void)rs_setObject:(id)anObj forKey:(id<NSCopying>)key;
//
- (id)rs_objectForInt:(NSInteger)intValue;
- (id)rs_objectForFloat:(CGFloat)floatValue;
//
- (void)rs_removeObjectForInt:(NSInteger)intValue;
- (void)rs_removeObjectForFloat:(CGFloat)floatValue;

- (BOOL)isEmpty;

@end
