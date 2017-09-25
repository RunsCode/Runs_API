//
//  UIView+Category.h
//
//  Created by wang on 15/12/19.
//

#import <UIKit/UIKit.h>

@interface UIView (Category)
+ (id)loadMainNib;
+ (UINib *)loadNib;
- (void)setZeroOrigin;
- (void)setFrameX:(CGFloat)frame_x;
- (void)setFrameY:(CGFloat)frame_y;
- (void)setFrameWidth:(CGFloat)frame_width;
- (void)setFrameHeight:(CGFloat)frame_height;
- (void)setCenterX:(CGFloat)centerX;
- (void)setCenterY:(CGFloat)centerY;
- (void)setSize:(CGSize)size;
- (void)setPoint:(CGPoint)point;
- (CGSize)size;
- (CGPoint)origin;
- (CGFloat)getFrameRight;
- (CGFloat)getFrameBottom;
//- (UIView *)deepCopy;
@end
