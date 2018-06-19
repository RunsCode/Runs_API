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
        delegates = [[NSMutableArray alloc] init];
        _reconnectMaxCount = WEB_SOCKET_RECONNECT_COUNT;
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
    if (_isConnect) {
        RunsLogEX(@"已经连接成功 取消继续重连")
        return;
    }
    //
    _host = URL;
    //
    [self close];
    if (!_host) {
        RunsLogEX(@"连接WebSocket失败， Host 为空")
        return;
    }
    _socket = [[SRWebSocket alloc] initWithURL:URL];
    _socket.delegate = self;
    [_socket open];
    //
    RunsLogEX(@"socket 正在连接 host : %@",_host.absoluteString)
}

- (void)reconnect {
    if (_isReconnect) {
        RunsLogEX(@"已经在重连中 ...")
        return;
    }
    RunsLogEX(@"socket 将要进行重连 ...")
    _isReconnect = YES;
    [self connectWithURL:_host];
}

- (void)close {
    RunsLogEX(@"开始关闭 socket")
    if (!_isConnect) {
        RunsLogEX(@"关闭socket 成功")
//        RunsLogEX(@"关闭失败 已经关闭哦")
         return;
    }
    [_socket close];
    [self clean];
    RunsLogEX(@"关闭socket 成功")
}

- (void)closeWithManually:(BOOL)isManually {
    RunsLogEX(@"手动关闭socket : %@", isManually ? @"YES" : @"NO")
    if (!_isConnect){
        RunsLogEX(@"手动关闭socket失败，已经关闭哦")
        return;
    }
    _isManuallyDisconnect = isManually;
    [self close];
}

- (void)forcedReconnect {
    _isReconnect = NO;
    [self closeWithManually:NO];
    [self reconnect];
}

- (void)clean {
    _isConnect = NO;
}

- (void)setReconnectMaxCount:(NSUInteger)reconnectMaxCount {
    _reconnectMaxCount = reconnectMaxCount > 0 ? reconnectMaxCount : WEB_SOCKET_RECONNECT_COUNT;
}

- (void)sendMap:(NSDictionary *)parameters {
    if (!_isConnect) return;
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
    [_socket send:jsonString];
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
    //
    [_socket send:message];
#ifdef DEBUG
    NSDictionary *jsonMap = [GKSimpleAPI jsonConvertObject:message];
    if (LOG_HEART_BEAT) {
        RunsLogEX(@"\n%@",jsonMap ? jsonMap : message)
    }else {
        if ([jsonMap[@"type"] integerValue] != ServerHeartBeatMessage) {
            RunsLogEX(@"\n%@",jsonMap ? jsonMap : message)
        }
    }
#endif
}

- (void)registeredListenWithType:(NSInteger)type callback:(SocketCallback)callback {
    if (!_callbackMap) {
        _callbackMap = [NSMapTable weakToWeakObjectsMapTable];
    }
    id key = @(type);
    id obj = callback;
    id map  = _callbackMap;
    if(_callbackMap){
        if(key) {
            if(obj) {
                [map setObject:obj forKey:key];
            }else{
                RunsLog(@"字典插入对象为空 key = %@",key);
            }
        }else{
            RunsLog(@"字典插入key为空");
        }
    } else {
        RunsLog(@"字典为空 无法插入数据");
    }
}

- (void)removeListenWithType:(NSInteger)type {
    [_callbackMap removeObjectForKey:@(type)];
}

#pragma mark -- SRWebSocketDelegate 

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    RunsLogEX(@"socket WebSocket连接成功");
    _reconnectCount = 0;
    _isConnect = YES;
    _isManuallyDisconnect = NO;
    
    if (_isReconnect) {
        _isReconnect = NO;
        [self showReconnectSuccessTips];
    }
    RunsLogEX(@"socket 代理数 ： %lu",(unsigned long)delegates.count)
    [delegates enumerateObjectsUsingBlock:^(id<RunsWebSocketDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(socket:didOpenWithHost:)]) {
            [obj socket:self didOpenWithHost:_host];
        }
    }];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSDictionary *jsonMap = [GKSimpleAPI dataConversionAdaption:message];
    
#ifdef DEBUG
    if (LOG_HEART_BEAT) {
        RunsLogEX(@"\n%@",jsonMap ? jsonMap : message)
    }else {
        if ([jsonMap[@"type"] integerValue] != ServerHeartBeatMessage) {
            RunsLogEX(@"\n%@",jsonMap ? jsonMap : message)
        }else {
            RunsLogEX(@"蹦蹦蹦")
        }
    }
#endif

    [delegates enumerateObjectsUsingBlock:^(id<RunsWebSocketDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(socket:didReceiveMessage:)]) {
            [obj socket:self didReceiveMessage:jsonMap];
        }
    }];
    
    RunsWebSocketResponse *respone = [RunsWebSocketResponse mj_objectWithKeyValues:jsonMap];
    SocketCallback callback = [_callbackMap objectForKey:respone.type];
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
    RunsLogEX(@"didFailWithError error : %@",error.localizedDescription);
    _isConnect = NO;
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
    _isConnect = NO;
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
    if (![RunsNetworkMonitor NetworkIsReachableWithShowTips:NO]) return;
    if (_reconnectCount < _reconnectMaxCount) {
        _reconnectCount += 1;
        RunsLogEX(@"正在进行第%lu次重连socket",(unsigned long)_reconnectCount)
        [self reconnect];
        [self showReconnectTips];
        return;
    }
    _socket.delegate = nil;
    RunsLogEX(@"达到最大重连数 链接失败 断开socket")
}

static int ToastShowCount = 0;
- (void)showReconnectTips {
    __weak typeof(self) weak_self = self;
//    NSString *message = [NSString stringWithFormat:@"连接不稳定，第%lu次自动重连中…",(unsigned long)_reconnectCount];
    NSString *message = @"    正在刷新...    ";
    [UIApplication.sharedApplication.keyWindow makeToast:message duration:1.f position:CSToastPositionCenter completed:^(BOOL didTap) {
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
//    [UIApplication.sharedApplication.keyWindow makeToast:@"重新连接成功" duration:3.f position:CSToastPositionCenter];
    [CSToastManager setQueueEnabled:YES];
    [UIApplication.sharedApplication.keyWindow makeToast:@"    刷新成功    " duration:1.f position:CSToastPositionCenter];
}

@end
