//
//  RunsHttpSessionProxy.m
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsHttpSessionProxy.h"
#import "RunsHttpSessionResponse.h"
#import "RunsHttpAssistant.h"
#import "RunsNetworkMonitor.h"
#import "NSString+Assistant.h"
#import "RunsMacroConstant.h"
#import "NSObject+RuntimeLog.h"
#import "GKSimpleAPI.h"
#import "UIView+Toast.h"
#import "NSString+NSURL_FOR_HTTP.h"
#import "NSOperationQueue+Category.h"

typedef void(^URLSessionCompletionHandler)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);

@interface RunsHttpSessionProxy ()
#if DEBUG
@property  (nonatomic, strong)NSOperationQueue *operationQueue;
#endif
@end

@implementation RunsHttpSessionProxy

- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    return [self GET:URLString parameters:parameters queue:NSOperationQueue.mainQueue success:success failure:failure];
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString json:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    return [self POST:URLString json:parameters queue:NSOperationQueue.mainQueue success:success failure:failure];;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    return [self POST:URLString parameters:parameters queue:NSOperationQueue.mainQueue success:success failure:failure];
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters queue:(NSOperationQueue *)operationQueue success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    operationQueue = operationQueue == nil ? [NSOperationQueue mainQueue] : operationQueue;
    
    if (!RunsNetworkMonitor.isReachable) {
        [operationQueue addOperationWithBlock:^{
            NSError *error = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据 " code:-1 userInfo:nil];
            RunsLogEX(@"%@",error.domain)
            if (failure) failure(error);
        }];
        return nil;
    }
    
    NSURL *url = [self checkURL:URLString parameters:parameters method:HttpMethod_Get failure:failure];
    if (!url) return nil;
    if (!url.absoluteString.httpAssistant) {
        url.absoluteString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Get parameters:parameters success:success falure:failure];
    }
    
    NSURLRequest *request = [self requsetWithMethod:HttpMethod_Get url:url body:nil];
    URLSessionCompletionHandler handler = [self handlerWithURLString:url.absoluteString queue:operationQueue success:success failure:failure];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:handler];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString json:(NSDictionary *)parameters queue:(NSOperationQueue *)operationQueue success:(SessionDataTaskSuccessCallback)success failure:( SessionDataTaskFailureCallback)failure {
    operationQueue = operationQueue == nil ? [NSOperationQueue mainQueue] : operationQueue;
    if (!RunsNetworkMonitor.isReachable) {
        [operationQueue addOperationWithBlock:^{
            NSError *error = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
            RunsLogEX(@"%@",error.domain)
            if (failure) {
                failure(error);
            }
        }];
        return nil;
    }
    NSURL *url = [self checkURL:URLString parameters:parameters method:HttpMethod_Post_Json failure:failure];
    if (!url) return nil;
    
    NSMutableURLRequest *request = [self requsetWithMethod:HttpMethod_Post_Json url:url body:nil];
    [request setAllHTTPHeaderFields:@{ @"content-type": @"application/json",
                                       @"cache-control": @"no-cache" }];
    NSError *encodeError = nil;
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:nil];
    if (encodeError && failure) {
        [RunsHttpSessionProxy showToast:encodeError.domain];
        [operationQueue addOperationWithBlock:^{
            RunsLogEX(@"参数序列化错误 %@",encodeError.domain)
            if (failure) {
                failure(encodeError);
            }
        }];
        return nil;
    }
    if (!url.absoluteString.httpAssistant) {
        url.absoluteString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Post_Json parameters:parameters success:success falure:failure];
    }
    URLSessionCompletionHandler handler = [self handlerWithURLString:url.absoluteString queue:operationQueue success:success failure:failure];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:handler];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters queue:(NSOperationQueue *)operationQueue success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    operationQueue = operationQueue == nil ? [NSOperationQueue mainQueue] : operationQueue;
    if (!RunsNetworkMonitor.isReachable) {
        [operationQueue addOperationWithBlock:^{
            NSError *error = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
            RunsLogEX(@"%@",error.domain)
            if (failure) failure(error);
        }];
        return nil;
    }
    NSURL *url = [self checkURL:URLString parameters:parameters method:HttpMethod_Post failure:failure];
    if (!url) return nil;
    
    NSMutableData *data = [NSMutableData data];
    [parameters.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *str = [NSString stringWithFormat:@"&%@=%@",obj, parameters[obj]];
        [data appendData:[str dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    NSMutableURLRequest *request = [self requsetWithMethod:HttpMethod_Post url:url body:data];
    if (!url.absoluteString.httpAssistant) {
        url.absoluteString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Post parameters:parameters success:success falure:failure];
    }
    URLSessionCompletionHandler handler = [self handlerWithURLString:url.absoluteString queue:operationQueue success:success failure:failure];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:handler];
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

    if (!url.absoluteString.httpAssistant) {
        url.absoluteString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Download success:success falure:failure];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    NSURLSessionDownloadTask *task = [NSURLSession.sharedSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                BOOL can = [URLString.httpAssistant canRetryRequest];
                if (can) return ;
                [NSOperationQueue rs_safeMainThreadAsync:^{
                    failure(error);
                }];
            }
            [NSOperationQueue rs_safeMainThreadAsync:^{
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
            [url.absoluteString rs_relaseAssisant];
        }
    }];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)HEAD:(NSString *)URLString parameters:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    NSOperationQueue *operationQueue = [NSOperationQueue currentQueue];
    if (!RunsNetworkMonitor.isReachable) {
        [operationQueue addOperationWithBlock:^{
            NSError *error = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
            RunsLogEX(@"%@",error.domain)
            if (failure)  failure(error);
        }];
        return nil;
    }
    
    NSURL *url = [self checkURL:URLString parameters:nil method:HttpMethod_Head failure:failure];
    if (!url) return nil;
    
    if (!url.absoluteString.httpAssistant) {
        url.absoluteString.httpAssistant = [RunsHttpAssistant assistantWithURL:URLString method:HttpMethod_Head success:success falure:failure];
    }
    NSMutableURLRequest *request = [self requsetWithMethod:HttpMethod_Head url:url body:nil];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [RunsHttpSessionProxy printResponseLogWithURL:url.absoluteString data:data];
        NSHTTPURLResponse *res = (NSHTTPURLResponse *)response;
        [RunsHttpSessionProxy printRequestLogWithURL:url.absoluteString new:@"" message:res.allHeaderFields];
        
        if (!res || error) {
            BOOL can = [URLString.httpAssistant canRetryRequest];
            if (can) return ;
            RunsLogEX(@"Http error : %@",error);
            [RunsHttpSessionProxy showToast:error.domain];
            [operationQueue addOperationWithBlock:^{
                NSError *err = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
                if (failure) failure(err);
            }];
            return;
        }
        RunsHttpSessionResponse *respone = [[RunsHttpSessionResponse alloc] initWithResponseData:res.allHeaderFields];
        [operationQueue addOperationWithBlock:^{
            if (success) success(respone);
        }];
        //
        [url.absoluteString rs_relaseAssisant];
    }];
    [task resume];
    return task;
}

