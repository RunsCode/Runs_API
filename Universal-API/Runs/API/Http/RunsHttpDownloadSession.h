//
// Created by runs on 2018/3/28.
// Copyright (c) 2018 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RunsDownloaderState) {
    RunsDownloaderError             = 0,
    RunsDownloaderProgress          = 1,
    RunsDownloaderFinish            = 2,
    RunsDownloaderInterrupt         = 3,
    RunsDownloaderBackgroundFinish  = 4,
    RunsDownloaderCacheResumeData   = 5,
    RunsDownloaderStateDefault      = RunsDownloaderError,
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^RunsDownloaderCallback)(NSURL *_Nullable location, NSError *_Nullable error);
typedef void (^RunsProgressCallback)(float progress);

@interface RunsHttpDownloadSession : NSObject
@property (nonatomic, assign, readonly) BOOL isRunning;
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong, readonly) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *downloaderQueue;
@property (nonatomic, copy) NSString *identifier;
- (void)cancelByProducingResumeData:(void(^)(NSString *identifier))completed;
/**
 下载指定URL文件 返回缓存地址 以及进度

 @param urlString 下载地址
 @param completionCallback 下载完成临时地址回调或者错误
 @param progressCallback 实时进度回调
 @return task
 */
- (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)urlString handleCallback:(RunsDownloaderCallback _Nullable)completionCallback progressCallback:
        (RunsProgressCallback _Nullable)progressCallback;
- (NSURLSessionDownloadTask *)downloadWithResumeData:(NSData *)data handleCallback:(RunsDownloaderCallback _Nullable)completionCallback progressCallback:
(RunsProgressCallback _Nullable)progressCallback;

- (void)suspend;
- (void)resume;
- (void)cancel;

@end
NS_ASSUME_NONNULL_END
