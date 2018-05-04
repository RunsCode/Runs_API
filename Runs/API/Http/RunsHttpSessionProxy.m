//
//  RunsHttpSessionProxy.m
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsHttpSessionProxy.h"
#import "RunsHttpSessionResponse.h"

@interface RunsHttpSessionProxy ()
#if DEBUG
@property  (nonatomic, strong)NSOperationQueue *operationQueue;
#endif
@end

@implementation RunsHttpSessionProxy

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (NSURL *)checkURL:(NSString *)URLString parameters:(NSDictionary *)parameters method:(HttpMethodType)method failure:(SessionDataTaskFailureCallback)failure {
    if (![RunsNetworkMonitor NetworkIsReachableWithShowTips:YES]) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"URL is Null" code:-1 userInfo:nil];
            [RunsHttpSessionProxy showToast:error.domain];
            failure(error);
        }
        return nil;
    }

    if (HttpMethod_Get == method) {
        NSURL *url = [URLString composeURLWithKeyValue:parameters];
        [self.class printRequestLogWithURL:URLString new:url.absoluteString message:parameters];
        //
        if (!url) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:@"URL is Null" code:-1 userInfo:nil];
                [RunsHttpSessionProxy showToast:error.domain];
                failure(error);
            }
        }
        return url;
    }else if (HttpMethod_Post == method || HttpMethod_Download == method) {
        NSURL *url = [NSURL URLWithString:URLString];
        [self.class printRequestLogWithURL:URLString new:URLString message:parameters];
        //
        if (!url) {
            if (failure) {
                NSError *error = [NSError errorWithDomain:@"URL is Null" code:-1 userInfo:nil];
                [RunsHttpSessionProxy showToast:error.domain];
                failure(error);
            }
        }
        return url;
    }
    return nil;
}


- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    
    if (!RunsNetworkMonitor.isReachable) {
        NSError *error = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
        RunsLogEX(@"%@",error.domain)
        if (failure) {
            failure(error);
        }
        return nil;
    }
    
    NSURL *url = [self checkURL:URLString parameters:parameters method:HttpMethod_Get failure:failure];
    if (!url) return nil;
    if (!URLString.httpAssistant) {
        URLString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Get parameters:parameters success:success falure:failure];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 10.f;
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [RunsHttpSessionProxy printResponeLogWithURL:url.absoluteString data:data];
        if (!data || error) {
            BOOL can = [URLString.httpAssistant canRetryRequest];
            if (can) return ;
            RunsLogEX(@"Http error : %@",error);
            [RunsHttpSessionProxy showToast:error.domain];
            [NSObject rs_safeMainThreadAsync:^{
                NSError *err = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
                if (failure) failure(err);
            }];
            return;
        }
        RunsHttpSessionResponse *respone = [[RunsHttpSessionResponse alloc] initWithResponseData:data];
        if (!respone.success) {
            RunsLogEX(@"Http respone error : %@",respone.errorMessage);
            [RunsHttpSessionProxy showToast:respone.errorMessage];
            [NSObject rs_safeMainThreadAsync:^{
                if (success) success(respone);
            }];
            return;
        }
        [NSObject rs_safeMainThreadAsync:^{
            if (success) success(respone);
        }];
        //
        [URLString rs_relaseAssisant];
    }];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    
    if (!RunsNetworkMonitor.isReachable) {
        NSError *error = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
        RunsLogEX(@"%@",error.domain)
        if (failure) {
            failure(error);
        }
        return nil;
    }
    NSURL *url = [self checkURL:URLString parameters:parameters method:HttpMethod_Get failure:failure];
    if (!url) return nil;

    NSMutableData *data = [NSMutableData data];
    [parameters.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = [NSString stringWithFormat:@"&%@=%@",obj, parameters[obj]];
        [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    request.timeoutInterval = 10.f;
    request.HTTPMethod = @"POST";
    NSError *encodeError = nil;
    request.HTTPBody = data;
    if (encodeError && failure) {
        failure(encodeError);
        [RunsHttpSessionProxy showToast:encodeError.domain];
        return nil;
    }
    if (!URLString.httpAssistant) {
        URLString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Post parameters:parameters success:success falure:failure];
    }

    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [RunsHttpSessionProxy printResponeLogWithURL:URLString data:data];
        if (!data || error) {
            BOOL can = [URLString.httpAssistant canRetryRequest];
            if (can) return ;
            RunsLogEX(@"Http error : %@",error);
            [RunsHttpSessionProxy showToast:error.domain];
            [NSObject rs_safeMainThreadAsync:^{
                NSError *err = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
                if (failure) failure(err);
            }];
            return;
        }
        RunsHttpSessionResponse *respone = [[RunsHttpSessionResponse alloc] initWithResponseData:data];
        if (!respone.success) {
            RunsLogEX(@"Http respone error : %@",respone.errorMessage);
            [RunsHttpSessionProxy showToast:respone.errorMessage];
            [NSObject rs_safeMainThreadAsync:^{
                if (success) success(respone);
            }];
            return;
        }
        [NSObject rs_safeMainThreadAsync:^{
            if (success) success(respone);
        }];
        //
        [URLString rs_relaseAssisant];
    }];
    [task resume];
    return task;
}

