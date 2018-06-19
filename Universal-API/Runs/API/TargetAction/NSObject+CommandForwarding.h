//
//  NSObject+CommandForwarding.h
//  OU_iPhone
//
//  Created by runs on 2018/5/2.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunsCommandForwardingEngineProtocol.h"

@interface NSObject (CommandForwarding)
@property(nonatomic, strong) id<RunsCommandForwardingEngineProtocol> commandEngine;
- (void)rs_releaseCommadnForwardingEngine;
@end
