//
//  NSIndexPath+Category.m
//  OU_iPad
//
//  Created by runs on 2017/9/8.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "NSIndexPath+Category.h"

static const char NSIndexPathCategoryRowsCount = '\0\0';

@implementation NSIndexPath (Category)

- (void)setRowsCount:(NSUInteger)rowsCount {
    objc_setAssociatedObject(self, &NSIndexPathCategoryRowsCount, @(rowsCount), OBJC_ASSOCIATION_ASSIGN);
}

- (NSUInteger)rowsCount {
    id value = objc_getAssociatedObject(self, &NSIndexPathCategoryRowsCount);
    return value;
}

@end
