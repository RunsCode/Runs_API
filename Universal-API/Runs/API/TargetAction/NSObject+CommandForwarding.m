//
//  NSObject+CommandForwarding.m
//  OU_iPhone
//
//  Created by runs on 2018/5/2.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "NSObject+CommandForwarding.h"
#import "RunsCommandForwardingEngine.h"
#import <objc/runtime.h>

@implementation NSObject (CommandForwarding)

- (id<RunsCommandForwardingEngineProtocol>)commandEngine {
    @synchronized(self) {
        id<RunsCommandForwardingEngineProtocol> engine = objc_getAssociatedObject(self, @selector(commandEngine));
        if (!engine) {
            engine = [[RunsCommandForwardingEngine alloc] init];
            [self setCommandEngine:engine];
        }
        return engine;
    }
}

- (void)setCommandEngine:(id<RunsCommandForwardingEngineProtocol>)commandEngine {
    objc_setAssociatedObject(self, @selector(commandEngine), commandEngine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)rs_releaseCommadnForwardingEngine {
    id<RunsCommandForwardingEngineProtocol> engine = objc_getAssociatedObject(self, @selector(commandEngine));
    if (!engine) return;
    objc_setAssociatedObject (self, @selector(commandEngine), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
