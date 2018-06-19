//
//  NSObject+Observation.m
//  OU_iPad
//
//  Created by runs on 2018/6/12.
//  Copyright © 2018 Olacio. All rights reserved.
//

#import "NSObject+Observation.h"

@implementation NSObject (Observation)

+ (void)load {
    Method originalMethod0 = class_getInstanceMethod(self, @selector(setValue:forKeyPath:));
    Method swizzleMethod0 = class_getInstanceMethod(self, @selector(rs_setValue:forKeyPath:));
    method_exchangeImplementations(originalMethod0, swizzleMethod0);
    Method originalMethod1 = class_getInstanceMethod(self, @selector(setValue:forKey:));
    Method swizzleMethod1 = class_getInstanceMethod(self, @selector(rs_setValue:forKey:));
    method_exchangeImplementations(originalMethod1, swizzleMethod1);
    Method originalMethod2 = class_getInstanceMethod(self, @selector(setNilValueForKey:));
    Method swizzleMethod2 = class_getInstanceMethod(self, @selector(rs_setNilValueForKey:));
    method_exchangeImplementations(originalMethod2, swizzleMethod2);
}

- (void)rs_releaseObserverMap {
    NSMutableDictionary *map = objc_getAssociatedObject(self, @selector(listenKeyPathMap));
    if (!map) return;
    [map removeAllObjects];
    objc_setAssociatedObject (self, @selector(listenKeyPathMap), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *,NSHashTable<id<IKeyPathListenerProtocol>> *> *)listenKeyPathMap {
    NSMutableDictionary *map = objc_getAssociatedObject(self, @selector(listenKeyPathMap));
    if (map) return map;
    map = [[NSMutableDictionary alloc] init];
    objc_setAssociatedObject(self, @selector(listenKeyPathMap), map, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return map;
}

- (void)addListener:(id<IKeyPathListenerProtocol>)listener keyPath:(NSString *)keyPath {
    if (keyPath.length <= 0) return;
    if (![listener conformsToProtocol:@protocol(IKeyPathListenerProtocol)]) return;

    NSMutableDictionary<NSString *, NSHashTable *> *map = self.listenKeyPathMap;
    if (!map[keyPath]) {
        map[keyPath] = [NSHashTable weakObjectsHashTable];
    }
    
    if ([map[keyPath] containsObject:listener]) return;
    [map[keyPath] addObject:listener];
}

- (void)removeListener:(id<IKeyPathListenerProtocol>)listener keyPath:(NSString *)keyPath {
    if (keyPath.length <= 0) return;
    NSHashTable *table = self.listenKeyPathMap[keyPath];
    if (!table || ![table containsObject:listener]) return;
    [table removeObject:listener];
}

- (void)removeListener:(id<IKeyPathListenerProtocol>)listener {
    for (NSHashTable<id<IKeyPathListenerProtocol>> *table in self.listenKeyPathMap.allValues) {
        if ([table containsObject:listener]) {
            [table removeObject:listener];
        }
    }
}

- (void)fireKeyPath:(NSString *)keyPath withValue:(id)value {
    NSHashTable<id<IKeyPathListenerProtocol>> *table = self.listenKeyPathMap[keyPath];
    if (!table) return;
    [table.objectEnumerator.allObjects enumerateObjectsUsingBlock:^(id<IKeyPathListenerProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(updateKeyPath:withValue:)]) {
            [obj updateKeyPath:keyPath withValue:value];
        }
        if ([obj respondsToSelector:@selector(updateModel:withKeyPath:)]) {
            [obj updateModel:self withKeyPath:keyPath];
        }
    }];
}

- (BOOL)hasObserverWithKeyPath:(NSString *)keyPath {
    if (![self conformsToProtocol:@protocol(IObjectObservationProtocol)]) return NO;
    __block BOOL has = NO;
    [self.listenKeyPathMap.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:keyPath]) {
            has = YES;
            *stop = YES;
        }
    }];
    return has;
}

- (void)rs_setValue:(id)value forKey:(NSString *)key {
    [self rs_setValue:value forKey:key];
    if (![self hasObserverWithKeyPath:key]) return;
    [self fireKeyPath:key withValue:value];
}

- (void)rs_setValue:(id)value forKeyPath:(NSString *)keyPath {
    [self rs_setValue:value forKeyPath:keyPath];
    if (![self hasObserverWithKeyPath:keyPath]) return;
    [self fireKeyPath:keyPath withValue:value];
}

- (void)rs_setNilValueForKey:(NSString *)key {
    [self rs_setNilValueForKey:key];
    if (![self hasObserverWithKeyPath:key]) return;
    [self fireKeyPath:key withValue:nil];
}



@end
