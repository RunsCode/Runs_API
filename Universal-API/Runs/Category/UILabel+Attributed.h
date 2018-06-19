//
//  UILabel+Attributed.h
//  OU_iPhone
//
//  Created by runs on 2017/10/19.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Attributed)
/**
 *  改变行间距
 */
- (void)rs_lineSpace:(CGFloat)space;

/**
 *  改变字间距
 */
- (void)rs_wordSpace:(CGFloat)space;

/**
 *  改变行间距和字间距
 */
- (void)rs_lineSpace:(float)lineSpace wordSpace:(float)wordSpace;
@end
