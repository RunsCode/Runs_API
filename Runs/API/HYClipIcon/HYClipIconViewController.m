//
//  HYClipIconViewController.m
//  ClipImage
//
//  Created by 莫名 on 16/9/20.
//  Copyright © 2016年 huangyi. All rights reserved.
//

#import "HYClipIconViewController.h"
#import "HYMaskView.h"

#define HY_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define HY_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define DEFAULT_CLIP_RECT CGRectMake((HY_SCREEN_WIDTH - 300.f)/2, (HY_SCREEN_HEIGHT - 300)/2, 300.f, 300.f)

@interface HYClipIconViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    HYMaskView *_maskView;
    
    UIButton *_cancelButton;
    UIButton *_clipButton;
    
    UIImage *_image; // 待裁剪的图片
}
@property (nonatomic, copy) void (^clipBlock)(UIImage *image);

@end

@implementation HYClipIconViewController

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        _image = [self scaleImageSizeWith:image];
        _maxScale = 1.5f;
        _clipRect = DEFAULT_CLIP_RECT;
        _clipType = HYClipTypeRect;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image clipType:(HYClipType)type {
    if (self = [self initWithImage:image]) {
        _clipType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_maskView setMaskRect:self.clipRect maskType:(HYMaskType)self.clipType];
    [self dealScrollView];
}

- (void)initContent {
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    
    _imageView = [[UIImageView alloc] initWithImage:_image];
    [_scrollView addSubview:_imageView];
    _scrollView.contentSize = _imageView.frame.size;
    
    
    _maskView = [[HYMaskView alloc] initWithFrame:_scrollView.frame];
    _maskView.userInteractionEnabled = NO;
    [self.view addSubview:_maskView];
    
    _clipButton = [[UIButton alloc] initWithFrame:CGRectMake(HY_SCREEN_WIDTH - 80.f, HY_SCREEN_HEIGHT - 40.f, 60.f, 30.f)];
    [_clipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_clipButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [_clipButton setTitle:@"确定" forState:UIControlStateNormal];
    [_clipButton addTarget:self action:@selector(clipImageAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_clipButton];
    
    _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20.f, HY_SCREEN_HEIGHT - 40.f, 60.f, 30.f)];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:16.f]];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];
}

- (void)clipImageAction {
    
    UIImage *image = [self beginClipImage];
    if (self.clipBlock) {
        self.clipBlock(image);
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([self.delegate respondsToSelector:@selector(HYClipIconViewControllerDidFinishedClickImage)]) {
        [self.delegate HYClipIconViewControllerDidFinishedClickImage];
    }
}

- (void)cancelAction {
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([self.delegate respondsToSelector:@selector(HYClipIconViewControllerDidFinishedClickImage)]) {
        [self.delegate HYClipIconViewControllerDidFinishedClickImage];
    }
}

- (void)didClipImageBlock:(void (^)(UIImage *))clipBlock {
    
    if (clipBlock) {
        self.clipBlock = clipBlock;
    }
}

#pragma mark - 裁剪图片
- (UIImage *)beginClipImage
{
    // 计算缩放比例
    CGFloat scale = _imageView.image.size.height / _imageView.frame.size.height;
    
    CGFloat width = self.clipRect.size.width * scale;
    CGFloat height = self.clipRect.size.height * scale;
    CGFloat x = (self.clipRect.origin.x + _scrollView.contentOffset.x) * scale;
    CGFloat y = (self.clipRect.origin.y + _scrollView.contentOffset.y) * scale;
    
    // 设置裁剪图片的区域
    CGRect rect = CGRectMake(x, y, width, height);
    
    // 截取区域图片
    CGImageRef imageRef = CGImageCreateWithImageInRect(_imageView.image.CGImage, rect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    if (self.clipType == HYClipTypeArc) { // 圆形图片 产品定义，最终拿矩形原始图片
        UIGraphicsBeginImageContext(image.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextBeginPath(context);
        CGContextAddArc(context, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5, 0.f, 2 * M_PI, YES);
        CGContextClip(context);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

- (void)showClipIconViewController:(UIViewController *)vc {
    __weak typeof(vc)weakVc = vc;
    if (weakVc != nil) {
        [weakVc presentViewController:self animated:YES completion:nil];
    }
}

#pragma mark - UIScrollViewDelegate 返回缩放的view
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return _imageView;
}

#pragma mark - 处理scrollView的最小缩放比例 和 滚动范围
- (void)dealScrollView {
    
    CGFloat top = self.clipRect.origin.y;
    CGFloat left = self.clipRect.origin.x;
    CGFloat bottom = HY_SCREEN_HEIGHT - self.clipRect.size.height - top;
    CGFloat right = HY_SCREEN_WIDTH - self.clipRect.size.width - left;
    
    CGFloat minScale = 0.f;
    if (_imageView.image.size.height > _imageView.image.size.width) {
        minScale = self.clipRect.size.width / _imageView.bounds.size.width;
    } else {
        minScale = self.clipRect.size.height / _imageView.bounds.size.height;
    }
    
    _scrollView.maximumZoomScale = self.maxScale;
    _scrollView.minimumZoomScale = minScale;
    _scrollView.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
    
    [self scrollToCenter];
}

#pragma mark - 滚动图片到中间位置
- (void)scrollToCenter {
    
    CGFloat x = (_imageView.frame.size.width - HY_SCREEN_WIDTH) / 2;
    CGFloat y = (_imageView.frame.size.height - HY_SCREEN_HEIGHT) / 2;
    _scrollView.contentOffset = CGPointMake(x, y);
}

#pragma mark - 缩放图片尺寸 适应屏幕
- (UIImage *)scaleImageSizeWith:(UIImage *)image {
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    width = HY_SCREEN_WIDTH;
    height = image.size.height / image.size.width * width;
    if (height < HY_SCREEN_WIDTH) {
        height = HY_SCREEN_WIDTH;
        width = image.size.width / image.size.height * height;
    }
    
    CGSize size = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
