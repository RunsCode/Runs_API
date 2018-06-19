//
//  RunsDeviceInfo.m
//  OU_iPhone
//
//  Created by runs on 2017/5/19.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "RunsDeviceInfo.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#include <sys/utsname.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#define DEVICE_INFO_IOS_CELLULAR    @"pdp_ip0"
#define DEVICE_INFO_IOS_WIFI        @"en0"
#define DEVICE_INFO_IOS_VPN         @"utun0"
#define DEVICE_INFO_IP_ADDR_IPv4    @"ipv4"
#define DEVICE_INFO_IP_ADDR_IPv6    @"ipv6"

@implementation RunsDeviceInfo

+ (NSString *)appName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *value = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    return value;
}

+ (NSString *)cameraUsageDescription {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *value = [infoDictionary objectForKey:@"NSCameraUsageDescription"];
    return value;
}

+ (NSString *)microphoneUsageDescription {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *value = [infoDictionary objectForKey:@"NSMicrophoneUsageDescription"];
    return value;
}

+ (NSString *) hostname {
    char baseHostName[256];
    int success = gethostname(baseHostName, 255);
    if (success != 0) return nil;
    baseHostName[255] = '\0';
    
#if TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s", baseHostName];
#else
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#endif
}

+ (NSString *)localIPAddress {
    return nil;
}

+ (NSString *)deviceToken {
    return @"";
}

+ (NSString *)iosVersion {
    UIDevice *device = [UIDevice currentDevice];
    return [device systemVersion];
}

+ (NSString *)iosModel {
    UIDevice *device = [UIDevice currentDevice];
    return [device model];
}


+ (NSString *)appVersion {
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    if (!appVersion || [appVersion length] == 0)
        appVersion = @"0.0";
    return appVersion;
}

+ (NSString *)appBuild {
    NSString *appBuild = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    if (!appBuild || [appBuild length] == 0)
        appBuild = @"0.0";
    return appBuild;
}

+ (NSString *)appVersionNumber {
    NSString *appV = [RunsDeviceInfo appVersion];
    char c;
    for (int i = 0; i < [appV length]; ++ i) {
        c = (char) [appV characterAtIndex:i];
        if (c >= '0' && c <= '9') {
            appV = [appV substringFromIndex:i];
            break;
        }
    }
    
    for (int i = (int)[appV length] - 1; i >= 0; -- i) {
        c = (char) [appV characterAtIndex:(NSUInteger) i];
        if (c >= '0' && c <= '9') {
            appV = [appV substringToIndex:(NSUInteger) (i + 1)];
            break;
        }
    }
    
    return appV;
}


+ (NSString *)freeDiskspace {
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *freeFileSystemSizeInBytes = dictionary[NSFileSystemFreeSize];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    return [NSString stringWithFormat:@"%llu", ((totalFreeSpace/1024ll)/1024ll)];
}

+ (NSString *)totalDiskspace {
    uint64_t totalSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = dictionary[NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
    }
    
    return [NSString stringWithFormat:@"%llu", ((totalSpace/1024ll)/1024ll)];
}

+ (DiskAttribute)diskattributes {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [NSFileManager.defaultManager attributesOfFileSystemForPath:paths.lastObject error:nil];
    
    DiskAttribute attribute;
    attribute.system_size = [dictionary[NSFileSystemSize] longLongValue] / (1024*1024);
    attribute.free_size = [dictionary[NSFileSystemFreeSize] longLongValue] / (1024*1024);
    attribute.used_size = (attribute.system_size - attribute.free_size);
    return attribute;
}

+ (UIDeviceBatteryState)batteryState {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    
    return [[UIDevice currentDevice] batteryState];
}

