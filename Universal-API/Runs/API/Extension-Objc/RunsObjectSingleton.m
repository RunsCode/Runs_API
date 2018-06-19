//
//  RunsObjectSingleton.m
//  OU_iPhone
//
//  Created by runs on 2018/5/17.
//  Copyright © 2018年 Olacio. All rights reserved.
//

#import "RunsObjectSingleton.h"
#import <objc/runtime.h>
#import "RunsMacroConstant.h"

@interface Hash<ObjectType> : NSObject<NSCopying>
@property (nonatomic, assign) NSInteger code;
- (instancetype)initWithObject:(ObjectType)object;
@end

@implementation Hash

- (instancetype)initWithObject:(id)object {
    self = [super init];
    if (self) {
        _code = [object hash];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    Hash *hash = [[[self class] allocWithZone:zone] init];
    hash.code = self.code;
    return hash;
}

- (NSUInteger)hash {
    return _code << 8;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    Hash *hash = (Hash *)object;
    return hash.code == _code;;
}

@end

@interface SingletonHashMap : NSObject
- (id<ObjectSingletonProtocol>)singletonForClassObject:(id)classObj;
- (void)destorySingletonForClassObject:(id)classObj;
@end

@implementation SingletonHashMap {
    NSMapTable<Hash<id> *, id> *hashMap;
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        hashMap = [NSMapTable strongToStrongObjectsMapTable];
    }
    return self;
}

- (id<ObjectSingletonProtocol>)singletonForClassObject:(id)classObj {
    Hash *hash = [[Hash<id> alloc] initWithObject:classObj];
    id<ObjectSingletonProtocol> instance = [hashMap objectForKey:hash] ;
    if (!instance) {
        instance = [[[classObj class] alloc] init];
        [self setObject:instance forHash:hash];
    }
    return instance;
}

- (void)destorySingletonForClassObject:(id)classObj {
    Hash *hash = [[Hash<id> alloc] initWithObject:classObj];
    [self removeObjectForHash:hash];
}

- (void)setObject:(id)obj forHash:(Hash<id> *)hash {
    if (!obj || !hash) {
        return;
    }
    
    if ([hashMap objectForKey:hash]) {
        return;
    }
    [hashMap setObject:obj forKey:hash];
}

- (void)removeObjectForHash:(Hash<id> *)hash {
    [hashMap removeObjectForKey:hash];
}

@end

@implementation RunsObjectSingleton

+ (SingletonHashMap *)sharedSingletonHashMap {
    static id sharedSingletonHashMap = nil;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        sharedSingletonHashMap = [[SingletonHashMap alloc] init];
    });
    return sharedSingletonHashMap;
}

+ (instancetype)sharedInstance {
    return (RunsObjectSingleton *)[RunsObjectSingleton.sharedSingletonHashMap singletonForClassObject:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)destory {
    [RunsObjectSingleton.sharedSingletonHashMap destorySingletonForClassObject:self.class];
}

- (void)dealloc {
    RunsReleaseLog()
}

- (void)_init {
    
}

@end
