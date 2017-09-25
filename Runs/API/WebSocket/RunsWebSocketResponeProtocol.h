//
//  RunsWebSocketResponeProtocol.h
//  OU_iPad
//
//  Created by runs on 2017/8/7.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RunsWebSocketResponeProtocol <NSObject>
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *dest;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, strong) NSDictionary *data;
@end
