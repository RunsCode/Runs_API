//
//  EasyObserve.m
//
//  Created by wy0012 on 15/12/17.
//

#import "EasyObserver.h"
#import "RunsMacroConstant.h"

@implementation EasyObserver {
    HandNotificationCallBack mNotificationFunc;
    NSArray<NSString *> * mNotificationList;
}

- (instancetype)init {
    self = [super init];
    if (self) { }
    return self;
}

- (void)dealloc {
    if (mNotificationFunc)
        mNotificationFunc = nil;
    
    if (mNotificationList)
        mNotificationList = nil;
}

- (void)startUpListen:(HandNotificationCallBack)callback withList:(NSArray<NSString *> *)notficationlist {
    mNotificationFunc = callback;
    [self registerObserver:notficationlist];
}

- (void)shutDown {
    [self removeRegisteredObserver];
}

- (void)registerObserver:(NSArray<NSString *> *)notficationlist {
    [self removeRegisteredObserver];
    if (notficationlist.count <= 0) { return;}
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    for (NSString * noti in notficationlist) {
        [center addObserver:self selector:@selector(handNotification:) name:noti object:nil];
    }
    
    mNotificationList = notficationlist;
}

- (void)handNotification:(NSNotification *)notification {
    if (mNotificationFunc)
        mNotificationFunc(notification);
}

- (void)removeRegisteredObserver {
    if (mNotificationList.count <= 0) {return;}
    
    NSNotificationCenter * center = [NSNotificationCenter defaultCenter];
    for (NSString * noti in mNotificationList) {
        [center removeObserver:self name:noti object:nil];
    }
}



@end
