//
//  UIPanGestureRecognizer+Category.m
//  OU_iPad
//
//  Created by runs on 2017/12/18.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UIPanGestureRecognizer+Category.h"

@implementation UIPanGestureRecognizer (Category)

- (UIPanGestureRecognizerDirection)directionInLocationView:(UIView *)locationView {
    CGPoint veloctyPoint = [self velocityInView:locationView];
    CGFloat x = fabs(veloctyPoint.x);
    CGFloat y = fabs(veloctyPoint.y);
    
    if (x > y) {
        return UIPanGestureRecognizerDirectionHorizontal;
    }
    return UIPanGestureRecognizerDirectionDefault;
}

- (BOOL)rs_isHorizontalMovedInLocationView:(UIView *)locationView {
    return [self directionInLocationView:locationView] == UIPanGestureRecognizerDirectionHorizontal;
}

@end
