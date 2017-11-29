//
//  MediaButton.m
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/26.
//  Copyright © 2017年 HM. All rights reserved.
//
#import <objc/runtime.h>
#import "MediaButton.h"
#import "DataDownloadManager.h"
#import "MediaExtension.h"
#import "MediaCacheView.h"

@implementation UIButton (MediaFacotryButton)

#pragma mark - set image
/**
 网络图片设置按钮一
 
 @param URLString 网络图片地址
 @param state UIControlState
 */
- (void)znk_setImageWithURL:(NSString *)URLString forState:(UIControlState)state{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:nil isBackgroundImage:NO fixSize:NO options:MediaFactoryImageOptionsNormal completion:nil];
}

/**
 网络图片设置按钮二
 
 @param URLString 网络图片地址
 @param state UIControlState
 @param placeholderImage 占位图片
 */
- (void)znk_setImageWithURL:(NSString *)URLString forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage isBackgroundImage:NO fixSize:NO options:MediaFactoryImageOptionsNormal completion:nil];
}

/**
 网络图片设置按钮三
 
 @param URLString 网络图片地址
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 */
- (void)znk_setImageWithURL:(NSString *)URLString forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage options:(MediaFactoryImageOptions)options{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage isBackgroundImage:NO fixSize:NO options:options completion:nil];
}

/**
 网络图片设置按钮四
 
 @param URLString 网络图片地址
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 @param fixSize 以图片宽高最小值裁剪
 */
- (void)znk_setImageWithURL:(NSString *)URLString forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage options:(MediaFactoryImageOptions)options fixSize:(BOOL)fixSize{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage isBackgroundImage:NO fixSize:fixSize options:options completion:nil];
}

/**
 网络图片设置按钮五
 
 @param URLString 网络图片地址
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 @param fixSize 以图片宽高最小值裁剪
 @param completion 完成block
 */
- (void)znk_setImageWithURL:(NSString *)URLString forState:(UIControlState)state placeholderImage:(UIImage *)placeholderImage options:(MediaFactoryImageOptions)options fixSize:(BOOL)fixSize compeltion:(void(^)(BOOL finished, NSError * _Nullable error, UIImage * _Nullable image))completion{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage isBackgroundImage:NO fixSize:fixSize options:options completion:completion];
}

#pragma mark - set background image

/**
 网络图片背景设置按钮一
 
 @param URLString 网络图片地址
 @param state UIControlState
 */
- (void)znk_setBackgroundImageWithURL:(NSString *_Nullable)URLString forState:(UIControlState)state{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:nil isBackgroundImage:YES fixSize:NO options:MediaFactoryImageOptionsNormal completion:nil];
}

/**
 网络图片背景设置按钮二
 
 @param URLString 网络图片地址
 @param state UIControlState
 @param placeholderImage 占位图片
 */
- (void)znk_setBackgroundImageWithURL:(NSString *_Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage isBackgroundImage:YES fixSize:NO options:MediaFactoryImageOptionsNormal completion:nil];
}

/**
 网络图片背景设置按钮三
 
 @param URLString 网络图片地址
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 */
- (void)znk_setBackgroundImageWithURL:(NSString *_Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage isBackgroundImage:YES fixSize:NO options:options completion:nil];
}

/**
 网络图片背景设置按钮四
 
 @param URLString 网络图片地址
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 @param fixSize 以图片宽高最小值裁剪
 */
- (void)znk_setBackgroundImageWithURL:(NSString *_Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options fixSize:(BOOL)fixSize{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage isBackgroundImage:YES fixSize:fixSize options:options completion:nil];
}

/**
 网络图片背景设置按钮五
 
 @param URLString 网络图片地址
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 @param fixSize 以图片宽高最小值裁剪
 @param completion 完成block
 */
- (void)znk_setBackgroundImageWithURL:(NSString *_Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options fixSize:(BOOL)fixSize compeltion:(void(^_Nullable)(BOOL finished, NSError * _Nullable error, UIImage * _Nullable image))completion{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage isBackgroundImage:YES fixSize:fixSize options:options completion:completion];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
