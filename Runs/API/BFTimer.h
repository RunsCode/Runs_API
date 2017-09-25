//
//  BFTimer.h
//  fTalk
//
//  Created by wang on 15/8/13.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^BFTimerBlock)(id data);

@interface BFTimer : NSObject
-(void)powerUp:(CGFloat)fInterval withblock:(BFTimerBlock)callback;// withObject:(id)obj; // auto loop
-(void)powerUpOnce:(CGFloat)fInterval withblock:(BFTimerBlock)callback withObject:(id)obj;
-(void)fire;
-(void)shutDown;
-(BOOL)working;
-(BOOL)nonbloking:(BOOL)bValue;
-(void)pause;
-(void)resume;
+(void)allTimerPause;
+(void)allTimerResume;
+(void)allTimerStop;
@end
