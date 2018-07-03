//
//  NSError+Chain.m
//  
//
//  Created by runs on 2018/6/28.
//  Copyright © 2018 Runs. All rights reserved.
//

#import "NSError+Chain.h"

@implementation NSError (Chain)

+ (instancetype (^)(NSString *))error {
    return ^(NSString *desc) {
        NSError *err = [NSError errorWithDomain:desc code:-1 userInfo:nil];
        return err;
    };
}

+ (instancetype (^)(NSString *desc, NSInteger code))errorCode {
    return ^(NSString *desc, NSInteger code) {
        NSError *err = [NSError errorWithDomain:desc code:code userInfo:nil];
        return err;
    };
}

+ (NSError* (^)(NSInteger))code {
    return ^(NSInteger code) {
        return [NSError errorWithDomain:@"" code:code userInfo:nil];
    };
}

+ (NSError* (^)(NSString *))domain {
    return ^(NSString *domain) {
        return [NSError errorWithDomain:domain code:-1 userInfo:nil];
    };
}

- (NSError* (^)(NSInteger))rs_code {
    return ^(NSInteger code) {
        [self setValue:@(code) forKey:@"code"];
        return self;
    };
}

- (NSError* (^)(NSString *))rs_domain {
    return ^(NSString *domain) {
        [self setValue:domain forKey:@"domain"];
        return self;
    };
}

- (NSError* (^)(NSDictionary *))rs_userInfo {
    return ^(NSDictionary *info) {
        [self setValue:info forKey:@"userInfo"];
        return self;
    };
}

@end

