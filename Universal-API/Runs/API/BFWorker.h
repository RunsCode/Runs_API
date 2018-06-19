//
//  BFWorker.h
//  fTalk
//
//  Created by wang on 15/9/10.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^BFButtonClick)(id sender);

@class BFWorkerHolder;
@interface BFWorker : NSObject
+(BFWorker*)withName:(NSString*)_name;
/**
 *  持有一个对象，以弱引用方式持有
 *
 *  @param _object 目标对象，可以是视图，可以是视图控制器，可以是任何对象
 *
 *  @return self
 */
-(BFWorker*)catchTarget:(id)_object;
/**
 *  放开持有的对象,与catchTarget配对
 */
-(void)detachTarget;
/**
 *  调用catchTarget时会回调
 */
-(void)onCatchTarget; // sub class will override
/**
 *  调用detachTarget时会回调
 */
-(void)onDetachTarget; // sub class will override
/**
 *  当前worker的名字，别的对象索引当前对象时需要用到
 *
 *  @return 当前worker的名字
 */
-(NSString*)workerName;
/**
 *  目标对象
 *
 *  @return 目标对象
 */
-(id)targetObject;
/**
 *  被BFWorkerHolder注册时回调
 */
-(void)onRegister;
/**
 *  被BFWorkerHolder解注册时回调
 */
-(void)onRemove;
/**
 *  自身的持有者
 */
@property (nonatomic,weak) BFWorkerHolder* workerHolder;
@end

@interface BFWorkerHolder : NSObject
-(void)registerWorker:(BFWorker*)_worker;
-(void)unRegisterWorker:(NSString*)_workerName;
-(void)removeAllWorkers;
-(BFWorker*)getWorker:(NSString*)_workerName;
@end
