//
//  UISlider+Category.m
//  OU_iPad
//
//  Created by runs on 2017/12/18.
//  Copyright © 2017年 Olacio. All rights reserved.
//

#import "UISlider+Category.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation UISlider (Category)

+ (instancetype)rs_systemVolumeSlider {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    UISlider *slider = nil;
    for (UIView *view in volumeView.subviews){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            slider = (UISlider *)view;
            break;
        }
    }
    return slider;
}
@end
