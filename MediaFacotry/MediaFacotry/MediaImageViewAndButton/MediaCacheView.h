//
//  MediaCacheView.h
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/28.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaCacheViewHeader.h"

@interface UIView (MediaFacotryCacheView)
/**
 加载菊花
 */
@property (nonatomic, strong) UIActivityIndicatorView * _Nullable indicatorView;

/**
 遮罩
 */
@property (nonatomic, strong) UIView * _Nullable coverView;

/**
 进度条
 */
@property (nonatomic, strong) UIProgressView * _Nullable progressView;

/**
 添加菊花
 */
- (void)znk_addIndicatorView;

/**
 移除菊花
 */
- (void)znk_removeIndicatorView;

/**
 添加遮罩
 */
- (void)znk_addCoverView;

/**
 移除遮罩
 */
- (void)znk_removeCoverView;

/**
 添加进度条
 */
- (void)znk_addProgressViewWithProgress:(float)progress;

/**
 移除
 */
- (void)znk_removeProgressView;

/**
 UIImageView、UIButton设置网络图片基方法
 
 @param URLString 下载路径
 @param placeholderImage 占位图
 @param isBackgroundImage UIButton是否为backgroundImage
 @param options MediaFactoryImageOptions
 @param completion 完成block
 */
- (void)znk_setImageWithURLString:(NSString * _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage * _Nullable)placeholderImage isBackgroundImage:(BOOL)isBackgroundImage fixSize:(BOOL)fixSize options:(MediaFactoryImageOptions)options completion:(void(^_Nullable)(BOOL finished, NSError * _Nullable error, UIImage * _Nullable image))completion;
@end
