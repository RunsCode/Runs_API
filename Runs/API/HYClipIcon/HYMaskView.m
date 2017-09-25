//
//  HYMaskView.m
//  ClipImage
//
//  Created by 莫名 on 16/9/20.
//  Copyright © 2016年 huangyi. All rights reserved.
//

#import "HYMaskView.h"

@implementation HYMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.maskType == HYMaskTypeArc) {
        CGContextAddEllipseInRect(context, self.maskRect);
    } else {
        CGContextAddRect(context, self.maskRect);
    }
    CGContextAddRect(context, rect);
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] setFill];
    
    CGContextDrawPath(context, kCGPathEOFill);
}

- (void)setMaskRect:(CGRect)rect maskType:(HYMaskType)type {
    _maskRect = rect;
    _maskType = type;
    
    [self setNeedsDisplay];
}

@end
