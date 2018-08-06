//
//  RunsHollowView.h
//  Runs
//
//  Created by runs on 2018/8/6.
//  Copyright © 2018 Olacio. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RunsHollowView : UIView
@property (nonatomic, assign) CGFloat expandPixel;

- (instancetype _Nullable)initWithFrame:(CGRect)frame radius:(CGFloat)cornerRadius hollowFrame:(CGRect)hollowFrame;
- (instancetype _Nullable)initWithMaskedView:(UIView *)view radius:(CGFloat)cornerRadius hollowFrame:(CGRect)hollowFrame;
- (instancetype _Nullable)initWithMaskedView:(UIView *)view radius:(CGFloat)cornerRadius hollowItemView:(UIView *)itmeView;
//
- (instancetype _Nullable)initWithFrame:(CGRect)frame radius:(CGFloat)cornerRadius frames:(NSValue *)frames, ...;
- (instancetype _Nullable)initWithMaskedView:(UIView *)view radius:(CGFloat)cornerRadius items:(UIView *)items, ...;
//
- (RunsHollowView * _Nullable (^)(CGRect))appendFrame;
- (RunsHollowView * _Nullable (^)(UIView *))appendView;
- (RunsHollowView * _Nullable (^)(CGRect frame, CGFloat radius))append;
- (void)display;
@end
NS_ASSUME_NONNULL_END
