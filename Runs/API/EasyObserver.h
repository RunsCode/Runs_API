//
//  EasyObserve.h
//
//  这是一个简洁版消息中心，主要是封装[NSNotificationCenter defaultCenter]单例的调用
//  Created by wy0012 on 15/12/17.
//

#import <Foundation/Foundation.h>

typedef void(^HandNotificationCallBack)(NSNotification * notification);
@interface EasyObserver : NSObject

/**
 *  用于注册消息
 *  For register Observer
 *
 *  @param callback        a callback blcok
 *  @param notficationlist 即将注册的消息列表
 */
- (void)startUpListen:(HandNotificationCallBack)callback withList:(NSArray<NSString *> *)notficationlist;

/**
 *  移除消息监听
 */
- (void)shutDown;
@end
