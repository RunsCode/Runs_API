//
// Created by runs on 2018/3/28.
// Copyright (c) 2018 Olacio. All rights reserved.
//

#import "RunsHttpDownloadSession.h"

@interface RunsHttpDownloadSession ()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong) RunsDownloadCallback downloadCallback;
@property (nonatomic, strong) RunsProgressCallback progressCallback;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSData *resumeData;
@property(nonatomic, assign) float progress;
@end

@implementation RunsHttpDownloadSession

- (void)dealloc {
    RunsReleaseLog()
}

- (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)urlString handleCallback:(RunsDownloadCallback)completionCallback progressCallback:(RunsProgressCallback)progressCallback {
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
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
    [task resume];
    //
    _session = session;
    _downloadTask = task;
    //
    return task;
}

- (void)suspend {
    __weak typeof(self) weak_self = self;
    [_downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        weak_self.resumeData = resumeData;
    }];
}

- (void)resume {
    if (!_resumeData) {
        RunsLog(@"断点数据不存在无法继续下载，进行重新下载")
        [_downloadTask resume];
        return;;
    }
    _downloadTask = [_session downloadTaskWithResumeData:_resumeData];
    [_downloadTask resume];
}


#pragma mark -- NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didFinishDownloadingToURL:(NSURL*)location {
    //断开URLSession对self的强引用 否则就会引起内存泄漏
    [session finishTasksAndInvalidate];
    if (_downloadCallback) {
        _downloadCallback(location, nil);
    }
}

- (void)URLSession:(NSURLSession*)session downloadTask:(NSURLSessionDownloadTask*)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    _progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
    if (_progressCallback) {
        _progressCallback(_progress);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    RunsLog(@"RunsHttpDownloadSession: Resume download at %lld", fileOffset);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    [session finishTasksAndInvalidate];
    if (!error) {
        return;
    }
    if (_downloadCallback) {
        _downloadCallback(nil, error);
    }
    //保存恢复数据，以备继续下载
    _resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
}

@end
