//
//  RunsWebSocketProxy.m
//  OU_iPad
//
//  Created by runs on 2017/8/1.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsWebSocketProxy.h"
#import <SocketRocket/SRWebSocket.h>
#import "RunsWebSocketDelegate.h"

@interface RunsWebSocketProxy ()<SRWebSocketDelegate>
@property (nonatomic, assign) BOOL isReconnect;
@property (nonatomic, assign) NSUInteger reconnectCount;
@property (nonatomic, strong) SRWebSocket *socket;
@property (nonatomic, strong) NSMapTable<NSNumber *, SocketCallback> *callbackMap;
@end

@implementation RunsWebSocketProxy {
    //for test
    NSMutableArray<id<RunsWebSocketDelegate>> *delegates;
}

- (void)dealloc {
    RunsReleaseLog()
}

- (instancetype)init {
    self = [super init];
    if (self) {
        delegates = [NSMutableArray array];
        _reconnectMaxCount = WEBSOCKET_RECONNECT_COUNT;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

+ (instancetype)socketWithDelegate:(id<RunsWebSocketDelegate>)delegate {
    return [[[self class] alloc]initWithDelegate:delegate];
}

- (instancetype)initWithDelegate:(id<RunsWebSocketDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)setDelegate:(id<RunsWebSocketDelegate>)delegate {
    if ([delegates containsObject:delegate]) {
        return;
    }
    [delegates addObject:delegate];
}


#pragma mark -- RunsWebSocketProtocol 
- (void)connectWithURL:(NSURL *)URL {
    if (self.isConnect) return;
    
    _host = URL;
    //
    [self close];
    self.socket = [[SRWebSocket alloc] initWithURL:URL];
    self.socket.delegate = self;
    [self.socket open];
}

- (void)reconnect {
    _isReconnect = YES;
    [self connectWithURL:_host];
}

- (void)close {
    if (!self.isConnect) return;
    [self.socket close];
    [self clean];
}

- (void)closeWithManually:(BOOL)isManually {
    if (!self.isConnect) return;
    _isManuallyDisconnect = isManually;
    [self close];
}

- (void)clean {
    _isConnect = NO;
}

- (void)setReconnectMaxCount:(NSUInteger)reconnectMaxCount {
    _reconnectMaxCount = reconnectMaxCount > 0 ? reconnectMaxCount : WEBSOCKET_RECONNECT_COUNT;
}

- (void)sendMap:(NSDictionary *)parameters {
    if (!self.isConnect) return;
    if (_socket.readyState != SR_OPEN) {
        if (_socket.readyState == SR_CLOSING || _socket.readyState == SR_CLOSED) return;
        __weak typeof(self) weak_self = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weak_self sendMap:parameters];
        });
        return;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.socket send:jsonString];
    RunsLogEX(@"\n%@",parameters)
}

- (void)sendJson:(NSString *)message {
    if (!self.isConnect) return;
    
    if (_socket.readyState != SR_OPEN) {
        if (_socket.readyState == SR_CLOSING || _socket.readyState == SR_CLOSED) return;
        __weak typeof(self) weak_self = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weak_self sendJson:message];
        });
        return;
    }

    
    [self.socket send:message];
    RunsLogEX(@"\n%@",[GKSimpleAPI jsonConvertObject:message])
}

- (void)registeredListenWithType:(NSInteger)type callback:(SocketCallback)callback {
    if (!self.callbackMap) {
        self.callbackMap = [NSMapTable weakToWeakObjectsMapTable];
    }
    SafeSetObject(self.callbackMap, callback, @(type))
}

- (void)removeListenWithType:(NSInteger)type {
    [self.callbackMap removeObjectForKey:@(type)];
}

