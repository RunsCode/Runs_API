//
//  RunsCommandForwardingEngine.m
//  OU_iPhone
//
//  Created by runs on 2018/5/2.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "RunsCommandForwardingEngine.h"
#import "RunsMacroConstant.h"
#import <objc/message.h>

@interface CommandBundle : NSObject<NSCopying>
@property (nonatomic, weak) id cmd;
@property (nonatomic, weak) id target;
@end


@implementation CommandBundle {
    @public
        SEL action;
}

- (void)dealloc {
    RunsReleaseLog()
}

+ (instancetype)wrapWithCommand:(nullable id)cmd target:(nullable id)target action:(nullable SEL)action {
    if (!cmd || !target || !action) {
        return nil;
    }
    CommandBundle *command = [[CommandBundle alloc] init];
    command.cmd = cmd;
    command.target = target;
    command->action = action;
    return command;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    CommandBundle *bundle = [[[self class] allocWithZone:zone] init];
    bundle.cmd = self.cmd;
    bundle.target = self.target;
    bundle->action = self->action;
    return bundle;
}

- (NSUInteger)hash {
    return [CommandBundle hashWithCommand:self.cmd target:_target action:action];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:CommandBundle.class]) {
        return NO;
    }
    CommandBundle *obj = (CommandBundle *)object;
    return obj.cmd == self.cmd && obj.target == self.target && obj->action == self->action;
}

+ (NSUInteger)hashWithCommand:(id)command target:(id)target action:(SEL)action {
    return ([command hash] << 8) ^ [target hash] ^ [NSStringFromSelector(action) hash];
}
@end

@interface RunsCommandForwardingEngine()
@property(nonatomic, strong) NSMutableDictionary<id, NSMutableOrderedSet<CommandBundle *> *> *commandMap;
@property(nonatomic, strong) NSMutableDictionary<id, NSMutableOrderedSet<CommandExcuteBlock> *> *commandBlockMap;
@end

@implementation RunsCommandForwardingEngine

- (void)dealloc {
    RunsReleaseLog()
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)clear {
    if (_commandMap) {
        [_commandMap removeAllObjects];
        _commandMap = nil;
    }
    
    if (_commandBlockMap) {
        [_commandBlockMap removeAllObjects];
        _commandBlockMap = nil;
    }
}

- (void)executeCommand:(id<NSCopying>)command {
    [self executeBlockCommand:command parameter:nil];
    //
    NSMutableOrderedSet<CommandBundle *> *commandBundles = _commandMap[command];
    if (commandBundles.count <= 0) return;
    [commandBundles enumerateObjectsUsingBlock:^(CommandBundle * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector = obj->action;
        if (![obj.target respondsToSelector:selector]) {
            return;
        }
        objc_msgSend(obj.target, selector);
    }];
}

- (void)executeCommand:(id<NSCopying>)command parameter:(id)parameter {
    [self executeBlockCommand:command parameter:parameter];
    //
    NSMutableOrderedSet<CommandBundle *> *commandBundles = _commandMap[command];
    if (commandBundles.count <= 0) return;
    void (*objc_msgSendCommand)(id target, SEL sel, id model) = (void*)objc_msgSend;
    [commandBundles enumerateObjectsUsingBlock:^(CommandBundle * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SEL selector = obj->action;
        if (![obj.target respondsToSelector:selector]) {
            return;
        }
        objc_msgSendCommand(obj.target, selector, parameter);
    }];
}

- (void)registerCommand:(id<NSCopying>)command target:(id)target action:(SEL)action {
    CommandBundle *commandBundle = [CommandBundle wrapWithCommand:command target:target action:action];
    if (!commandBundle) return;
    if (!_commandMap) {
        _commandMap = [[NSMutableDictionary alloc] initWithCapacity:8];
    }
    if (!_commandMap[command]) {
        _commandMap[command] = [NSMutableOrderedSet orderedSet];
    }
    [_commandMap[command] addObject:commandBundle];
}

- (void)unregisterCommand:(id<NSCopying>)command target:(id)target action:(SEL)action {
    [self unregisterBlockCommand:command];
    NSMutableOrderedSet<CommandBundle *> *commandBundles = _commandMap[command];
    if (!commandBundles) return;
    NSUInteger hashCode = [CommandBundle hashWithCommand:command target:target action:action];
    [commandBundles enumerateObjectsUsingBlock:^(CommandBundle * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.hash == hashCode) {
            [commandBundles removeObject:obj];
            *stop = YES;
        }
    }];
}

- (void)executeNumberCommand:(NSUInteger)command {
    [self executeCommand:@(command)];
}

- (void)executeNumberCommand:(NSUInteger)command parameter:(id)parameter {
    [self executeCommand:@(command) parameter:parameter];
}

- (void)registerNumberCommand:(NSUInteger)command target:(id)target action:(SEL)action {
    [self registerCommand:@(command) target:target action:action];
}

- (void)unregisterNumberCommand:(NSUInteger)command target:(id)target action:(SEL)action {
    [self unregisterCommand:@(command) target:target action:action];
}

- (void)registerCommand:(id<NSCopying> _Nullable)command usingBlock:(nonnull CommandExcuteBlock)blk {
    if (!command && !blk) return;
    if (!_commandBlockMap) {
        _commandBlockMap = [[NSMutableDictionary alloc] init];
    }
    if (!_commandBlockMap[command]) {
        _commandBlockMap[command] = [NSMutableOrderedSet orderedSet];
    }
    [_commandBlockMap[command] addObject:blk];
}

- (void)registerNumberCommand:(NSUInteger)command usingBlock:(CommandExcuteBlock)blk {
    [self registerCommand:@(command) usingBlock:blk];
}

- (void)executeBlockCommand:(id<NSCopying>)command parameter:(id)parameter {
    NSOrderedSet<CommandExcuteBlock> *blks = _commandBlockMap[command];
    if (blks.count <= 0) return;
    [blks enumerateObjectsUsingBlock:^(CommandExcuteBlock  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj(parameter);
    }];
}

- (void)unregisterBlockCommand:(id<NSCopying>)command {
    [_commandBlockMap removeObjectForKey:command];
}

@end











