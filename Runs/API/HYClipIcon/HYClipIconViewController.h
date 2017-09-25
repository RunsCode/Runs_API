//
//  HYClipIconViewController.h
//  ClipImage
//
//  Created by 莫名 on 16/9/20.
//  Copyright © 2016年 huangyi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HYClipType) {
    HYClipTypeRect = 0, // 矩形裁剪
    HYClipTypeArc,      // 圆形裁剪
};

@protocol HYClipIconViewControllerDelegate <NSObject>

- (void)HYClipIconViewControllerDidFinishedClickImage;

@end

@interface HYClipIconViewController : UIViewController

/**
 代理
 */
@property (nonatomic,weak) id<HYClipIconViewControllerDelegate> delegate;
/**
 *  裁剪区域  默认 300*300显示屏幕中心位置
 */
@property (nonatomic, assign) CGRect clipRect;
/**
 *  裁剪类型  默认 HYClipTypeRect
 */
@property (nonatomic, assign) HYClipType clipType;
/**
 *  最大缩放比例  默认1.5
 */
@property (nonatomic, assign) CGFloat maxScale;

/**
 *  初始化方法
 *
 *  @param image 待裁剪图片
 *
 *  @return HYClipIconViewController
 */
- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithImage:(UIImage *)image clipType:(HYClipType)type;

/**
 *  显示裁剪控制器
 *
 *  @param vc 显示在哪个vc上
 */
- (void)showClipIconViewController:(UIViewController *)vc;

/**
 *  裁剪完成回调
 *
 *  @param clipBlock 回调：image为裁剪之后的图片
 */
- (void)didClipImageBlock:(void (^)(UIImage *image))clipBlock;

@end
