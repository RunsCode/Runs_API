//
//  Promise.h
//  OU_iPhone
//
//  Created by runs on 2018/6/5.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "FBLPromise.h"

NS_ASSUME_NONNULL_BEGIN

@interface Promise<__covariant Value> : FBLPromise
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end
@interface Promise<Value>(DotSyntaxAdditions)

/**
 Convenience dot-syntax wrappers for FBLPromise.
 Usage: FBLPromise.resolve(value)
 */
+ (Promise* (^)(id __nullable))resolve FBL_PROMISES_DOT_SYNTAX NS_SWIFT_UNAVAILABLE("");

@end
NS_ASSUME_NONNULL_END
