//
//  NSObject+RuntimeLog.m
//  ProtoBuf_Make
//
//  Created by Dev_Wang on 2017/5/9.
//  Copyright © 2017年 Giant. All rights reserved.
//

#import "NSObject+RuntimeLog.h"
#import <objc/runtime.h>

@implementation NSObject (RuntimeLog)

- (void)rs_log {
#ifdef DEBUG    
//    NSUInteger length = self.rs_propertyCount;
////    NSArray *keys = [self rs_fetchPropertyWithLength:length];
//    NSDictionary *map = [self rs_fetchKeyValueWithLength:length];
//    NSString *string = [NSString stringWithFormat:@"%@ \n %@", self, map];
//    NSLog(@"%@", string);
#else
#endif
}
@end

@implementation NSObject (Dispatch)
+ (void)rs_safeMainThreadSync:(void(^)(void))block {
    if ([NSThread isMainThread]) {
        block();
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), block);
}

+ (void)rs_safeMainThreadAsync:(void(^)(void))block {
    if ([NSThread isMainThread]) {
        block();
        return;
    }
    dispatch_async(dispatch_get_main_queue(), block);
}
@end


@implementation NSObject (DeepCopy)

- (instancetype)rs_deepCopy {
    NSData *archiveForCopy = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSObject *deepCoy = [NSKeyedUnarchiver unarchiveObjectWithData:archiveForCopy];
    return deepCoy;
}

@end


@implementation NSObject (NSNotification)

+ (void)rs_notify:(NSString *)notificationName {
    [self rs_notify:notificationName object:nil];
}

+ (void)rs_notify:(NSString *)notificationName object:(id)obj {
    [NSNotificationCenter.defaultCenter postNotificationName:notificationName object:obj];
}

+ (void)rs_subscribe:(NSString *)notificationName onNext:(void (^)(NSNotification * _Nonnull))blk {
    [self rs_subscribe:notificationName object:nil onNext:blk];
}

+ (void)rs_subscribe:(NSString *)notificationName object:(id _Nullable)obj onNext:(nonnull void (^)(NSNotification * _Nonnull))blk {
    [NSNotificationCenter.defaultCenter addObserverForName:notificationName object:obj queue:nil usingBlock:blk];
}

+ (void)rs_unsubscribe:(id)observer {
    [NSNotificationCenter.defaultCenter removeObserver:observer];
}

+ (void)rs_unsubscribe:(id)observer notificationName:(NSString *)notificatioName {
    [NSNotificationCenter.defaultCenter removeObserver:observer name:notificatioName object:nil];
}

+ (void)rs_unsubscribe:(id)observer notificationName:(NSString *)notificatioName object:(id)obj {
    [NSNotificationCenter.defaultCenter removeObserver:observer name:notificatioName object:obj];
}

@end

@implementation NSObject (Property)

- (NSUInteger)rs_propertyCount {
    unsigned int count = 0;
    id classObj = objc_getClass(NSStringFromClass(self.class).UTF8String);
    objc_property_t *pList = class_copyPropertyList(classObj, &count);
    free(pList);
    return count;// >= 4 ? count -4 : count > 0 ? count : 0;
}


- (NSArray<NSString *> *)rs_fetchPropertyWithLength:(NSUInteger)lenght {
    
    id classObj = objc_getClass(NSStringFromClass(self.class).UTF8String);
    NSMutableArray<NSString *> *keys = [NSMutableArray array];
    unsigned int count = 0;
    objc_property_t *pList = class_copyPropertyList(classObj, &count);
    if (count > lenght) {
        count = (int)lenght;
    }
    if (lenght > 0) {
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(pList[i])];
            [keys addObject:key];
        }
    }
    free(pList);
    return keys;
}

- (NSDictionary<NSString *, id> *)rs_fetchKeyValueWithLength:(NSUInteger)lenght {
    id classObj = objc_getClass(NSStringFromClass(self.class).UTF8String);
    NSMutableDictionary<NSString *,id> *maps = [NSMutableDictionary dictionaryWithCapacity:lenght];
    unsigned int count = 0;
    objc_property_t *pList = class_copyPropertyList(classObj, &count);
    if (count > lenght) {
        count = (int)lenght;
    }
    if (lenght > 0) {
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithUTF8String:property_getName(pList[i])];
            id value = [self valueForKeyPath:key];
            if (!value) {
                if ([value isKindOfClass:NSNumber.class]) {
                    value = @10000;
                }else {
                    value = @"";
                }
            }
            maps[key] = value;
        }
    }
    free(pList);
    return maps;
}
@end


