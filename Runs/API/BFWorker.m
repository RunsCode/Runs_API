//
//  BFWorker.m
//  fTalk
//
//  Created by wang on 15/4/22.
//
//

#import "BFWorker.h"
#import "RunsMacroConstant.h"

@implementation BFWorker
{
    NSString* _mpWorkerName;
    id __weak _weakObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mpWorkerName = nil;
        _workerHolder = nil;
    }
    return self;
}

- (void)dealloc
{
    [self detachTarget];
    _mpWorkerName = nil;
    _workerHolder = nil;
}

-(void)setName:(NSString*)_name
{
    _mpWorkerName = [NSString stringWithString:_name];
}

+(BFWorker*)withName:(NSString*)_name
{
    BFWorker* _worker = [[self alloc] init];
    [_worker setName:_name];
    return _worker;
}

-(BFWorker*)catchTarget:(id __weak)_object
{
    RunsAssert(_object != nil, @"BFWorker catchTarget: 参数不能为空!");
    RunsAssert(_weakObject == nil, @"BFWorker catchTarget: 注册/反注册不配对!");
    _weakObject = _object;
    [self onCatchTarget];
    return  self;
}

-(void)onCatchTarget
{
    // sub class will override
}

-(void)detachTarget
{
    if (self.targetObject) {
        [self onDetachTarget];
        _weakObject = nil;
    }
}

-(void)onDetachTarget
{
    // sub class will override
}

-(NSString*)workerName
{
    return _mpWorkerName;
}

-(id __weak)targetObject
{
    return _weakObject;
}

-(void)onRegister
{
    
}

-(void)onRemove
{
    
}

@end


@implementation BFWorkerHolder
{
    NSMutableDictionary* _mpWorkerMap;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mpWorkerMap = [[NSMutableDictionary alloc] initWithCapacity:32];
    }
    return self;
}

- (void)dealloc
{
    _mpWorkerMap = nil;
}

-(void)registerWorker:(BFWorker*)_worker
{
    NSAssert(_worker.workerName && [_worker.workerName length] > 0, @"BFWorkerHolder registerWorker error!");
    [_mpWorkerMap setObject:_worker forKey:_worker.workerName];
    _worker.workerHolder = self;
    [_worker onRegister];
}

-(void)unRegisterWorker:(NSString*)_workerName
{
    BFWorker* _worker = [self getWorker:_workerName];
    if (_worker) {
        _worker.workerHolder = nil;
        [_worker onRemove];
    }
    [_mpWorkerMap removeObjectForKey:_workerName];
}

-(void)removeAllWorkers
{
    NSArray* _allKeys = [_mpWorkerMap allKeys];
    for (int i=0; i < [_allKeys count]; i++) {
        BFWorker* _worker = [self getWorker:[_allKeys objectAtIndex:i]];
        if (_worker) {
            _worker.workerHolder = nil;
        }
    }
    [_mpWorkerMap removeAllObjects];
}

-(BFWorker*)getWorker:(NSString*)_workerName
{
    return [_mpWorkerMap objectForKey:_workerName];
}

@end
