//
//  RunsWebSocketRequest.h
//  OU_iPad
//
//  Created by runs on 2017/8/25.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunsWebSocketRequest : NSObject
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *dest;
@property (nonatomic, strong) NSDictionary *data;

/**
 发送音视频相关消息到服务器
 
 @param code 消息类型
 @param source 发送者uid
 @param dest 目的地 这里为roomId
 @param data 参数
 @return 实例
 */
+ (instancetype)requestWithType:(NSInteger)code source:(NSString *)source dest:(NSString *)roomId data:(NSDictionary *)data;

@end
