//
//  UIButton+Category.m
//  OU_iPad
//
//  Created by runs on 2017/9/27.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UIButton+Category.h"

@implementation UIButton (Category)

- (void)rs_cornerRadius:(CGFloat)radius {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:(CGSize){radius, radius}];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.bounds;
    layer.backgroundColor = UIColor.redColor.CGColor;
    layer.path = path.CGPath;
    self.layer.mask = layer;
}

- (void)rs_showUnderLine {
    NSString *title = [self titleForState:UIControlStateNormal];
    NSMutableAttributedString *str = [NSMutableAttributedString.alloc initWithString:title];
    NSRange strRange = {0,str.length};
    [str addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:strRange];
    [self setAttributedTitle:str forState:UIControlStateNormal];
}

@end
//UIRectCornerBottomLeft | UIRectCornerTopLeft
//UIRectCornerAllCorners
