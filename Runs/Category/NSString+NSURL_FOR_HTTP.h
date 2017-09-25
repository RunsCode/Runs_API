//
//  NSString+NSURL_FOR_HTTP.h
//  OU_iPad
//
//  Created by runs on 2017/8/3.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSURL_FOR_HTTP)
- (NSURL *)composeURLWithKeyValue:(NSDictionary *)parameters;
@end
