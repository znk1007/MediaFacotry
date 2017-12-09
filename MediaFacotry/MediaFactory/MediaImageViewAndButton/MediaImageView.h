//
//  MediaImageView.h
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/28.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaCacheViewHeader.h"

@interface UIImageView (MediaFacotryImageView)
/**
 UIImageView 设置网络图片一
 
 @param URLString 网络图片路径 / UIImage
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString;

/**
 UIImageView 设置网络图片二
 
 @param URLString 网络图片路径 / UIImage
 @param placeholderImage 占位图片
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage;

/**
 UIImageView 设置网络图片三

 @param URLString 网络图片路径 / UIImage
 @param placeholderImage 占位图片
 @param fixSize 以图片宽高最小值裁剪
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage fixSize:(BOOL)fixSize;

/**
 UIImageView 设置网络图片四

 @param URLString 网络图片路径 / UIImage
 @param placeholderImage 占位图片
 @param fixSize 以图片宽高最小值裁剪
 @param options MediaFactoryImageOptions
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage fixSize:(BOOL)fixSize options:(MediaFactoryImageOptions)options;

/**
 UIImageView 设置网络图片五
 
 @param URLString 网络图片路径 / UIImage
 @param placeholderImage 占位图片
 @param fixSize 以图片宽高最小值裁剪
 @param options MediaFactoryImageOptions
 @param completion 完成block
 */
- (void)znk_setImageWithURLString:(id _Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage fixSize:(BOOL)fixSize options:(MediaFactoryImageOptions)options compeltion:(void(^_Nullable)(BOOL finished, NSError * _Nullable error, UIImage * _Nullable image))completion;
@end
