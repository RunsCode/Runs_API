//
//  RunsHttpSessionProxy.h
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunsHttpSessionProtocol.h"
#import "RunsObjectSingleton.h"


NS_ASSUME_NONNULL_BEGIN

@interface RunsHttpSessionProxy : RunsObjectSingleton <RunsHttpSessionProtocol>

@end
NS_ASSUME_NONNULL_END
