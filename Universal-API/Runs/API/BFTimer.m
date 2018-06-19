//
//  BFTimer.m
//  fTalk
//
//  Created by wang on 15/8/13.
//
//

#import "BFTimer.h"
#import "RunsMacroConstant.h"

@implementation BFTimer {
    NSTimer* _mpTimer;
    NSDate* _mpPauseStart;
    NSDate* _mpPreviousFireDate;
    BFTimerBlock mBlock;
}

static NSMutableDictionary* _timerMap;

-(void)loop_func:(NSTimer*)timer {
    if (mBlock) {
        mBlock([timer userInfo]);
    }
}

-(void)loop_once:(NSTimer*)timer {
    if (mBlock) {
        mBlock([timer userInfo]);
    }
    [self shutDown];
}

-(void)powerUp:(CGFloat)fInterval withblock:(BFTimerBlock)callback {
//    RunsAssert(_mpTimer==nil, @"timer已经运行!"); //Debug 模式下 用户体验不好
    if (self.working) {
        return;
    }
    _mpPauseStart = nil;
    _mpPreviousFireDate = nil;
    mBlock = callback;
    _mpTimer = [NSTimer scheduledTimerWithTimeInterval:fInterval target:self selector:@selector(loop_func:) userInfo:nil repeats:YES];
    [BFTimer buildTimerMap];
    [self nonbloking:YES];
    [_mpTimer fire];
    [_timerMap setObject:self forKey:@((NSInteger)self)];
}

-(void)powerUpOnce:(CGFloat)fInterval withblock:(BFTimerBlock)callback withObject:(id)obj {
    RunsAssert(_mpTimer==nil, @"timer已经运行!");
    _mpPauseStart = nil;
    _mpPreviousFireDate = nil;
    mBlock = callback;
    _mpTimer = [NSTimer scheduledTimerWithTimeInterval:fInterval target:self selector:@selector(loop_once:) userInfo:obj repeats:NO];
    [BFTimer buildTimerMap];
    [self nonbloking:YES];
    [_mpTimer fire];
    [_timerMap setObject:self forKey:@((NSInteger)self)];
}

- (void)fire {
    [_mpTimer fire];
}

-(void)shutDown {
    if (_mpTimer) {
        [_mpTimer invalidate];
        _mpTimer = nil;
    }
    [BFTimer buildTimerMap];
    [_timerMap removeObjectForKey:@((NSInteger)self)];
}

-(BOOL)working {
    return _mpTimer!=nil;
}

-(BOOL)nonbloking:(BOOL)bValue {
    if (_mpTimer==nil) {
        return NO;
    }
    if (bValue) {
        NSRunLoop* runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:_mpTimer forMode:NSRunLoopCommonModes];
        return YES;
    }
    return NO;
}

-(void)pause {
    if (_mpTimer && _mpPauseStart==nil) {
        _mpPauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
        _mpPreviousFireDate = _mpTimer.fireDate;
        [_mpTimer setFireDate:[NSDate distantFuture]];
    }
}

-(void)resume {
    if (_mpTimer && _mpPauseStart) {
        float pauseTime = (-1)*[_mpPauseStart timeIntervalSinceNow];
        [_mpTimer setFireDate:[NSDate dateWithTimeInterval:pauseTime sinceDate:_mpPreviousFireDate]];
        _mpPauseStart = nil;
        _mpPreviousFireDate = nil;
    }
}

+(void)buildTimerMap
{
    if (_timerMap==nil) {
        _timerMap = [[NSMutableDictionary alloc] initWithCapacity:64];
    }
}

+(void)allTimerPause
{
    NSArray* allKeys = [_timerMap allKeys];
    for (NSInteger i=0; i < allKeys.count; i++) {
         BFTimer* timer = _timerMap[allKeys[i]];
        [timer pause];
    }
}

+(void)allTimerResume
{
    NSArray* allKeys = [_timerMap allKeys];
    for (NSInteger i=0; i < allKeys.count; i++) {
        BFTimer* timer = _timerMap[allKeys[i]];
        [timer resume];
    }
}

+(void)allTimerStop {
    NSArray* allKeys = [_timerMap allKeys];
    for (NSInteger i=0; i < allKeys.count; i++) {
        BFTimer* timer = _timerMap[allKeys[i]];
        [timer shutDown];
    }
}


@end
