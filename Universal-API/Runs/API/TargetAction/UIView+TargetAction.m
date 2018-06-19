//
//  UIView+TargetAction.m
//  OU_iPhone
//
//  Created by runs on 2018/5/28.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "UIView+TargetAction.h"
#import "RunsTargetActionEngine.h"
#import <objc/runtime.h>

@implementation UIView (TargetAction)


- (id<RunsTargetActionEngineProtocol>)targetactionEngine {
    @synchronized(self) {
        id<RunsTargetActionEngineProtocol> engine = objc_getAssociatedObject(self, @selector(targetactionEngine));
        if (!engine) {
            engine = [[RunsTargetActionEngine alloc] init];
            [self setTargetactionEngine:engine];
        }
        return engine;
    }
}

- (void)setTargetactionEngine:(id<RunsTargetActionEngineProtocol>)targetactionEngine {
    objc_setAssociatedObject(self, @selector(targetactionEngine), targetactionEngine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)rs_releaseTargetactionEngine {
    id<RunsTargetActionEngineProtocol> engine = objc_getAssociatedObject(self, @selector(targetactionEngine));
    if (!engine) return;
    objc_setAssociatedObject (self, @selector(targetactionEngine), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(RunsControlEvents)controlEvents {
    [self.targetactionEngine addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(nullable id)target action:(nullable SEL)action forControlEvents:(RunsControlEvents)controlEvents {
    [self.targetactionEngine removeTarget:target action:action forControlEvents:controlEvents];
}

- (void)clear {
    [self.targetactionEngine clear];
}

- (void)runWithEvents:(RunsControlEvents)controlEvents {
    [self.targetactionEngine runWithEvents:controlEvents];
}

- (void)runWithEvents:(RunsControlEvents)controlEvents parameter:(id)parameter {
    [self.targetactionEngine runWithEvents:controlEvents parameter:parameter];
}

@end
