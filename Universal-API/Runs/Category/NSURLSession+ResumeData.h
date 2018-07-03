//
//  NSURLSession+ResumeData.h
//  OU_iPhone
//
//  Created by runs on 2018/6/21.
//  Copyright © 2018 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (ResumeData)
- (NSURLSessionDownloadTask *)rs_downloadTaskWithFixedResumeData:(NSData *)resumeData;
@end
