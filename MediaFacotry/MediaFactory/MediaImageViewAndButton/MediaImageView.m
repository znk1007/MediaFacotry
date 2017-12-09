//
//  MediaImageView.m
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/28.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaImageView.h"
#import "MediaCacheView.h"


@implementation UIImageView (MediaFacotryImageView)
/**
 UIImageView 设置网络图片
 
 @param URLString 网络图片路径 / UIImage
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString{
    [self znk_setImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:nil isBackgroundImage:NO fixSize:NO options:MediaFactoryImageOptionsIndicator completion:nil];
}

/**
 UIImageView 设置网络图片
 
 @param URLString 网络图片路径 / UIImage
 @param placeholderImage 占位图片
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage{
    [self znk_setImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:placeholderImage isBackgroundImage:NO fixSize:NO options:MediaFactoryImageOptionsIndicator completion:nil];
}

/**
 UIImageView 设置网络图片
 
 @param URLString 网络图片路径 / UIImage
 @param placeholderImage 占位图片
 @param fixSize 以图片宽高最小值裁剪
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage fixSize:(BOOL)fixSize{
    [self znk_setImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:placeholderImage isBackgroundImage:NO fixSize:fixSize options:MediaFactoryImageOptionsIndicator completion:nil];
}

/**
 UIImageView 设置网络图片三
 
 @param URLString 网络图片路径 / UIImage
 @param placeholderImage 占位图片
 @param fixSize 以图片宽高最小值裁剪
 @param options MediaFactoryImageOptions
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage fixSize:(BOOL)fixSize options:(MediaFactoryImageOptions)options{
    [self znk_setImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:placeholderImage isBackgroundImage:NO fixSize:fixSize options:options completion:nil];
}

/**
 UIImageView 设置网络图片五
 
 @param URLString 网络图片路径 / UIImage
 @param placeholderImage 占位图片
 @param fixSize 以图片宽高最小值裁剪
 @param options MediaFactoryImageOptions
 @param completion 完成block
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage fixSize:(BOOL)fixSize options:(MediaFactoryImageOptions)options compeltion:(void(^_Nullable)(BOOL finished, NSError * _Nullable error, UIImage * _Nullable image))completion{
    [self znk_setImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:placeholderImage isBackgroundImage:NO fixSize:fixSize options:options completion:completion];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
