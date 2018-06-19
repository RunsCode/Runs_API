//
//  RunsWebSocketDelegate.h
//  OU_iPad
//
//  Created by runs on 2017/8/3.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RunsWebSocketProtocol;

@protocol RunsWebSocketDelegate <NSObject>
@optional
- (void)socket:(id<RunsWebSocketProtocol>)socket didOpenWithHost:(NSURL *)host;

/**
 收到新消息回调

 @param socket socket实例
 @param message 消息结构图
 @return 返回值 返回YES 表示此消息是我的我处理了，你们不用管了（阻止消息下传），返回NO表示此消息我处理了或者不是我要的，给你们继续处理（传递消息）
 */
- (BOOL)socket:(id<RunsWebSocketProtocol>)socket didReceiveMessage:(id)message;
- (void)socket:(id<RunsWebSocketProtocol>)socket didFailWithError:(NSError *)error;
- (void)socket:(id<RunsWebSocketProtocol>)socket didCloseWithCode:(NSInteger)code reason:(NSString *)reason;
@end
