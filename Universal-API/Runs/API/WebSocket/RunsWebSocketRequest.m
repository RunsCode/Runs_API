//
//  RunsWebSocketRequest.m
//  OU_iPad
//
//  Created by runs on 2017/8/25.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsWebSocketRequest.h"

@implementation RunsWebSocketRequest

+ (instancetype)requestWithType:(NSInteger)code source:(NSString *)source dest:(NSString *)roomId data:(NSDictionary *)data {
    RunsWebSocketRequest *request = [RunsWebSocketRequest new];
    request.type = code;
    request.source = source;
    request.dest = roomId;
    request.data = data;
    return  request;
}

@end
