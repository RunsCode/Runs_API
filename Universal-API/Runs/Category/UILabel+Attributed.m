//
//  UILabel+Attributed.m
//  OU_iPhone
//
//  Created by runs on 2017/10/19.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UILabel+Attributed.h"

@implementation UILabel (Attributed)
- (void)rs_lineSpace:(CGFloat)space {
    if (self.text.length <= 0) {
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:space];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
    self.attributedText = attributedString;
    [self sizeToFit];
}

- (void)rs_wordSpace:(CGFloat)space {
    if (self.text.length <= 0) {
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSKernAttributeName:@(space)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
    self.attributedText = attributedString;
    [self sizeToFit];
}

- (void)rs_lineSpace:(float)lineSpace wordSpace:(float)wordSpace {
    if (self.text.length <= 0) {
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text attributes:@{NSKernAttributeName:@(wordSpace)}];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
    self.attributedText = attributedString;
    [self sizeToFit];
}

@end