- (URLSessionCompletionHandler)handlerWithURLString:(NSString *)URLString queue:(NSOperationQueue *)operationQueue success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    return ^(NSData *data, NSURLResponse *response, NSError *error) {
        [RunsHttpSessionProxy printResponseLogWithURL:URLString data:data];
        if (!data || error) {
            BOOL can = [URLString.httpAssistant canRetryRequest];
            if (can) return ;
            RunsLogEX(@"Http error : %@",error);
            [RunsHttpSessionProxy showToast:error.domain];
            [operationQueue addOperationWithBlock:^{
                NSError *err = [NSError errorWithDomain:@"无网络连接或者未允许使用网络数据" code:-1 userInfo:nil];
                if (failure) failure(err);
            }];
            return;
        }
        RunsHttpSessionResponse *respone = [[RunsHttpSessionResponse alloc] initWithResponseData:data];
        if (!respone.success) {
            RunsLogEX(@"Http respone error : %@",respone.errorMessage);
            [RunsHttpSessionProxy showToast:respone.errorMessage];
        }
        [operationQueue addOperationWithBlock:^{
            if (success) success(respone);
        }];
        [URLString rs_relaseAssisant];
    };
}

- (NSMutableURLRequest *)requsetWithMethod:(HttpMethodType)method url:(NSURL * _Nonnull)url body:(id _Nullable )body {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.f];
    request.timeoutInterval = 10.f;
    request.HTTPMethod = @"POST";
    
    if (HttpMethod_Post == method || HttpMethod_Post_Json == method) {
        request.HTTPMethod = @"POST";
    } else if (HttpMethod_Get == method) {
        request.HTTPMethod = @"GET";
    } else if (HttpMethod_Head == method) {
        request.HTTPMethod = @"HEAD";
    }
    if (body) {
        request.HTTPBody = body;
    }
    return request;
}

