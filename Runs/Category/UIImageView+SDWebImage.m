//
//  UIImageView+SDWebImage.m
//  Hey
//
//  Created by Dev_Wang on 2017/5/17.
//  Copyright © 2017年 Giant Inc. All rights reserved.
//

#import "UIImageView+SDWebImage.h"

@implementation UIImageView (SDWebImage)

- (void)rs_setImageWithURL:(nullable NSString *)url {
    
    if (url.length <= 0 || ![url containsString:@"http"]) {
//        [self setImage:UIImage.HeyGlobalDefaultAvatar];
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//防止中文
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)rs_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder {
    if (url.length <= 0 || ![url containsString:@"http"]) {
        [self setImage:placeholder];
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//防止中文
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)rs_setImageWithURL:(nullable NSString *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options {
    if (url.length <= 0 || ![url containsString:@"http"]) {
        [self setImage:placeholder];
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//防止中文
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)rs_setImageWithURL:(nullable NSString *)url completed:(nullable SDExternalCompletionBlock)completedBlock {
    if (url.length <= 0 || ![url containsString:@"http"]) {
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//防止中文
    [self sd_setImageWithURL:[NSURL URLWithString:url] completed:completedBlock];
}

- (void)rs_setImageWithURL:(nullable NSString *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock {
    if (url.length <= 0 || ![url containsString:@"http"]) {
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//防止中文
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:completedBlock];
}

- (void)rs_setImageWithURL:(nullable NSString *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options completed:(nullable SDExternalCompletionBlock)completedBlock {
    if (url.length <= 0 || ![url containsString:@"http"]) {
        return;
    }
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//防止中文
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder options:options completed:completedBlock];
}
@end
