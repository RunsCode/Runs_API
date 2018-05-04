//
//  RunsHttpAssistant.h
//  OU_iPad
//
//  Created by runs on 2017/12/7.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RunsHttpSessionProtocol.h"

typedef NS_ENUM(NSUInteger, HttpMethodType) {
    HttpMethod_Get = 0,
    HttpMethod_Post = 1,
    HttpMethod_Upload = 2,
    HttpMethod_Download = 3,
    HttpMethod_Default = HttpMethod_Get,
};


@interface RunsHttpAssistant : NSObject
@property (nonatomic, assign) NSUInteger countOfRequest; // when init is 0
@property (nonatomic, assign) NSUInteger maxCountOfRequest; //default is 3
@property (nonatomic, assign) HttpMethodType method;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, strong) id parameters;
@property (nonatomic, strong) id data; //For upload
@property (nonatomic, strong) SessionDataTaskSuccessCallback success;
@property (nonatomic, strong) SessionDataTaskFailureCallback failure;

+ (instancetype)assistantWithURL:(NSString *)urlString
                          method:(HttpMethodType)method
                         success:(SessionDataTaskSuccessCallback)success
                          falure:(SessionDataTaskFailureCallback)failure;
+ (instancetype)assistantWithURL:(NSString *)urlString
                          method:(HttpMethodType)method
                      parameters:(id)parameters
                         success:(SessionDataTaskSuccessCallback)success
                          falure:(SessionDataTaskFailureCallback)failure;

- (BOOL)canRetryRequest;

@end
