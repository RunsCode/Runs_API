//
//  RunsHttpSessionResponse.m
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsHttpSessionResponse.h"
#import "GKSimpleAPI.h"

#define CODE_KEY        @"code"
#define RESULT_CODE_KEY @"resultCode"
#define RETURN_CODE_KEY @"returncode"
#define DATA_KEY        @"data"
#define SUCCESS_KEY     @"success"
#define ERR_MSG_KEY     @"message"

@implementation RunsHttpSessionResponse

- (instancetype)initWithResponseData:(id)respone {
    self = [super init];
    if (self) {
        id object = [GKSimpleAPI dataConversionAdaption:respone];
        if ([object isKindOfClass:NSArray.class]) {
            NSArray *array = (NSArray *)object;
            _success = array.count > 0;
            _data = array;
            return self;
        }
        
        NSDictionary *json = (NSDictionary *)object;
        _origin = json;
        //
        if (json[CODE_KEY]) {
            _code = [json[CODE_KEY] integerValue];
        }
        
        if (json[RESULT_CODE_KEY]) {
            _code = [json[RESULT_CODE_KEY] integerValue];
        }
        
        if (json[RETURN_CODE_KEY]) {
            _returnCode = json[RETURN_CODE_KEY];
        }
        
        if (json[SUCCESS_KEY]) {
            _success = [json[SUCCESS_KEY] boolValue];
        }
        
        if (json[DATA_KEY]) {
            _data = json[DATA_KEY];
        }
        
        if (json[ERR_MSG_KEY]) {
            _errorMessage = json[ERR_MSG_KEY];
        }
        //test fuck 接口返回不统一 
        if (!_data && _origin && [json.allKeys containsObject:@"appId"]) {
            _success = _code  == 20000;
        }
        
        if (_returnCode.length > 0) {
            _success = [_returnCode isEqualToString:@"SUCCESS"];
        }
    }
    return self;
}

- (NSError *)error {
    if (!self.errorMessage) self.errorMessage = @"网络异常";
    return [NSError errorWithDomain:self.errorMessage code:self.code userInfo:nil];
}

@end
