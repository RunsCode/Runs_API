//
//  RunsTargetActionEngine.m
//  OU_iPhone
//
//  Created by runs on 2018/4/17.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "RunsTargetActionEngine.h"
#import "RunsMacroConstant.h"
#import <objc/message.h>

@implementation RunsTargetActionWrap

- (void)dealloc{
    RunsReleaseLog()
}

+ (instancetype)wrapWithTarget:(nullable id)target action:(nullable SEL)action {
    if (!target || !action) {
        return nil;
    }
    RunsTargetActionWrap *wrap = [[RunsTargetActionWrap alloc] init];
    wrap.target = target;
    wrap.action = NSStringFromSelector(action);
    return wrap;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:RunsTargetActionWrap.class]) {
        return NO;
    }
    RunsTargetActionWrap *obj = (RunsTargetActionWrap *)object;
    return obj.target == _target && [obj.action isEqualToString:_action];
}

- (NSUInteger)hash {
    return [self.target hash] ^ self.action.hash;
}
@end


@interface RunsTargetActionEngine ()
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableOrderedSet<RunsTargetActionWrap *> *> *targetActionMap;
@end

@implementation RunsTargetActionEngine

- (void)dealloc {
    RunsReleaseLog()
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(RunsControlEvents)controlEvents {
    NSNumber *key = @(controlEvents);
    if (!key) {
        return;
    }
    if (!_targetActionMap) {
        _targetActionMap = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    
    if (!_targetActionMap[key]) {
        _targetActionMap[key] = [NSMutableOrderedSet orderedSetWithCapacity:4];
    }
    RunsTargetActionWrap *wrap = [RunsTargetActionWrap wrapWithTarget:target action:action];
    if (!wrap) {
        return;
    }
    [_targetActionMap[key] addObject:wrap];
}

- (void)removeTarget:(nullable id)target action:(nullable SEL)action forControlEvents:(RunsControlEvents)controlEvents {
    NSNumber *key = @(controlEvents);
    NSMutableOrderedSet<RunsTargetActionWrap *> *wraps = _targetActionMap[key];
    if (wraps.count <= 0) return;
    [wraps enumerateObjectsUsingBlock:^(RunsTargetActionWrap * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hash == ([target hash] ^ [NSStringFromSelector(action) hash])) {
            [wraps removeObject:obj];
        }
    }];
    if (wraps.count <= 0) {
        [_targetActionMap removeObjectForKey:key];
    }
}

- (void)clear {
    [_targetActionMap removeAllObjects];
    _targetActionMap = nil;
}

- (void)runWithEvents:(RunsControlEvents)controlEvents {
    NSOrderedSet<RunsTargetActionWrap *> *wraps = _targetActionMap[@(controlEvents)];
    [wraps enumerateObjectsUsingBlock:^(RunsTargetActionWrap * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector = NSSelectorFromString(obj.action);
        if (![obj.target respondsToSelector:selector]) {
            return;
        }
        objc_msgSend(obj.target, selector);
    }];
}

- (void)runWithEvents:(RunsControlEvents)controlEvents parameter:(id)parameter {
    NSOrderedSet<RunsTargetActionWrap *> *wraps = _targetActionMap[@(controlEvents)];
    void (*objc_msgSendWrap)(id target, SEL sel, id model) = (void*)objc_msgSend;
    [wraps enumerateObjectsUsingBlock:^(RunsTargetActionWrap * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector = NSSelectorFromString(obj.action);
        if (![obj.target respondsToSelector:selector]) {
            return;
        }
        objc_msgSendWrap(obj.target, selector, parameter);
    }];
}

- (NSString *)generateKeyWithTarget:(id)target action:(SEL)action events:(RunsControlEvents)controlEvents {
    if (!target || !action) {
        return nil;
    }
    NSString *className = [NSString stringWithUTF8String:object_getClassName(target)];
    NSString *actionName = NSStringFromSelector(action);
    return [NSString stringWithFormat:@"%@_%@_%lu",className, actionName, (unsigned long)controlEvents];
}

@end
