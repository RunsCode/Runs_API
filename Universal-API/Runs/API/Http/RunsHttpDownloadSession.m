//
// Created by runs on 2018/3/28.
// Copyright (c) 2018 Olacio. All rights reserved.
//

#import "RunsHttpDownloadSession.h"

@interface RunsHttpDownloadSession ()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) RunsDownloaderCallback downloadCallback;
@property (nonatomic, strong) RunsProgressCallback progressCallback;
@property (nonatomic, strong, readwrite) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSData *resumeData;
@property(nonatomic, assign) float progress;
@end

@implementation RunsHttpDownloadSession

- (void)dealloc {
    RunsReleaseLog()
}

- (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)urlString handleCallback:(RunsDownloaderCallback)completionCallback progressCallback:(RunsProgressCallback)progressCallback {
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        if (completionCallback) {
            completionCallback(nil, [NSError errorWithDomain:@"链接地址错误" code:-1 userInfo:nil]);
        }
        return nil;
    }
    _downloadCallback = completionCallback;
    _progressCallback = progressCallback;
    //
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:urlString];
    _downloaderQueue = _downloaderQueue ? _downloaderQueue : [[NSOperationQueue alloc] init];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:_downloaderQueue];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
//    task.priority = NSURLSessionTaskPriorityHigh;
    [task resume];
    //
    _session = session;
    _downloadTask = task;
    //
    return task;
}

- (BOOL)isRunning {
    return _downloadTask.state == NSURLSessionTaskStateRunning ;
}

- (void)suspend {
    [_downloadTask suspend];
}

- (void)resume {
    if (!_resumeData) {
        RunsLog(@"断点数据不存在无法继续下载，进行重新下载")
        [_downloadTask resume];
        return;
    }
    _downloadTask = [_session downloadTaskWithResumeData:_resumeData];
    [_downloadTask resume];
}

- (void)cancel {
    [_downloadTask cancel];
    [_session invalidateAndCancel];
    __weak typeof(self) weak_self = self;
    [_downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        weak_self.resumeData = resumeData;
    }];
}

#pragma mark -- NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didFinishDownloadingToURL:(NSURL*)location {
    //断开URLSession对self的强引用 否则就会引起内存泄漏
    if (_downloadCallback) {
        _downloadCallback(location, nil);
    }
    [session finishTasksAndInvalidate];
}

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    if (NSURLSessionTaskStateRunning != downloadTask.state) {
        RunsLogEX(@"NSURLSessionTaskStateRunning != downloadTask.state")
        return;
    }
    _progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    if (_progressCallback) {
        RunsLogEX(@"下载进度 %0.3f", _progress)
        _progressCallback(_progress);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    RunsLog(@"RunsHttpDownloadSession: Resume download at %lld", fileOffset);
}

- (void)URLSession:(NSURLSession *)session taskIsWaitingForConnectivity:(NSURLSessionTask *)task {
    RunsLogEX(@"taskIsWaitingForConnectivity")
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    RunsLogEX(@"didBecomeInvalidWithError erroR : %@", error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (!error) {
        [session finishTasksAndInvalidate];
        return;
    }
    if (_downloadCallback) {
        _downloadCallback(nil, error);
    }
    //保存恢复数据，以备继续下载
    [session finishTasksAndInvalidate];
    _resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    
}

@end
