//
// Created by runs on 2018/3/28.
// Copyright (c) 2018 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RunsDownloaderCallback)(NSURL *_Nullable location, NSError *_Nullable error);
typedef void (^RunsProgressCallback)(float progress);

@interface RunsHttpDownloadSession : NSObject
@property (nonatomic, assign, readonly) BOOL isRunning;
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSOperationQueue *downloaderQueue;

/**
 下载指定URL文件 返回缓存地址 以及进度

 @param urlString 下载地址
 @param completionCallback 下载完成临时地址回调或者错误
 @param progressCallback 实时进度回调
 @return task
 */
- (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)urlString handleCallback:(RunsDownloaderCallback)completionCallback progressCallback:
        (RunsProgressCallback)progressCallback;

- (void)suspend;
- (void)resume;
- (void)cancel;

@end
NS_ASSUME_NONNULL_END
