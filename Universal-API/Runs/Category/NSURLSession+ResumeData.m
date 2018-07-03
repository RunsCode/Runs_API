//
//  NSURLSession+ResumeData.m
//  OU_iPhone
//
//  Created by runs on 2018/6/21.
//  Copyright © 2018 Olacio. All rights reserved.
//

#import "NSURLSession+ResumeData.h"

NSString * const NSURLSessionResumeCurrentRequest  = @"NSURLSessionResumeCurrentRequest";
NSString * const NSURLSessionResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
NSString * const RunsKeyedArchiveRootObjectKey     = @"NSKeyedArchiveRootObjectKey";

static NSData * fixedRequestData(NSData *requestData) {
    if (!requestData) return nil;
    if ([NSKeyedUnarchiver unarchiveObjectWithData:requestData] != nil)  return requestData;
    
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:requestData options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    if (!archive) return nil;
    
    NSInteger k = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",k]] != nil)  k += 1;
        NSInteger i = 0;
        while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]] != nil) {
            NSMutableArray *arr = archive[@"$objects"];
            NSMutableDictionary *dic = arr[1];
            id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
            if (obj) {
                [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
                [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
                [arr replaceObjectAtIndex:1 withObject:dic];
                archive[@"$objects"] = arr;
            }
            i++;
        }
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive[@"$top"] objectForKey:RunsKeyedArchiveRootObjectKey] != nil) {
        [archive[@"$top"] setObject:archive[@"$top"][RunsKeyedArchiveRootObjectKey] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:RunsKeyedArchiveRootObjectKey];
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return result;
}



@interface NSMutableDictionary(Private)
- (NSMutableDictionary * (^) (NSString *key))exchange;
@end

@implementation NSMutableDictionary(Private)

- (NSMutableDictionary * (^) (NSString *key))exchange {
    return ^(NSString *key) {
        NSData *requestData = fixedRequestData(self[key]);
        self[key] = requestData;
        return self;
    };
}

@end

@implementation NSURLSession (ResumeData)

- (NSMutableDictionary *)fetchResumeMapWithResumeData:(NSData *)data {
    NSMutableDictionary *iresumeDictionary = nil;
    if (@available(iOS 10.0, *)) {
        id root = nil;
        id  keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        @try {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:RunsKeyedArchiveRootObjectKey error:nil];
            if (!root) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        } @catch(NSException *exception) {
            NSLog(@"%@", exception);
        }
        [keyedUnarchiver finishDecoding];
        iresumeDictionary = [root mutableCopy];
        return  iresumeDictionary;
    }
    iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    return iresumeDictionary;
}

- (NSData *)fixedResumeData:(NSData *)resumeData {
    if (!resumeData) return nil;
    NSMutableDictionary *resumeMap = [self fetchResumeMapWithResumeData:resumeData];
    if (!resumeMap) return nil;
    resumeMap.exchange(NSURLSessionResumeCurrentRequest).exchange(NSURLSessionResumeOriginalRequest);
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeMap format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return result;
}

- (NSURLSessionDownloadTask *)rs_downloadTaskWithFixedResumeData:(NSData *)resumeData {
    NSData *fixedResumeData = [self fixedResumeData:resumeData];
    fixedResumeData = fixedResumeData ? fixedResumeData : resumeData;
    NSURLSessionDownloadTask *task = [self downloadTaskWithResumeData:fixedResumeData];
    NSMutableDictionary *resumeMap = [self fetchResumeMapWithResumeData:fixedResumeData];
    if (!resumeMap) return task;
    if (!task.originalRequest) {
        NSData *originalRqData = resumeMap[NSURLSessionResumeOriginalRequest];
        NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalRqData ];
        if (originalRequest) {
            [task setValue:originalRequest forKey:@"originalRequest"];
        }
    }
    if (!task.currentRequest) {
        NSData *currentRqData = resumeMap[NSURLSessionResumeCurrentRequest];
        NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentRqData];
        if (currentRequest) {
            [task setValue:currentRequest forKey:@"currentRequest"];
        }
    }
    return task;
}

@end













