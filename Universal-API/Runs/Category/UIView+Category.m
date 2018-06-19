//
//  UIView+Category.m
//
//  Created by wang on 15/12/19.
//

#import "UIView+Category.h"
#import "RunsMacroConstant.h"
@implementation UIView (Category)

+ (id)loadMainNib
{
    NSString * className = NSStringFromClass(self.class);
    id object = [[[NSBundle mainBundle] loadNibNamed:className owner:nil options:nil] firstObject];
    return object;
}

+ (UINib *)loadNib {
    NSString * className = NSStringFromClass(self.class);
    UINib * nib = [UINib nibWithNibName:className bundle:nil];
    return nib;
}

- (void)setZeroOrigin
{
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameX:(CGFloat)frame_x
{
    self.frame = CGRectMake(frame_x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameY:(CGFloat)frame_y
{
    self.frame = CGRectMake(self.frame.origin.x, frame_y, self.frame.size.width, self.frame.size.height);
}

- (void)setFrameWidth:(CGFloat)frame_width
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, frame_width, self.frame.size.height);
}

- (void)setFrameHeight:(CGFloat)frame_height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, frame_height);
}

- (void)setCenterX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

- (void)setCenterY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

- (void)setSize:(CGSize)size
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (void)setPoint:(CGPoint)point
{
    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
}

-(CGSize)size
{
    return self.frame.size;
}

-(CGPoint)origin
{
    return self.frame.origin;
}

-(CGFloat)getFrameRight
{
    return self.frame.origin.x + self.frame.size.width;
}

-(CGFloat)getFrameBottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)corners:(UIRectCornerExtension)corners radius:(CGFloat)radius {
    RunsAssert(self.bounds.size.width > 0 && self.bounds.size.height > 0, @"没有实际大小Size 无法切圆角")
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:(UIRectCorner)corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

//- (UIView *)deepCopy
//{
//    NSData *archiveForCopyView = [NSKeyedArchiver archivedDataWithRootObject:self];
//    UIView *copyView = [NSKeyedUnarchiver unarchiveObjectWithData:archiveForCopyView];
//    return copyView;
//}

@end
