//
//  RunsTargetActionEngineProtocol.h
//  OU_iPhone
//
//  Created by runs on 2018/4/17.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, RunsControlEvents) {
    RunsControlEvent_None         = 0,
    RunsControlEvent_Play         = 1,
    RunsControlEvent_Pause        = 2,
    RunsControlEvent_Reload       = 3,
    RunsControlEvent_Pop          = 4,
    RunsControlEvent_Push         = 5,
    RunsControlEvent_Present      = 6,
    RunsControlEvent_Dismiss      = 7,
    RunsControlEvent_Back         = 8,
    RunsControlEvent_Seek         = 9,
    RunsControlEvent_Next         = 10,
    RunsControlEvent_Undo         = 11,
    RunsControlEvent_Redo         = 12,
    RunsControlEvent_Clear        = 13,
    RunsControlEvent_Delete       = 14,
    RunsControlEvent_Start        = 15,
    RunsControlEvent_Stop         = 16,
    RunsControlEvent_Suspend      = 17,
    RunsControlEvent_Resume       = 18,
    RunsControlEvent_Cancel       = 19,
    RunsControlEvent_Done         = 20,
    RunsControlEvent_Tap          = 21,
    RunsControlEvent_HorizontalMove         = 22,
    RunsControlEvent_VerticalMove           = 23,
    RunsControlEvent_MoveBegan              = 24,
    RunsControlEvent_MoveEnded              = 25,
    RunsControlEvent_DoubleClick            = 26,
    RunsControlEvent_Default = RunsControlEvent_None,
};

@protocol RunsTargetActionEngineProtocol <NSObject>
- (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(RunsControlEvents)controlEvents;
- (void)removeTarget:(nullable id)target action:(nullable SEL)action forControlEvents:(RunsControlEvents)controlEvents;
- (void)clear;
@optional
- (void)runWithEvents:(RunsControlEvents)controlEvents;
- (void)runWithEvents:(RunsControlEvents)controlEvents parameter:(id)parameter;
@end
