//
//  RunsHttpSessionRespone.h
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunsHttpSessionRespone : NSObject
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSDictionary *origin;
@property (nonatomic, copy) NSString *errorMessage;
@property (nonatomic, copy) NSString *returnCode;

- (instancetype)initWithResponeData:(id)respone;
- (NSError *)error;
@end
