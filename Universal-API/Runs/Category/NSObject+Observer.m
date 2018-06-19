//
//  NSObject+Observer.m
//  OU_iPhone
//
//  Created by runs on 2018/5/29.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "NSObject+Observer.h"
#import <objc/runtime.h>
#import "RunsMacroConstant.h"

@implementation NSObject (Observer)

+ (void)load {
    Method originalAddMethod = class_getInstanceMethod(self, @selector(addObserver:forKeyPath:options:context:));
    Method swizzledAddMethod = class_getInstanceMethod(self, @selector(rs_addObserver:forKeyPath:options:context:));
    method_exchangeImplementations(originalAddMethod, swizzledAddMethod);
    Method originalRemoveMethod = class_getInstanceMethod(self, @selector(removeObserver:forKeyPath:context:));
    Method swizzledRemoveMethod = class_getInstanceMethod(self, @selector(rs_removeObserver:forKeyPath:context:));
    method_exchangeImplementations(originalRemoveMethod, swizzledRemoveMethod);
}

- (void)rs_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    
    NSString *className = NSStringFromClass(self.class);
    if (![className hasPrefix:@"OU"]) {
        [self rs_addObserver:observer forKeyPath:keyPath options:options context:context];
        return;
    }
    if ([self isContainKeyPath:keyPath]) return;
    [self rs_addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)rs_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    
    NSString *className = NSStringFromClass(self.class);
    if (![className hasPrefix:@"OU"]) {
        [self rs_removeObserver:observer forKeyPath:keyPath context:context];
        return;
    }
    @try {
        if (![self isContainKeyPath:keyPath]) return;
        [self rs_removeObserver:observer forKeyPath:keyPath context:context];
    } @catch(NSException *exception) {
        RunsLogEX(@"移除 KVO 观察者 异常 key : %@, exception : %@", keyPath, exception)
    }
}

- (BOOL)isContainKeyPath:(NSString *)keyPath {
    id info = self.observationInfo;
    NSArray *array = [info valueForKey:@"_observances"];
    __block BOOL isContain = NO;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id properties = [obj valueForKeyPath:@"_property"];
        NSString *key = [properties valueForKeyPath:@"_keyPath"];
        if ([key isEqualToString:keyPath]) {
            isContain = YES;
            *stop = YES;
        }
    }];
    return isContain;
}

@end
