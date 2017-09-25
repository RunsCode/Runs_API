//
//  RunsHttpSessionProxy.m
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsHttpSessionProxy.h"
#import "RunsHttpSessionRespone.h"

@implementation RunsHttpSessionProxy

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    NSURL *url = [URLString composeURLWithKeyValue:parameters];
    [self.class printRequestLogWithURL:URLString new:url.absoluteString message:parameters];
    if (!url) {
        if (failure) {
            failure([NSError errorWithDomain:@"URL is Null" code:-1 userInfo:nil]);
        }
        return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 10.f;
    request.HTTPMethod = @"GET";
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [RunsHttpSessionProxy printResponeLogWithURL:url.absoluteString data:data];
        if (!data && error) {
            RunsLogEX(@"Http error : %@",error);
            [NSObject rs_safeMainThreadAsync:^{
                if (failure) failure(error);
            }];
            return;
        }
        RunsHttpSessionRespone *respone = [[RunsHttpSessionRespone alloc] initWithResponeData:data];
        if (!respone.success) {
            RunsLogEX(@"Http respone error : %@",respone.errorMessage);
            [NSObject rs_safeMainThreadAsync:^{
                if (failure) failure(respone.error);
            }];
            return;
        }
        [NSObject rs_safeMainThreadAsync:^{
            if (success) success(respone);
        }];
    }];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(SessionDataTaskSuccessCallback)success failure:(SessionDataTaskFailureCallback)failure {
    //
    [self.class printRequestLogWithURL:URLString new:URLString message:parameters];
    //
    NSURL *url = [NSURL URLWithString:URLString];
    if (!url) {
        if (failure) {
            failure([NSError errorWithDomain:@"URL is Null" code:-1 userInfo:nil]);
        }
        return nil;
    }
    
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
        return nil;
    }
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [RunsHttpSessionProxy printResponeLogWithURL:URLString data:data];
        if (!data && error) {
            RunsLogEX(@"Http error : %@",error);
            [NSObject rs_safeMainThreadAsync:^{
                if (failure) failure(error);
            }];
            return;
        }
        RunsHttpSessionRespone *respone = [[RunsHttpSessionRespone alloc] initWithResponeData:data];
        if (!respone.success) {
            RunsLogEX(@"Http respone error : %@",respone.errorMessage);
            [NSObject rs_safeMainThreadAsync:^{
                if (failure) failure(respone.error);
            }];
            return;
        }
        [NSObject rs_safeMainThreadAsync:^{
            if (success) success(respone);
        }];
    }];
    [task resume];
    return task;
}

+ (void)printRequestLogWithURL:(NSString *_Nonnull)URLString new:(NSString *)newURLString message:(NSDictionary *_Nonnull)parameters {
#ifdef DEBUG
    RunsLog(@"\n\n------------------------%@----------------------", URLString)
    printf("%s", [GKSimpleAPI objectConvertJson:parameters].UTF8String);
    printf("\n------------------------%s-----------------------\n\n", newURLString.UTF8String);
#else
#endif
}

+ (void)printResponeLogWithURL:(NSString *)URLString data:(NSData *)data {
#ifdef DEBUG
    RunsLog(@"\n\n------------------------%@----------------------", URLString)
    NSDictionary *json = [GKSimpleAPI dataConversionAdaption:data];
    printf("%s", [GKSimpleAPI objectConvertJson:json].UTF8String);
    printf("\n------------------------%s-----------------------\n\n", URLString.UTF8String);
#else
#endif
}

@end
