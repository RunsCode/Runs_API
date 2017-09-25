//
//  RunsWebSocketProxy.h
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunsWebSocketProtocol.h"

NS_ASSUME_NONNULL_BEGIN


@interface RunsWebSocketProxy : NSObject<RunsWebSocketProtocol>
@property (nonatomic, assign, readonly) BOOL isManuallyDisconnect;
@property (nonatomic, assign, readonly) BOOL isConnect;
@property (nonatomic, strong, readonly) NSURL *host;
@property (nonatomic, assign) NSUInteger reconnectMaxCount;
@property (nonatomic, weak) id<RunsWebSocketDelegate> delegate;

//SINGLETON_UNAVAILABLE_FUNCTION

+ (instancetype)sharedInstance;
+ (instancetype)socketWithDelegate:(id<RunsWebSocketDelegate>)delegate;
- (instancetype)initWithDelegate:(id<RunsWebSocketDelegate>)delegate;

@end
NS_ASSUME_NONNULL_END
