//
//  UIPanGestureRecognizer+Category.h
//  OU_iPad
//
//  Created by runs on 2017/12/18.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIPanGestureRecognizerDirection) {
    UIPanGestureRecognizerDirectionHorizontal = 0,
    UIPanGestureRecognizerDirectionVertical = 1,
    UIPanGestureRecognizerDirectionDefault = UIPanGestureRecognizerDirectionVertical,
};

@interface UIPanGestureRecognizer (Category)
- (UIPanGestureRecognizerDirection)directionInLocationView:(UIView *)locationView;
- (BOOL)rs_isHorizontalMovedInLocationView:(UIView *)locationView;
@end
