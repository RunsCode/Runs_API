//
//  NSObject+RuntimeLog.h
//  ProtoBuf_Make
//
//  Created by Dev_Wang on 2017/5/9.
//  Copyright © 2017年 Giant. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QueryOrderType) {
    Enum_OrderByASC = 0,
    Enum_OrderByDESC = 1,
    Enum_OrderNone = 2,
    Enum_Default_Order = Enum_OrderNone,
};

@interface NSObject (RuntimeLog)
- (void)rs_log;
@end

@interface NSObject (Dispatch)
/**
 同步 抛回主线程执行block
 */
+ (void)rs_safeMainThreadSync:(void(^)(void))block;
/**
 异步 抛回主线程执行block
 */
+ (void)rs_safeMainThreadAsync:(void(^)(void))block;
@end


@interface NSObject (DeepCopy)
- (instancetype)rs_deepCopy;
@end

@interface NSObject (NSNotification)
+ (void)rs_notify:(NSString *)notificationName;
+ (void)rs_notify:(NSString *)notificationName object:(id _Nullable)obj;
+ (void)rs_subscribe:(NSString *)notificationName onNext:(void (^)(NSNotification *note))blk;;
+ (void)rs_subscribe:(NSString *)notificationName object:(id _Nullable)obj onNext:(void (^)(NSNotification *note))blk;;
+ (void)rs_unsubscribe:(id)observer;
+ (void)rs_unsubscribe:(id)observer notificationName:(NSString *)notificatioName;
+ (void)rs_unsubscribe:(id)observer notificationName:(NSString *)notificatioName object:(id)obj;
@end

@interface NSObject (Property)
- (NSUInteger)rs_propertyCount;
- (NSArray<NSString *> *)rs_fetchPropertyWithLength:(NSUInteger)lenght;
- (NSDictionary<NSString *, id> *)rs_fetchKeyValueWithLength:(NSUInteger)lenght;
@end

@interface NSObject (Sqlite)
- (NSString *)rs_fetchInsertSqlWithTableName:(NSString *)tableName uniqueKey:(NSString *)uniqueKey;
+ (NSString *)rs_fetchDeleteSqlWithTableName:(NSString *)tableName conditionKey:(NSString *)conditionKey;
+ (NSString *)rs_fetchUpdateSqlWithTableName:(NSString *)tableName updateKey:(NSString *)updateKey conditionKey:(NSString *)conditionKey;
+ (NSString *)rs_fetchDropTableSqlWithTableName:(NSString *)tableName;
/**
 按条件查找  比如根据某一标识 查找更多
 
 比如拉取最新十条记录  然后跟句最后一条记录标识  再来拉取十条

 @param tableName 表名
 @param conditionKey 筛选条件 如果为空则根据排序键值 取结果 没有排序键值  根据ID 取结果
 @param order 升序还是降序
 @param orderKey  排序的限制条件 小于等于 -1:表示所有
 @param limit 查询结果最大数
 @return 返回sql语句
 */
+ (NSString *)rs_fetchQueryLoadMoreSqlWithTableName:(NSString *)tableName conditionKey:(NSString *)conditionKey order:(QueryOrderType)order orderKey:(NSString *)orderKey limit:(NSUInteger)limit;

/**
 根据表名 筛选条件 排序 限制数 获取查询语句
 
 如果只要去除一个数据 没有其他任何排序条件下  limit 传入 0

 @param tableName 表名
 @param conditionKey 筛选条件 如果为空则根据排序键值 取结果 没有排序键值  根据ID 取结果
 @param order 排序方式  升序还是降序
 @param orderKey 排序的限制条件 小于等于 -1:表示所有
 @param limit 查询结果最大数
 @return 返回sql语句
 */
+ (NSString *)rs_fetchQuerySqlWithTableName:(NSString *)tableName conditionKey:(NSString * _Nullable)conditionKey order:(QueryOrderType)order orderKey:(NSString * _Nullable)orderKey limit:(NSUInteger)limit;

@end
NS_ASSUME_NONNULL_END