+ (NSString *)currentIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ DEVICE_INFO_IOS_VPN @"/" DEVICE_INFO_IP_ADDR_IPv4, DEVICE_INFO_IOS_VPN @"/" DEVICE_INFO_IP_ADDR_IPv6, DEVICE_INFO_IOS_WIFI @"/" DEVICE_INFO_IP_ADDR_IPv4, DEVICE_INFO_IOS_WIFI @"/" DEVICE_INFO_IP_ADDR_IPv6, DEVICE_INFO_IOS_CELLULAR @"/" DEVICE_INFO_IP_ADDR_IPv4, DEVICE_INFO_IOS_CELLULAR @"/" DEVICE_INFO_IP_ADDR_IPv6 ] :
    @[ DEVICE_INFO_IOS_VPN @"/" DEVICE_INFO_IP_ADDR_IPv6, DEVICE_INFO_IOS_VPN @"/" DEVICE_INFO_IP_ADDR_IPv4, DEVICE_INFO_IOS_WIFI @"/" DEVICE_INFO_IP_ADDR_IPv6, DEVICE_INFO_IOS_WIFI @"/" DEVICE_INFO_IP_ADDR_IPv4, DEVICE_INFO_IOS_CELLULAR @"/" DEVICE_INFO_IP_ADDR_IPv6, DEVICE_INFO_IOS_CELLULAR @"/" DEVICE_INFO_IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [[self class] fetchIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)fetchIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = DEVICE_INFO_IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = DEVICE_INFO_IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}


