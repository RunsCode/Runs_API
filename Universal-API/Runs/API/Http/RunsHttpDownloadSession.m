//
// Created by runs on 2018/3/28.
// Copyright (c) 2018 Olacio. All rights reserved.
//

#import "RunsHttpDownloadSession.h"
#import <UIKit/UIKit.h>
#import <RunsMacroConstant.h>
#import "NSObject+CommandForwarding.h"
#import "NSURLSession+ResumeData.h"

@interface RunsHttpDownloadSession ()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) RunsDownloaderCallback downloadCallback;
@property (nonatomic, strong) RunsProgressCallback progressCallback;
@property (nonatomic, strong, readwrite) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong, readwrite) NSURLSession *session;
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) BOOL isTerminate;
@end

@implementation RunsHttpDownloadSession

- (void)dealloc {
    [self rs_releaseCommadnForwardingEngine];
    RunsReleaseLog()
}

- (void)cancelByProducingResumeData:(void (^)(NSString * _Nonnull))completed {
    _isTerminate = self.isRunning;
    if (!_isTerminate) {
        if (completed) completed(_identifier);
        return;
    }
    __weak typeof(self) weak_self = self;
    [_downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        [weak_self.commandEngine executeNumberCommand:RunsDownloaderInterrupt parameter:resumeData];
        if (completed) completed(weak_self.identifier);
    }];
}

- (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)urlString handleCallback:(RunsDownloaderCallback)completionCallback progressCallback:(RunsProgressCallback)progressCallback {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSError *error = [NSError errorWithDomain:@"下载链接为空" code:-1 userInfo:nil];
        if (completionCallback) completionCallback(nil, error);
        [self.commandEngine executeNumberCommand:RunsDownloaderError parameter:error];
       return nil;
    }
    _downloadCallback = completionCallback;
    _progressCallback = progressCallback;
    //
    _identifier = _identifier.length > 0 ? _identifier : urlString;
    //
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_identifier];
    _downloaderQueue = _downloaderQueue ? _downloaderQueue : [NSOperationQueue.alloc init];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:_downloaderQueue];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
    //
    _session = session;
    _downloadTask = task;
    //
    return task;
}

- (NSURLSessionDownloadTask *)downloadWithResumeData:(NSData *)data handleCallback:(RunsDownloaderCallback)completionCallback progressCallback:(RunsProgressCallback)progressCallback {
    if (!data) {
        NSError *error = [NSError errorWithDomain:@"续传数据为空" code:-1 userInfo:nil];
        if (completionCallback) completionCallback(nil, error);
        [self.commandEngine executeNumberCommand:RunsDownloaderError parameter:error];
        return nil;
    }
    _downloadCallback = completionCallback;
    _progressCallback = progressCallback;
    //
    _identifier = _identifier.length > 0 ? _identifier : NON_STRING;
    //
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_identifier];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:_downloaderQueue];
    if (@available(iOS 10.0, *)) {
        _downloadTask = [session rs_downloadTaskWithFixedResumeData:data];
    } else {
        _downloadTask = [session downloadTaskWithResumeData:data];
    }
    _session = session;
    return _downloadTask;
}

- (BOOL)isRunning {
    return _downloadTask.state == NSURLSessionTaskStateRunning;
}

- (void)suspend {
    RunsLogEX(@"暂停下载")
    __weak typeof(self) weak_self = self;
    [_downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        [weak_self.commandEngine executeNumberCommand:RunsDownloaderInterrupt parameter:resumeData];
        weak_self.resumeData = resumeData;
        weak_self.downloaderQueue.suspended = YES;
        RunsLogEX(@"保存续传数据 大小 ： %lu", (unsigned long)resumeData.length)
    }];
}

- (void)resume {
    
    _downloaderQueue.suspended = NO;
    if (!_resumeData) {
        [_downloadTask resume];
        RunsLogEX(@"直接恢复下载")
        return;
    }
    RunsLogEX(@"断点续传下载")
    [self downloadWithResumeData:_resumeData handleCallback:_downloadCallback progressCallback:_progressCallback];
    [_downloadTask resume];
    _resumeData = nil;
}

- (void)cancel {
    [_downloadTask cancel];
    [_session invalidateAndCancel];
}

#pragma mark -- NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didFinishDownloadingToURL:(NSURL*)location {
    //断开URLSession对self的强引用 否则就会引起内存泄漏
    [session finishTasksAndInvalidate];
    if (_downloadCallback) {
        _downloadCallback(location, nil);
    }
    [self.commandEngine executeNumberCommand:RunsDownloaderFinish parameter:location];
    [self.commandEngine executeNumberCommand:RunsDownloaderBackgroundFinish parameter:session.configuration.identifier];
}

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (NSURLSessionTaskStateRunning != downloadTask.state) {
        RunsLogEX(@"NSURLSessionTaskStateRunning != downloadTask.state")
        return;
    }
    CGFloat progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    if (_progressCallback) {
        RunsLogEX(@"下载进度 %0.3f", progress)
        _progressCallback(progress);
    } else {
        [self.commandEngine executeNumberCommand:RunsDownloaderProgress parameter:@(progress)];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    RunsLog(@"RunsHttpDownloadSession: Resume download at %lld", fileOffset);
}

- (void)URLSession:(NSURLSession *)session taskIsWaitingForConnectivity:(NSURLSessionTask *)task {
    RunsLogEX(@"taskIsWaitingForConnectivity")
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    RunsLogEX(@"didBecomeInvalidWithError error : %@", error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (_isTerminate || !error) {
        [session finishTasksAndInvalidate];
        return;
    }
    
    if (!self.isRunning) {
        return;
    }
    
    if (_downloadCallback) {
        _downloadCallback(nil, error);
    }
    [self.commandEngine executeNumberCommand:RunsDownloaderError parameter:error];

    //保存恢复数据，以备继续下载
    [session finishTasksAndInvalidate];
    _resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
    [self.commandEngine executeNumberCommand:RunsDownloaderInterrupt parameter:_resumeData];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    [self.commandEngine executeNumberCommand:RunsDownloaderBackgroundFinish parameter:session.configuration.identifier];
}

@end
