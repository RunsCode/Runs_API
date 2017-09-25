//
//  RunsMacroConstant.h
//  qiuqiuTalk
//
//  Created by wang on 2016/9/30.
//  Copyright © 2016年 iOS. All rights reserved.
//

#ifndef RunsMacroConstant_h
#define RunsMacroConstant_h

#define CER_NAME @"bomb"
#define CER_TYPE @"cer"

#define USER_LOGIN_STATUS_KEY   @"USER_LOGIN_STATUS_KEY"
#define USER_BASEINFO_KEY       @"USER_BASEINFO_KEY"
#define USER_ID_KEY             @"USER_ID_KEY"
#define USER_NAME_KEY           @"USER_NAME_KEY"
#define USER_PWD_KEY            @"USER_PWD_KEY"
#define USER_TOEKN_KEY          @"USER_TOEKN_KEY"

#define RandomSeed (arc4random_uniform(2000))
#define TEST_UID (RandomSeed+300)
#define TEST_SEX (1)
#define TEST_NAME     @"Runs"

#ifdef DEBUG
#define RUNS_TEST (1)
#else
#define RUNS_TEST (0)
#endif



#define TEST_ICON @"http://pic.3h3.com/up/2016-4/20164421211445459480.jpg"

#define MSG_TYPE_SIZE       (2)
#define HEART_BEAT_INTERVAL (10.f)
#define HEART_BEAT_TIMEOUT  (5.f)
#define MAX_RECONNECT_COUNT (3)

#define UserProtoMsgHeadName @"Msg"
#define AlertViewTitleString @"系统提示"
#define DEVEICE_TOEKN_KEY    @"DeveiceToekn"

//#define UIDefaultFontWithSize(args) ([UIFont fontWithName:@"MFYueHei_Noncommercial-Light" size:args])
#define UIDefaultFontWithSize(args) ([UIFont systemFontOfSize:args])

#define IsEqualToString(str1,str2) ([str1 isEqualToString:str2])
#define IsClassOf(obj,class_type) [obj isKindOfClass:[class_type class]]
#define NStrFromCStr(cstr) [NSString stringWithUTF8String:cstr.c_str()]
#define IntToString(args) [NSString stringWithFormat:@"%d",args]
#define LongToString(args) [NSString stringWithFormat:@"%ld",(long)args]

//色值处理转换
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//用于block的弱引用
#define WEAK_SELF_OBJCET_BLOCK(selfObject, weakObject) __weak __typeof(selfObject)weakObject = selfObject;
#define WEAK_OBJCET_STRONG_POINT(weakSelf, strongSelf) __strong __typeof(weakSelf)strongSelf = weakSelf;
#define WEAK_BLOCK_OBJECT(object) WEAK_SELF_OBJCET_BLOCK(object,weak_##object##_kaf9097uq54ni8);
#define BLOCK_OBJECT(object) WEAK_OBJCET_STRONG_POINT(weak_##object##_kaf9097uq54ni8,weak_##object);



#define RandomColor [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1]
#define RandomData [NSString stringWithFormat:@"随机数据---%d", arc4random_uniform(1000000)]
#define SuperViewTransparent(arg1,arg2) ([arg1 colorWithAlphaComponent:arg2])
//状态栏高度
#define STATUS_BAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)//20
//NavBar高度
#define NAVIGATION_BAR_HEIGHT (self.navigationController.navigationBar.frame.size.height)//44
#define NAVIGATION_BAR_PROXY_HEIGHT (Runs_NAV_PROXY.curNavigationController.navigationBar.frame.size.height)//44
//状态栏 ＋ NavBar 高度
#define STATUS_AND_NAVIGATION_HEIGHT ((STATUS_BAR_HEIGHT) + (NAVIGATION_BAR_HEIGHT))
#define STATUS_AND_NAVIGATION_PROXY_HEIGHT ((STATUS_BAR_HEIGHT) + (NAVIGATION_BAR_PROXY_HEIGHT))

//屏幕 rect
#define SCREEN_RECT ([UIScreen mainScreen].bounds)
#define OC_SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define OC_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


#if defined(DEBUG)
//#define RunsLog(STRLOG) NSLog(@"%@: %@ %@", self, NSStringFromSelector(_cmd), STRLOG)
#define RunsLog(format, ...) NSLog(@"[%d], %@: %@ %@", NSThread.isMainThread, self, NSStringFromSelector(_cmd), ([NSString stringWithFormat:format, ## __VA_ARGS__]));
#else
#define RunsLog(format, ...);//NSLog(@"%@: %@ %@", self, NSStringFromSelector(_cmd), STRLOG)

