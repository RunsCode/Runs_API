//
//  NSURLSessionTask+Category.h
//  OU_iPhone
//
//  Created by runs on 2017/11/21.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionTask (Category)
@property (nonatomic, assign) NSInteger maxRetryCount;
- (void)rs_retry:(void(^)(void))completd;
@end
