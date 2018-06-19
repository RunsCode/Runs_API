//
//  HYMaskView.h
//  ClipImage
//
//  Created by 莫名 on 16/9/20.
//  Copyright © 2016年 huangyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HYMaskType) {
    HYMaskTypeRect = 0,     // 矩形
    HYMaskTypeArc,      // 圆形
};

@interface HYMaskView : UIView

@property (nonatomic, assign) CGRect maskRect;
@property (nonatomic, assign) HYMaskType maskType;

- (void)setMaskRect:(CGRect)rect maskType:(HYMaskType)type;

@end