//#if TARGET_IPHONE_SIMULATOR
//// 模拟器中仍然显示日志
//#define RunsLog(STRLOG)
////#define RunsLogSP(format, ...)
//#else
//// release版本目前也增加日志吧,正式发部时再决定是否去掉
//#define RunsLog(STRLOG)
//#define RunsLog(format, ...)
//#endif
#endif

#ifndef RunsLogEX
#ifdef DEBUG
#define RunsLogEX(format, ...) NSLog(@"[%d] %s %@", NSThread.isMainThread, __PRETTY_FUNCTION__, ([NSString stringWithFormat:format, ## __VA_ARGS__]));
#define RunsReleaseLog() NSLog(@"%@ Release", NSStringFromClass(self.class));
#else
#define RunsLogEX(format, ...)
#define RunsReleaseLog()
#endif
#endif

#ifdef DEBUG
#define RunsTimeBegin(TAG) printf("TAG: %s ,%s  begin :%f \n",TAG.UTF8String, __PRETTY_FUNCTION__, [[NSDate date] timeIntervalSince1970]);
#define RunsTimeEnd(TAG) printf("TAG: %s ,%s    end :%f \n",TAG.UTF8String, __PRETTY_FUNCTION__, [[NSDate date] timeIntervalSince1970]);
#else
#define RunsTimeBegin(TAG)
#define RunsTimeEnd(TAG)
#endif

#if defined(ENTERPRISE_VERSION)
//#define RunsLog(STRLOG) NSLog(@"%@: %@ %@", self, NSStringFromSelector(_cmd), STRLOG)
#define RunsLog(format, ...) NSLog(@"%@: %@ %@", self, NSStringFromSelector(_cmd), ([NSString stringWithFormat:format, ## __VA_ARGS__]));
#define RunsLogEX(format, ...) NSLog(format, ## __VA_ARGS__);
#endif

//
#ifdef DEBUG
#define RunsAssert(condition,msg) if (!(condition)) { \
RunsLog(@"RunsAssert: %@ [%@ %@]",msg,@(__FILE__),@(__LINE__)); \
assert(false); \
}
//NSString* targetMsg = [NSString stringWithFormat:@"RunsAssert: %@ [%@ %@]",msg,@(__FILE__),@(__LINE__)]; \

#define RunsAssertKind(_obj,_kind,_msg) if (_obj) { \
RunsAssert([(_obj) isKindOfClass:[_kind class]],(_msg)); \
}else { \
RunsLog(@"RunsAssertKind: warning %@ is nil.[%@ %@]",NSStringFromClass([_kind class]),@(__FILE__),@(__LINE__)); \
}
#else
#define RunsAssert(condition,msg) if (!(condition)) { \
RunsLog(@"RunsAssert: %@ [%@ %@]",msg,@(__FILE__),@(__LINE__)); \
return;\
}
//NSString* targetMsg = [NSString stringWithFormat:@"RunsAssert: %@ [%@ %@]",msg,@(__FILE__),@(__LINE__)]; \

#define RunsAssertKind(_obj,_kind,_msg) if (_obj) { \
RunsAssert([(_obj) isKindOfClass:[_kind class]],(_msg)); \
}else { \
RunsLog(@"RunsAssertKind: warning %@ is nil.[%@ %@]",NSStringFromClass([_kind class]),@(__FILE__),@(__LINE__)); \
}
#endif
//

#define SafeSetObject(map,obj,key) if(map){\
if(key) {\
    if(obj) {\
        [map setObject:obj forKey:key];\
    }else{\
        RunsLog(@"字典插入对象为空 key = %@",key);\
    }\
}else{\
    RunsLog(@"字典插入key为空");\
}\
} else {\
RunsLog(@"字典为空 无法插入数据");}\


#define RunsSafeMainThreadSync(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define RunsSafeMainThredAsync(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define UNAVAILABLE(args) \
- (instancetype) init __attribute__((unavailable(args)));\
+ (instancetype) new  __attribute__((unavailable(args)));

#define SINGLETON_UNAVAILABLE_FUNCTION \
- (instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));\
+ (instancetype) new  __attribute__((unavailable("new not available, call sharedInstance instead")));

//+ (instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
#ifdef DEBUG
#define RunsRequestLog(args0,arg1)\
if (![args0 containsString:kUploadPhotoURL]\
&& ![args0 containsString:kUploadAudioURL]\
&& ![args0 containsString:kUploadViedeoURL]\
&& ![args0 containsString:kUploadFileURL]) {\
}\
RunsLog(@"\n\n------------------------%@----------------------", args0)\
printf("%s", GPBTextFormatForMessage(arg1, nil).UTF8String);\
printf("------------------------%s-----------------------\n\n", args0.UTF8String);
#else
#define RunsRequestLog(args0,arg1)
#endif

#endif /* RunsMacroConstant_h */