@implementation NSObject (Sqlite)

- (NSString *)rs_fetchInsertSqlWithTableName:(NSString *)tableName uniqueKey:(NSString *)uniqueKey {
    
    NSString *head = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (ID",tableName];
    NSString *middle = @") VALUES (";
    NSString *tail = @");";
    NSString *select = [NSString stringWithFormat:@"(SELECT ID FROM %@ WHERE %@ = :%@)",tableName, uniqueKey, uniqueKey];
    
    NSMutableString *sql = [NSMutableString stringWithString:head];
    NSArray<NSString *> *keys = [self rs_fetchPropertyWithLength:self.rs_propertyCount];
    for (NSString *key in keys) {
        [sql appendFormat:@", %@",key];
    }
    //
    [sql appendString:middle];
    [sql appendString:select];
    //
    for (NSString *key in keys) {
        [sql appendFormat:@", :%@", key];
    }
    [sql appendString:tail];
    return sql;
}

+ (NSString *)rs_fetchDropTableSqlWithTableName:(NSString *)tableName {
    return [NSString stringWithFormat:@"DROP TABLE %@", tableName];
}

+ (NSString *)rs_fetchDeleteSqlWithTableName:(NSString *)tableName conditionKey:(NSString *)conditionKey {
    return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = :%@;", tableName, conditionKey, conditionKey];
}

+ (NSString *)rs_fetchUpdateSqlWithTableName:(NSString *)tableName updateKey:(NSString *)updateKey conditionKey:(NSString *)conditionKey {
    return [NSString stringWithFormat:@"UPDATE %@ SET %@ = :%@ WHERE %@ = :%@;",tableName, updateKey, updateKey, conditionKey, conditionKey];
}

+ (NSString *)rs_fetchQueryLoadMoreSqlWithTableName:(NSString *)tableName conditionKey:(NSString *)conditionKey order:(QueryOrderType)order orderKey:(NSString *)orderKey limit:(NSUInteger)limit {
    if (limit == 0 || Enum_OrderNone == order) {
        return [NSString stringWithFormat:@"SELECT * FROM %@;",tableName];
    }
    
    NSString *orderCommand = @"ASC";
    if (Enum_OrderByDESC == order) {
        orderCommand = @"DESC";
    }

    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ < :%@ ORDER BY %@ %@ LIMIT %ld",tableName, conditionKey, conditionKey, orderKey, orderCommand, (unsigned long)limit];
}

+ (NSString *)rs_fetchQuerySqlWithTableName:(NSString *)tableName conditionKey:(NSString *)conditionKey order:(QueryOrderType)order orderKey:(NSString *)orderKey limit:(NSUInteger)limit {
    
    if (!conditionKey || conditionKey.length <= 0) {
        return [self rs_fetchQueryOrderSql:tableName order:order orderKey:orderKey limit:limit];
    }
    
    if (limit <= 0 || Enum_OrderNone == order) {
        return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = :%@;",tableName, conditionKey, conditionKey];
    }
    
    NSString *orderCommand = @"ASC";
    if (Enum_OrderByDESC == order) {
        orderCommand = @"DESC";
    }
    
    return [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = :%@ ORDER BY %@ %@ LIMIT %ld;",tableName, conditionKey, conditionKey, orderKey, orderCommand, (unsigned long)limit];

}

+ (NSString *)rs_fetchQueryOrderSql:(NSString *)tableName order:(QueryOrderType)order orderKey:(NSString *)orderKey limit:(NSUInteger)limit {
    if (limit == 0 || Enum_OrderNone == order) {
        return [NSString stringWithFormat:@"SELECT * FROM %@;",tableName];
    }
    
    NSString *orderCommand = @"ASC";
    if (Enum_OrderByDESC == order) {
        orderCommand = @"DESC";
    }
    
    if (limit <= 0) {//-1
        return [NSString stringWithFormat:@"SELECT * FROM %@  ORDER BY %@ %@;",tableName, orderKey, orderCommand];
    }

    return [NSString stringWithFormat:@"SELECT * FROM %@  ORDER BY %@ %@ LIMIT %ld;",tableName, orderKey, orderCommand, (unsigned long)limit];
}
@end




