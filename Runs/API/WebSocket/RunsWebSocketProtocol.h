//
//  RunsWebSocketProtocol.h
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SocketCallback)(NSDictionary *messsage);

@protocol RunsWebSocketDelegate;

@protocol RunsWebSocketProtocol <NSObject>
@property (nonatomic, assign, readonly) BOOL isManuallyDisconnect;
@property (nonatomic, assign, readonly) BOOL isConnect;
@property (nonatomic, strong, readonly) NSURL *host;
@property (nonatomic, assign) NSUInteger reconnectMaxCount; //default is WEBSOCKET_RECONNECT_COUN
@property (nonatomic, weak) id<RunsWebSocketDelegate> delegate;

- (void)connectWithURL:(NSURL *)URL;
- (void)reconnect;
- (void)closeWithManually:(BOOL)isManually;
//
- (void)sendMap:(NSDictionary *)parameters;
- (void)sendJson:(NSString *)message;
//
- (void)registeredListenWithType:(NSInteger)type callback:(SocketCallback)callback;
- (void)removeListenWithType:(NSInteger)type;

@end
