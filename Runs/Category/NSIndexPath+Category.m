//
//  NSIndexPath+Category.m
//  OU_iPad
//
//  Created by runs on 2017/9/8.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSIndexPath+Category.h"

static const NSString * NSIndexPathCategoryRowsCount = @"NSIndexPath+Category_runs";

@implementation NSIndexPath (Category)

- (void)setRowsCount:(NSUInteger)rowsCount {
    objc_setAssociatedObject(self, &NSIndexPathCategoryRowsCount, @(rowsCount), OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)rowsCount {
    id value = objc_getAssociatedObject(self, &NSIndexPathCategoryRowsCount);
    return (NSUInteger)value;
}

@end
