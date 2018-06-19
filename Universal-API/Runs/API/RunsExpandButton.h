//
//  RunsExpandButton.h
//  Hey
//
//  Created by Dev_Wang on 2017/5/31.
//  Copyright © 2017年 Giant Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

IB_DESIGNABLE
@interface RunsExpandButton : UIButton
//x,y轴向外扩张多少像素
@property (nonatomic, assign) IBInspectable CGPoint expandPoint;
@end

NS_ASSUME_NONNULL_END
