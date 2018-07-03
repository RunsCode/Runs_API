//
//  NSObject+Observation.h
//  OU_iPad
//
//  Created by runs on 2018/6/12.
//  Copyright © 2018 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IKeyPathListenerProtocol <NSObject>
@optional
- (void)updateKeyPath:(NSString *)keyPath withValue:(id)value;
- (void)updateModel:(id)object withKeyPath:(NSString *)keyPath;
@end

@protocol IObjectObservationProtocol <NSObject>
@optional
- (void)addListener:(id<IKeyPathListenerProtocol>)listener keyPath:(NSString *)keyPath;
- (void)removeListener:(id<IKeyPathListenerProtocol>)listener keyPath:(NSString *)keyPath;
- (void)removeListener:(id<IKeyPathListenerProtocol>)listener;
- (void)fireKeyPath:(NSString *)keyPath withValue:(id)value;
@end

@interface NSObject (Observation)
- (void)rs_releaseObserverMap;
@end
