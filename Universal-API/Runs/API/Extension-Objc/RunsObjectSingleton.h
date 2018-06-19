//
//  RunsObjectSingleton.h
//  OU_iPhone
//
//  Created by runs on 2018/5/17.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjectSingletonProtocol <NSObject>
@optional
- (void)_init;
@end

@interface RunsObjectSingleton : NSObject<ObjectSingletonProtocol>

- (instancetype)init __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype)new  __attribute__((unavailable("new not available, call sharedInstance instead")));

+ (instancetype)sharedInstance;
- (void)destory;
@end
