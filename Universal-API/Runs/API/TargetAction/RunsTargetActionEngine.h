//
//  RunsTargetActionEngine.h
//  OU_iPhone
//
//  Created by runs on 2018/4/17.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunsTargetActionEngineProtocol.h"

@interface RunsTargetActionWrap : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, copy) NSString *action;
+ (instancetype)wrapWithTarget:(nullable id)target action:(nullable SEL)action;
@end


@interface RunsTargetActionEngine : NSObject<RunsTargetActionEngineProtocol>

@end
