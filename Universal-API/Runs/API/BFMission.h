//
//  BFMission.h
//  fTalk
//
//  Created by wang on 15/9/10.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef BOOL (^BFMissionBlock)(CGFloat dt);

@interface BFMission : NSObject
+(instancetype)withBlock:(BFMissionBlock)callback;
-(instancetype)initWithBlock:(BFMissionBlock)callback;
@property (nonatomic,strong) BFMissionBlock main;
@property (nonatomic) BOOL bSleep; // 待机
@end

@interface BFMissionMaster : NSObject
-(void)registerMission:(NSString*)missionName withWorker:(BFMission*)worker delayInterval:(CGFloat)fInterval;
-(void)removeMission:(NSString*)missionName;
-(BOOL)hasMission:(NSString*)missionName;
-(BFMission*)getMission:(NSString*)missionName;
-(NSArray*)allMissionKeys;
-(void)fire;
-(void)stop;
@property (nonatomic) CGFloat triggerInterval; // 工作频率,单位秒,默认1.0
@end
