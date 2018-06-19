//
//  BFMission.m
//  fTalk
//
//  Created by baifeng on 15/9/10.
//
//

#import "BFMission.h"
#import "BFTimer.h"
#import "RunsMacroConstant.h"

//==========================================================================

@implementation BFMission

-(instancetype)initWithBlock:(BFMissionBlock)callback
{
    if (self = [super init]) {
        self.main = callback;
        self.bSleep = NO;
    }
    return self;
}

+(instancetype)withBlock:(BFMissionBlock)callback
{
    BFMission* obj = [[BFMission alloc] initWithBlock:callback];
    return obj;
}

- (void)dealloc
{
    self.main = nil;
}

@end


//==========================================================================

@interface PrivateMission : NSObject
@property (nonatomic) CGFloat fCurInterval;
@property (nonatomic) CGFloat fMaxInterval;
@property (nonatomic) BFMission* target;
@end

@implementation PrivateMission
@end


//==========================================================================

@implementation BFMissionMaster
{
    BFTimer* _mpTimer;
    NSMutableDictionary* _mpMissionMap;
}

- (void)dealloc
{
    [_mpTimer shutDown];
    [_mpMissionMap removeAllObjects];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.triggerInterval = 1.0f;
        _mpTimer = [[BFTimer alloc] init];
        _mpMissionMap = [[NSMutableDictionary alloc] initWithCapacity:64];
    }
    return self;
}

-(void)loop_func
{
    [self performSelectorOnMainThread:@selector(loop_func_in_main_thread) withObject:nil waitUntilDone:NO];
//    [self performSelector:@selector(loop_func_in_main_thread) onThread:[NSThread currentThread] withObject:nil waitUntilDone:NO];
//    [self loop_func_in_main_thread];
//    RunsLog(@"%@",[NSThread currentThread]);
}

-(void)loop_func_in_main_thread
{
    NSArray* allKeys = [_mpMissionMap allKeys];
    for (NSInteger i=0; i < allKeys.count; i++) {
        NSString* key = allKeys[i];
        PrivateMission* mission = [_mpMissionMap objectForKey:key];
        if (mission.target.bSleep) {
            continue;
        }
        mission.fCurInterval += self.triggerInterval;
        if (mission.fCurInterval >= mission.fMaxInterval) {
            if (mission.target == nil) {
                [_mpMissionMap removeObjectForKey:key];
            }else {
                if (mission.target.main(mission.fCurInterval)==NO) {
                    [_mpMissionMap removeObjectForKey:key];
                }
            }
            mission.fCurInterval = 0.0f;
        }
    }
}

-(void)registerMission:(NSString*)missionName withWorker:(BFMission*)worker delayInterval:(CGFloat)fInterval
{
    
    if ([self hasMission:missionName]) {
        return;
    }
    
    PrivateMission* mission = [[PrivateMission alloc] init];
    mission.fCurInterval = 0.0f;
    mission.fMaxInterval = fInterval;
    mission.target = worker;
    [_mpMissionMap setObject:mission forKey:missionName];
}

-(void)removeMission:(NSString*)missionName
{
    if (!missionName) {
        return;
    }
    [_mpMissionMap removeObjectForKey:missionName];
}

-(BOOL)hasMission:(NSString*)missionName
{
    return [_mpMissionMap objectForKey:missionName]!=nil;
}

-(BFMission*)getMission:(NSString*)missionName
{
    PrivateMission* mission = [_mpMissionMap objectForKey:missionName];
    return mission.target;
}

-(NSArray*)allMissionKeys
{
    NSArray* allKeys = [_mpMissionMap allKeys];
    return allKeys;
}

-(void)fire
{
    if (_mpTimer.working) {
        return;
    }
    WEAK_BLOCK_OBJECT(self);
    [_mpTimer powerUp:self.triggerInterval withblock:^(id data) {
        BLOCK_OBJECT(self);
        [weak_self loop_func];
    }];// withObject:nil];
    [_mpTimer nonbloking:YES];
}

-(void)stop
{
    [_mpTimer shutDown];
}

-(void)setTriggerInterval:(CGFloat)triggerInterval
{
    _triggerInterval = triggerInterval;
    if (_mpTimer.working) {
        [self stop];
        [self fire];
    }
}

@end
