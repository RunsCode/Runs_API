//
//  NSOperationQueue+Category.m
//  OU_iPhone
//
//  Created by runs on 2018/5/23.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "NSOperationQueue+Category.h"

@implementation NSOperation (Category)

+ (void)load {
    Method originalAddMethod = class_getInstanceMethod(self, @selector(addDependency:));
    Method swizzledAddMethod = class_getInstanceMethod(self, @selector(rs_addDependency:));
    method_exchangeImplementations(originalAddMethod, swizzledAddMethod);
    Method originalRemoveMethod = class_getInstanceMethod(self, @selector(removeDependency:));
    Method swizzledRemoveMethod = class_getInstanceMethod(self, @selector(rs_removeDependency:));
    method_exchangeImplementations(originalRemoveMethod, swizzledRemoveMethod);
}

- (void)rs_addDependency:(NSOperation *)op {
    if (!op) return;
    [self rs_addDependency:op];
}

- (void)rs_removeDependency:(NSOperation *)op {
    if (!op) return;
    [self rs_removeDependency:op];
}
@end

@implementation NSOperationQueue (Category)

+ (void)load {
    Method originalAddMethod = class_getInstanceMethod(self, @selector(addOperation:));
    Method swizzledAddMethod = class_getInstanceMethod(self, @selector(rs_addOperation:));
    method_exchangeImplementations(originalAddMethod, swizzledAddMethod);
    Method originalAddBlockMethod = class_getInstanceMethod(self, @selector(addOperationWithBlock:));
    Method swizzledAddBlockMethod = class_getInstanceMethod(self, @selector(rs_addOperationWithBlock:));
    method_exchangeImplementations(originalAddBlockMethod, swizzledAddBlockMethod);
}

- (void)rs_addOperation:(NSOperation *)op {
    if (!op) return;
    [self rs_addOperation:op];
}

- (void)rs_addOperationWithBlock:(void (^)(void))block {
    if (!block) return;
    [self rs_addOperationWithBlock:block];
}

- (void)rs_addMutableOperation:(NSOperation *)firstObj, ... {
    if (firstObj) {
        va_list argsList;
        [self addOperation:firstObj];
        va_start(argsList, firstObj);
        id arg;
        while ((arg = va_arg(argsList, id))) {
            if ([arg isKindOfClass:NSOperation.class]) {
                [self addOperation:arg];
            }
        }
        va_end(argsList);
    }
}

- (NSOperationQueue * (^)(NSOperation *op))add {
    return ^ (NSOperation *op) {
        [self addOperation:op];
        return self;
    };
}

@end
