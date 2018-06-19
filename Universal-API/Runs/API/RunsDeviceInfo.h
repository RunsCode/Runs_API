//
//  RunsDeviceInfo.h
//  OU_iPhone
//
//  Created by runs on 2017/5/19.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//版本比较
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef struct disk_attribute {
    long long free_size;
    long long system_size;
    long long used_size;
} DiskAttribute;

@interface RunsDeviceInfo : NSObject
+ (NSString *)appName;
+ (NSString *)cameraUsageDescription;
+ (NSString *)microphoneUsageDescription;
+ (NSString *)hostname;
+ (NSString *)deviceToken;
+ (NSString *)localIPAddress;
+ (NSString *)iosVersion;
+ (NSString *)appVersion;
+ (NSString *)appBuild;
+ (NSString *)appVersionNumber;
+ (NSString *)iosModel;
+ (UIDeviceBatteryState)batteryState;
+ (NSString *)totalDiskspace;
+ (NSString *)freeDiskspace;
+ (DiskAttribute)diskattributes;
+ (NSString *)currentIPAddress:(BOOL)preferIPv4;
+ (NSString *)platformType;
@end
