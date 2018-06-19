//
//  RunsCommandForwardingEngineProtocol.h
//  OU_iPhone
//
//  Created by runs on 2018/5/2.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
typedef void(^CommandExcuteBlock)(id _Nullable paramters);

@protocol RunsCommandForwardingEngineProtocol <NSObject>
/**
 注册命令 注册监听一些命令事件回调 一对多 不影响block
 参数之类的懒得解释 看不懂的说明不适合做iOS
 
 @param command 命令（比如Socket通讯消息号等）
 @param target target
 @param action action
 */
- (void)registerCommand:(id<NSCopying> _Nullable)command target:(id _Nullable) target action:(SEL _Nullable)action;

/**
 解注册命令 解注册监听一些命令事件回调
 
 @param command 命令
 @param target target
 @param action action
 */
- (void)unregisterCommand:(id<NSCopying> _Nullable)command target:(id _Nullable)target action:(SEL _Nullable)action;

/**
 上面两个 `registerCommand` `unregisterCommand` 语法糖而已 对id类型的分解
 会同时移除对应Block

 @param command 命令
 @param target target
 @param action action
 */
- (void)registerNumberCommand:(NSUInteger)command target:(id _Nullable)target action:(SEL _Nullable)action;
- (void)unregisterNumberCommand:(NSUInteger)command target:(id _Nullable)target action:(SEL _Nullable)action;

/**
 通过block的语法执行某个命令 一对一 block 与 target-action 互不影响

 @param command 命令
 @param blk block
 */
- (void)registerCommand:(id<NSCopying> _Nullable)command usingBlock:(CommandExcuteBlock)blk;
- (void)registerNumberCommand:(NSUInteger)command usingBlock:(CommandExcuteBlock)blk;

/**
 触发执行某个命令 无参数
 
 @param command 命令
 */
- (void)executeCommand:(id<NSCopying> _Nullable)command;

/**
 触发执行某个命令 有参数
 
 @param command 命令
 @param parameter 参数
 */
- (void)executeCommand:(id<NSCopying> _Nullable)command parameter:(id _Nullable)parameter;


/**
 触发执行某个命令  `executeCommand` `executeCommand:parameters` 语法糖而已 对id类型的分解
 
 @param command 命令
 */
- (void)executeNumberCommand:(NSUInteger)command;
- (void)executeNumberCommand:(NSUInteger)command parameter:(id _Nullable)parameter;


/**
 清空所有命令 释放内存
 */
- (void)clear;

@end
NS_ASSUME_NONNULL_END