+ (NSString *)platformType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *result = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString *type;
    
    if ([result isEqualToString:@"i386"])           type = @"Simulator";
    //ipod
    if ([result isEqualToString:@"iPod1,1"])        type = @"iPod Touch 1G";
    if ([result isEqualToString:@"iPod2,1"])        type = @"iPod Touch 2G";
    if ([result isEqualToString:@"iPod3,1"])        type = @"iPod Touch 3G";
    if ([result isEqualToString:@"iPod4,1"])        type = @"iPod Touch 4G";
    if ([result isEqualToString:@"iPod5,1"])        type = @"iPod Touch 5G";
    if ([result isEqualToString:@"iPod7,1"])        type = @"iPod Touch 6G";
    //ipad
    if ([result isEqualToString:@"iPad1,1"])        type = @"iPad 1G";
    if ([result isEqualToString:@"iPad2,1"])        type = @"iPad 2 (Wi-Fi)";
    if ([result isEqualToString:@"iPad2,2"])        type = @"iPad 2 (GSM)";
    if ([result isEqualToString:@"iPad2,3"])        type = @"iPad 2 (CDMA)";
    if ([result isEqualToString:@"iPad2,4"])        type = @"iPad 2 (Wi-Fi, revised)";
    if ([result isEqualToString:@"iPad2,5"])        type = @"iPad mini (Wi-Fi)";
    if ([result isEqualToString:@"iPad2,6"])        type = @"iPad mini (A1454)";
    if ([result isEqualToString:@"iPad2,6"])        type = @"iPad mini (A1455)";
    if ([result isEqualToString:@"iPad3,1"])        type = @"iPad (3rd gen, Wi-Fi)";
    if ([result isEqualToString:@"iPad3,2"])        type = @"iPad (3rd gen, Wi-Fi+LTE Verizon)";
    if ([result isEqualToString:@"iPad3,3"])        type = @"iPad (3rd gen, Wi-Fi+LTE AT&T)";
    if ([result isEqualToString:@"iPad3,4"])        type = @"iPad (4th gen, Wi-Fi)";
    if ([result isEqualToString:@"iPad3,5"])        type = @"iPad (4th gen, A1459)";
    if ([result isEqualToString:@"iPad3,6"])        type = @"iPad (4th gen, A1460)";
    if ([result isEqualToString:@"iPad4,1"])        type = @"iPad Air (Wi-Fi)";
    if ([result isEqualToString:@"iPad4,2"])        type = @"iPad Air (Wi-Fi+LTE)";
    if ([result isEqualToString:@"iPad4,3"])        type = @"iPad Air (Rev)";
    if ([result isEqualToString:@"iPad4,4"])        type = @"iPad mini 2 (Wi-Fi)";
    if ([result isEqualToString:@"iPad4,5"])        type = @"iPad mini 2 (Wi-Fi+LTE)";
    if ([result isEqualToString:@"iPad4,6"])        type = @"iPad mini 2 (Rev)";
    if ([result isEqualToString:@"iPad4,7"])        type = @"iPad mini 3 (Wi-Fi)";
    if ([result isEqualToString:@"iPad4,8"])        type = @"iPad mini 3 (A1600)";
    if ([result isEqualToString:@"iPad4,9"])        type = @"iPad mini 3 (A1601)";
    if ([result isEqualToString:@"iPad5,1"])        type = @"iPad mini 4 (Wi-Fi)";
    if ([result isEqualToString:@"iPad5,2"])        type = @"iPad mini 4 (Wi-Fi+LTE)";
    if ([result isEqualToString:@"iPad5,3"])        type = @"iPad Air 2 (Wi-Fi)";
    if ([result isEqualToString:@"iPad5,4"])        type = @"iPad Air 2 (Wi-Fi+LTE)";
    if ([result isEqualToString:@"iPad6,7"])        type = @"iPad Pro (Wi-Fi)";
    if ([result isEqualToString:@"iPad6,8"])        type = @"iPad Pro (Wi-Fi+LTE)";
    //iphone
    if ([result isEqualToString:@"iPhone1,1"])      type = @"iPhone";
    if ([result isEqualToString:@"iPhone1,2"])      type = @"iPhone 3G";
    if ([result isEqualToString:@"iPhone2,1"])      type = @"iPhone 3Gs";
    if ([result isEqualToString:@"iPhone3,1"])      type = @"iPhone 4 (GSM)";
    if ([result isEqualToString:@"iPhone3,3"])      type = @"iPhone 4 (CDMA)";
    if ([result isEqualToString:@"iPhone4,1"])      type = @"iPhone 4s";
    if ([result isEqualToString:@"iPhone5,1"])      type = @"iPhone 5 (A1428)";
    if ([result isEqualToString:@"iPhone5,2"])      type = @"iPhone 5";
    if ([result isEqualToString:@"iPhone5,3"])      type = @"iPhone 5c (A1456/A1532)";
    if ([result isEqualToString:@"iPhone5,4"])      type = @"iPhone 5c (A1507/A1516/A1529)";
    if ([result isEqualToString:@"iPhone6,1"])      type = @"iPhone 5s (A1433/A1453)";
    if ([result isEqualToString:@"iPhone6,2"])      type = @"iPhone 5s (A1457/A1518/A1530)";
    if ([result isEqualToString:@"iPhone7,2"])      type = @"iPhone 6";
    if ([result isEqualToString:@"iPhone7,1"])      type = @"iPhone 6 Plus";
    if ([result isEqualToString:@"iPhone8,1"])      type = @"iPhone 6s";
    if ([result isEqualToString:@"iPhone8,2"])      type = @"iPhone 6s Plus";
    if ([result isEqualToString:@"iPhone8,4"])      type = @"iPhone SE";
    if ([result isEqualToString:@"iPhone9,1"])      type = @"iPhone 7";
    if ([result isEqualToString:@"iPhone9,3"])      type = @"iPhone 7";
    if ([result isEqualToString:@"iPhone9,2"])      type = @"iPhone 7 Plus";
    if ([result isEqualToString:@"iPhone9,4"])      type = @"iPhone 7 Plus";
    if ([result isEqualToString:@"iPhone10,1"])     type = @"iPhone 8";
    if ([result isEqualToString:@"iPhone10,4"])     type = @"iPhone 8";
    if ([result isEqualToString:@"iPhone10,2"])     type = @"iPhone 8 Plus";
    if ([result isEqualToString:@"iPhone10,5"])     type = @"iPhone 8 Plus";
    if ([result isEqualToString:@"iPhone10,3"])     type = @"iPhone X";
    if ([result isEqualToString:@"iPhone10,6"])     type = @"iPhone X";
    if (!type) {
        NSInteger index = MAX([result rangeOfString:@"iPhone"].length, [result rangeOfString:@"iPad"].length);
        if (index == 0) {
            index = [result rangeOfString:@"iPod"].length;
        }
        if (index > 0) {
            type = [result substringToIndex:index];
        }
    }
    
    return type;
}

@end
