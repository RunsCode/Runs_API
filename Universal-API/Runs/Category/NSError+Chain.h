//
//  NSError+Chain.h
//  
//
//  Created by runs on 2018/6/28.
//  Copyright © 2018 Runs. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSError (Chain)
+ (instancetype (^)(NSString *desc))error;
+ (instancetype (^)(NSString *desc, NSInteger code))errorCode;
+ (NSError* (^)(NSInteger))code;
+ (NSError* (^)(NSString *))domain;
//
- (NSError* (^)(NSInteger))rs_code;
- (NSError* (^)(NSString *))rs_domain;
- (NSError* (^)(NSDictionary *))rs_userInfo;
@end
NS_ASSUME_NONNULL_END