#pragma mark -- SRWebSocketDelegate 

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    RunsLogEX(@"webSocketDidOpen");
    
    _reconnectCount = 0;
    _isConnect = YES;
    _isManuallyDisconnect = NO;
    
    if (_isReconnect) {
        _isReconnect = NO;
        [self showReconnectSuccessTips];
    }
    
    [delegates enumerateObjectsUsingBlock:^(id<RunsWebSocketDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(socket:didOpenWithHost:)]) {
            [obj socket:self didOpenWithHost:_host];
        }
    }];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSDictionary *jsonMap = [GKSimpleAPI dataConversionAdaption:message];
    RunsLogEX(@"\n%@",jsonMap ? jsonMap : message)
    
    [delegates enumerateObjectsUsingBlock:^(id<RunsWebSocketDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(socket:didReceiveMessage:)]) {
            *stop = [obj socket:self didReceiveMessage:jsonMap];
        }
    }];
    
    RunsWebSocketRespone *respone = [RunsWebSocketRespone mj_objectWithKeyValues:jsonMap];
    SocketCallback callback = [self.callbackMap objectForKey:respone.type];
    if (callback) {
        callback(jsonMap);
        return;
    }
//    RunsLogEX(@"type = %@, 没有对应的 block 监听回调， 响应被抛弃",respone.type)
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSArray<id<RunsWebSocketDelegate>> *array = [delegates copy];
    [array enumerateObjectsUsingBlock:^(id<RunsWebSocketDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj respondsToSelector:@selector(socket:didFailWithError:)]) {
            [obj socket:self didFailWithError:error];
        }
        if (_isManuallyDisconnect) {
            [delegates removeObject:obj];
        }
    }];
    
    RunsLogEX(@"didFailWithError error : %@",error);
    [self delayReconect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSArray<id<RunsWebSocketDelegate>> *array = [delegates copy];
    [array enumerateObjectsUsingBlock:^(id<RunsWebSocketDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj respondsToSelector:@selector(socket:didCloseWithCode:reason:)]) {
            [obj socket:self didCloseWithCode:code reason:reason];
        }
        if (_isManuallyDisconnect) {
            [delegates removeObject:obj];
        }
    }];

    RunsLogEX(@"didCloseWithCode code = %ld, reason = %@, clean = %d",(long)code, reason, wasClean);
    [self delayReconect];
}

- (void)delayReconect {
    __weak typeof(self) weak_self = self;
    float interval = 0;
    if (_reconnectCount > 0) {
        interval = 1;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_self checkReconnect];
    });
}


- (void)checkReconnect {
    if (_isConnect) return;
    if (_isManuallyDisconnect) return;
    if (_reconnectCount < _reconnectMaxCount) {
        [self reconnect];
        _reconnectCount += 1;
        [self showReconnectTips];
        RunsLogEX(@"正在进行第%lu次重连socket",(unsigned long)self.reconnectCount)
        
        return;
    }
    _socket.delegate = nil;
    RunsLogEX(@"达到最大重连数 链接失败 断开socket")
}

static int ToastShowCount = 0;
- (void)showReconnectTips {
    __weak typeof(self) weak_self = self;
    NSString *message = [NSString stringWithFormat:@"连接不稳定，第%lu次自动重连中…",_reconnectCount];
    [UIApplication.sharedApplication.keyWindow makeToast:message duration:2.f position:CSToastPositionCenter completed:^(BOOL didTap) {
        ToastShowCount += 1;
        if (ToastShowCount < weak_self.reconnectMaxCount)  return;
        if (weak_self.reconnectCount >= weak_self.reconnectMaxCount) {
            ToastShowCount = 0;
            [weak_self showDisconnectTips];
        }
    }];
    [CSToastManager setQueueEnabled:NO];
}

- (void)showDisconnectTips {
    __weak typeof(self) weak_self = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络连接断开了" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"重新连接" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weak_self.reconnectCount = 0;
        [weak_self checkReconnect];
    }]];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)showReconnectSuccessTips {
    [CSToastManager setQueueEnabled:YES];
    [UIApplication.sharedApplication.keyWindow makeToast:@"重新连接成功" duration:1.f position:CSToastPositionCenter];
}

@end
