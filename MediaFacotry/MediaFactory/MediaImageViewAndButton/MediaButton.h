//
//  MediaButton.h
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/26.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaCacheViewHeader.h"

@interface UIButton (MediaFacotryButton)

#pragma mark - set image
/**
 网络图片设置按钮一

 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state;

/**
 网络图片设置按钮二

 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 @param placeholderImage 占位图片
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage;

/**
 网络图片设置按钮三

 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options;

/**
 网络图片设置按钮四

 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 @param fixSize 以图片宽高最小值裁剪
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options fixSize:(BOOL)fixSize;

/**
 网络图片设置按钮五
 
 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 @param fixSize 以图片宽高最小值裁剪
 @param completion 完成block
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options fixSize:(BOOL)fixSize compeltion:(void(^_Nullable)(BOOL finished, NSError * _Nullable error, UIImage * _Nullable image))completion;

#pragma mark - set background image

/**
 网络图片背景设置按钮一
 
 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 */
- (void)znk_setBackgroundImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state;

/**
 网络图片背景设置按钮二
 
 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 @param placeholderImage 占位图片
 */
- (void)znk_setBackgroundImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage;

/**
 网络图片背景设置按钮三
 
 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 */
- (void)znk_setBackgroundImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options;

/**
 网络图片背景设置按钮四
 
 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 @param fixSize 以图片宽高最小值裁剪
 */
- (void)znk_setBackgroundImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options fixSize:(BOOL)fixSize;

/**
 网络图片背景设置按钮五
 
 @param URLString 网络图片地址 / UIImage
 @param state UIControlState
 @param placeholderImage 占位图片
 @param options MediaFactoryImageOptions
 @param fixSize 以图片宽高最小值裁剪
 @param completion 完成block
 */
- (void)znk_setBackgroundImageWithURLString:(id _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage *_Nullable)placeholderImage options:(MediaFactoryImageOptions)options fixSize:(BOOL)fixSize compeltion:(void(^_Nullable)(BOOL finished, NSError * _Nullable error, UIImage * _Nullable image))completion;


@end

