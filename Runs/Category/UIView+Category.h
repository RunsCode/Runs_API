//
//  UIView+Category.h
//
//  Created by wang on 15/12/19.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UIRectCornerExtension) {
    UIRectCornerLeftTopAndBottom            = UIRectCornerTopLeft | UIRectCornerBottomLeft,    //左上左下
    UIRectCornerTopLeftAndRight             = UIRectCornerTopLeft | UIRectCornerTopRight,      //左上右上
    UIRectCornerTopLeftAndBottomRight       = UIRectCornerTopLeft | UIRectCornerBottomRight,   //左上右下
    UIRectCornerBottomLeftAndTopRight       = UIRectCornerBottomLeft | UIRectCornerTopRight,   //左下右上
    UIRectCornerBottomLeftAndBottomRight    = UIRectCornerBottomLeft | UIRectCornerBottomRight,//左下右下
    UIRectCornerRightTopAndBottom           = UIRectCornerTopRight | UIRectCornerBottomRight,  //左上右上
    UIRectCornerExtensionAllCorners         = UIRectCornerAllCorners,                          // 四周
    UIRectCornerExtensionDefault            = UIRectCornerExtensionAllCorners,
};

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
- (void)corners:(UIRectCornerExtension)corners radius:(CGFloat)radius;
@end
