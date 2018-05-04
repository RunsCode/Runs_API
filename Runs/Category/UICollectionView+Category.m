//
//  UICollectionView+Category.m
//  OU_iPhone
//
//  Created by runs on 2017/11/22.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UICollectionView+Category.h"

@implementation UICollectionView (Category)

+ (void)load {
    Method originalMethod0 = class_getInstanceMethod(self, @selector(reloadData));
    Method swizzledMethod0 = class_getInstanceMethod(self, @selector(rs_reloadData));
    method_exchangeImplementations(originalMethod0, swizzledMethod0);
}

- (void)rs_reloadData {
    [self rs_reloadData];
    [self.collectionViewLayout invalidateLayout];
}

@end