- (NSURLSessionDownloadTask *)DOWNLOAD:(NSString *)URLString success:(SessionDataTaskSuccessCallback)success faillure:(SessionDataTaskFailureCallback)failure {
    
    if (!RunsNetworkMonitor.isReachable) {
        NSError *error = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
        RunsLogEX(@"%@",error.domain)
        if (failure) {
            failure(error);
        }
        return nil;
    }
    
    NSURL *url = [self checkURL:URLString parameters:nil method:HttpMethod_Download failure:failure];
    if (!url) return nil;

    if (!URLString.httpAssistant) {
        URLString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Download success:success falure:failure];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    NSURLSessionDownloadTask *task = [NSURLSession.sharedSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                BOOL can = [URLString.httpAssistant canRetryRequest];
                if (can) return ;
                [NSObject rs_safeMainThreadAsync:^{
                    failure(error);
                }];
            }
            [NSObject rs_safeMainThreadAsync:^{
                RunsLogEX(@"下载失败 URL: %@, Error: %@", URLString, error)
                [RunsHttpSessionProxy showToast:error.domain];
            }];
            return ;
        }
        if (success) {
            RunsLogEX(@"下载成功 URL: %@", URLString)
            RunsHttpSessionResponse *sessionRespone = [RunsHttpSessionResponse new];
            sessionRespone.data = location;
            success(sessionRespone);
            //
            [URLString rs_relaseAssisant];
        }
    }];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    if (!RunsNetworkMonitor.isReachable) {
        NSError *error = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
        RunsLogEX(@"%@",error.domain)
        if (failure) {
            failure(error);
        }
        return nil;
    }
    
    NSURL *url = [self checkURL:URLString parameters:nil method:HttpMethod_Download failure:failure];
    if (!url) return nil;
    
    if (!URLString.httpAssistant) {
        URLString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Download success:success falure:failure];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 10.f;
    request.HTTPMethod = @"HEAD";

    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [RunsHttpSessionProxy printResponeLogWithURL:url.absoluteString data:data];
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        [RunsHttpSessionProxy printRequestLogWithURL:url.absoluteString new:@"" message:res.allHeaderFields];
        
        if (!res || error) {
            BOOL can = [URLString.httpAssistant canRetryRequest];
            if (can) return ;
            RunsLogEX(@"Http error : %@",error);
            [RunsHttpSessionProxy showToast:error.domain];
            [NSObject rs_safeMainThreadAsync:^{
                NSError *err = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
                if (failure) failure(err);
            }];
            return;
        }
        RunsHttpSessionResponse *respone = [[RunsHttpSessionResponse alloc] initWithResponseData:res.allHeaderFields];
        [NSObject rs_safeMainThreadAsync:^{
            if (success) success(respone);
        }];
        //
        [URLString rs_relaseAssisant];
    }];
    [task resume];
    return task;
}

+ (void)printRequestLogWithURL:(NSString *_Nonnull)URLString new:(NSString *)newURLString message:(NSDictionary *_Nonnull)parameters {
#ifdef DEBUG
    [RunsHttpSessionProxy.sharedInstance.operationQueue addOperationWithBlock:^{
        RunsLogEX(@"\n\n------------------------%@----------------------", URLString)
        printf("%s", [GKSimpleAPI objectConvertJson:parameters].UTF8String);
        printf("\n------------------------%s-----------------------\n\n", newURLString.UTF8String);
    }];
#endif
}

+ (void)printResponeLogWithURL:(NSString *)URLString data:(NSData *)data {
#ifdef DEBUG
    [RunsHttpSessionProxy.sharedInstance.operationQueue addOperationWithBlock:^{
        RunsLogEX(@"\n\n------------------------%@----------------------", URLString)
        NSDictionary *json = [GKSimpleAPI dataConversionAdaption:data];
        printf("%s", [GKSimpleAPI objectConvertJson:json].UTF8String);
        printf("\n------------------------%s-----------------------\n\n", URLString.UTF8String);
    }];
#endif
}

+ (void)showToast:(NSString *)message {
#ifdef DEBUG
    [NSObject rs_safeMainThreadAsync:^{
        [UIApplication.sharedApplication.keyWindow makeToast:message duration:1.f position:CSToastPositionBottom];
    }];
#else
#endif
}

#if DEBUG
- (NSOperationQueue *)operationQueue {
    if (_operationQueue) {
        return _operationQueue;
    }
    _operationQueue = [[NSOperationQueue alloc] init];
    return _operationQueue;
}
#endif

@end

