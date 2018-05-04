//
//  RunsHttpAssistant.m
//  OU_iPad
//
//  Created by runs on 2017/12/7.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsHttpAssistant.h"

#define DEFAULT_RETRY_COUNT (3)

@implementation RunsHttpAssistant

+ (instancetype)assistantWithURL:(NSString *)urlString method:(HttpMethodType)method success:(SessionDataTaskSuccessCallback)success falure:(SessionDataTaskFailureCallback)failure {
    RunsHttpAssistant *assisant = [RunsHttpAssistant.alloc initWithURL:urlString method:method parameters:nil success:success falure:failure];
    return assisant;
}

+ (instancetype)assistantWithURL:(NSString *)urlString method:(HttpMethodType)method parameters:(id)parameters success:(SessionDataTaskSuccessCallback)success falure:(SessionDataTaskFailureCallback)failure {
    RunsHttpAssistant *assisant = [RunsHttpAssistant.alloc initWithURL:urlString method:method parameters:parameters success:success falure:failure];
    return assisant;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _countOfRequest     = 1;
        _maxCountOfRequest  = DEFAULT_RETRY_COUNT;
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)urlString method:(HttpMethodType)method parameters:(id)parameters success:(SessionDataTaskSuccessCallback)success falure:(SessionDataTaskFailureCallback)failure {
    self = [super init];
    if (self) {
        _urlString          = urlString;
        _method             = method;
        _parameters         = parameters;
        _countOfRequest     = 0;
        _success            = success;
        _failure            = failure;
        _maxCountOfRequest  = DEFAULT_RETRY_COUNT;
    }
    return self;
}

- (BOOL)canRetryRequest {
    if (_countOfRequest >= _maxCountOfRequest) {
        return NO;
    }
    _countOfRequest++;
    RunsLog(@"Http 请求失败 第%lu次重试", (unsigned long)_countOfRequest)

    switch (_method) {
        case HttpMethod_Get:
            [RunsHttpSessionProxy.sharedInstance GET:_urlString parameters:_parameters success:_success failure:_failure];
            break;
        case HttpMethod_Post:
            [RunsHttpSessionProxy.sharedInstance POST:_urlString parameters:_parameters success:_success failure:_failure];
            break;
        case HttpMethod_Upload:
            [RunsHttpSessionProxy.sharedInstance UPLOAD:_urlString parameters:_parameters data:_data success:_success failure:_failure];
            break;
        case HttpMethod_Download:
            [RunsHttpSessionProxy.sharedInstance DOWNLOAD:_urlString success:_success faillure:_failure];
            break;

        default:
            break;
    }
    return YES;
}


@end
