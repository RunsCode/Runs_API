//
//  UIView+TargetAction.h
//  OU_iPhone
//
//  Created by runs on 2018/5/28.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunsTargetActionEngineProtocol.h"

@interface UIView (TargetAction)<RunsTargetActionEngineProtocol>
@property(nonatomic, strong) id<RunsTargetActionEngineProtocol> targetactionEngine;
- (void)rs_releaseTargetactionEngine;
@end
