//
//  RunsHttpSessionProtocol.h
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RunsHttpSessionRespone;
typedef void(^SessionDataTaskSuccessCallback)(RunsHttpSessionRespone *responseObject);
typedef void(^SessionDataTaskFailureCallback)(NSError *error);

@protocol RunsHttpSessionProtocol <NSObject>

/**
 普通 GET 请求
 
 @param URLString 完整的URL
 @param parameters 请求参数 比如字典
 @param success 成功回调
 @param failure 失败回调
 @return NSURLSessionDataTask 实例
 */
- (NSURLSessionDataTask * _Nullable)GET:(NSString *)URLString
                             parameters:(NSDictionary* _Nullable)parameters
                                success:(SessionDataTaskSuccessCallback _Nullable)success
                                failure:(SessionDataTaskFailureCallback _Nullable)failure;

/**
 普通 POST 请求
 
 @param URLString 完整的URL
 @param parameters 请求参数 比如字典
 @param success 成功回调
 @param failure 失败回调
 @return NSURLSessionDataTask 实例
 */
- (NSURLSessionDataTask * _Nullable)POST:(NSString *)URLString
                              parameters:(NSDictionary* _Nullable)parameters
                                 success:(SessionDataTaskSuccessCallback _Nullable)success
                                 failure:(SessionDataTaskFailureCallback _Nullable)failure;

@optional
/**
 普通 UPLOAD 请求 没有返回进度
 
 @param URLString 完整的URL
 @param parameters 请求参数 比如字典
 @param data 二进制
 @param success 成功回调
 @param failure 失败回调
 @return NSURLSessionDataTask 实例
 */
- (NSURLSessionDataTask * _Nullable)UPLOAD:(NSString *)URLString
                                parameters:(NSDictionary* _Nullable)parameters
                                      data:(NSData *)data
                                   success:(SessionDataTaskSuccessCallback _Nullable)success
                                   failure:(SessionDataTaskFailureCallback _Nullable)failure;

@end


NS_ASSUME_NONNULL_END