- (NSURL *)checkURL:(NSString *)URLString parameters:(NSDictionary *)parameters method:(HttpMethodType)method failure:(SessionDataTaskFailureCallback)failure {
    if (![RunsNetworkMonitor NetworkIsReachableWithShowTips:YES]) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"网络不可达" code:-1 userInfo:nil];
            [RunsHttpSessionProxy showToast:error.domain];
            failure(error);
        }
        return nil;
    }
    
    NSURL *url = nil;
    if (HttpMethod_Get == method || HttpMethod_Head == method) {
        url = [URLString composeURLWithKeyValue:parameters];
        [self.class printRequestLogWithURL:URLString new:url.absoluteString message:parameters];
    }else if (HttpMethod_Post == method || HttpMethod_Post_Json == method || HttpMethod_Download == method) {
        url = [NSURL URLWithString:URLString];
        [self.class printRequestLogWithURL:URLString new:URLString message:parameters];
    }
    //
    if (url) return url;
    if (failure) {
        NSError *error = [NSError errorWithDomain:@"URL is Null" code:-1 userInfo:nil];
        [RunsHttpSessionProxy showToast:error.domain];
        failure(error);
    }
    return url;
}


+ (void)printRequestLogWithURL:(NSString *_Nonnull)URLString new:(NSString *)newURLString message:(NSDictionary *_Nonnull)parameters {
#ifdef DEBUG
    [RunsHttpSessionProxy.sharedInstance.operationQueue addOperationWithBlock:^{
        RunsLogEX(@"\n\n------------------------%@---------------------- Request", URLString)
        printf("%s", [GKSimpleAPI objectConvertJson:parameters].UTF8String);
        printf("\n------------------------%s----------------------- Request\n\n", newURLString.UTF8String);
    }];
#endif
}

+ (void)printResponseLogWithURL:(NSString *)URLString data:(NSData *)data {
#ifdef DEBUG
    [RunsHttpSessionProxy.sharedInstance.operationQueue addOperationWithBlock:^{
        RunsLogEX(@"\n\n------------------------%@---------------------- Response", URLString)
        NSDictionary *json = [GKSimpleAPI dataConversionAdaption:data];
        printf("%s", [GKSimpleAPI objectConvertJson:json].UTF8String);
        printf("\n------------------------%s----------------------- Response\n\n", URLString.UTF8String);
    }];
#endif
}

+ (void)showToast:(NSString *)message {
#ifdef DEBUG
    [NSOperationQueue rs_safeMainThreadAsync:^{
        [UIApplication.sharedApplication.keyWindow makeToast:message duration:1.f position:CSToastPositionBottom];
    }];
#endif
}

#ifdef DEBUG

- (NSOperationQueue *)operationQueue {
    if (_operationQueue) return _operationQueue;
    _operationQueue = [[NSOperationQueue alloc] init];
    return _operationQueue;
}
#endif

@end

