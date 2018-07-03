//
//  NSOperationQueue+Category.h
//  OU_iPhone
//
//  Created by runs on 2018/5/23.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperation (Category)

@end

@interface NSOperationQueue (Category)
- (void)rs_addMutableOperation:(NSOperation *)firstObj,...;
- (NSOperationQueue * (^)(NSOperation *op))add;
//

/**
 切换到主线程`异步`执行Block里任务
 */
+ (void)rs_safeMainThreadAsync:(dispatch_block_t)block;
/**
 切换到主线程`同步`执行Block里任务
 */
+ (void)rs_safeMainThreadSync:(dispatch_block_t)block;
@end
