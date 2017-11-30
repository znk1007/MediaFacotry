//
//  MediaStyle.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaStyle : NSObject
/**
 状态栏颜色 默认白色
 */
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

/**
 导航栏样式 默认浅色
 */
@property (nonatomic, assign) UIBarStyle barStyle;

/**
 导航栏半透明 默认NO
 */
@property (nonatomic, assign) BOOL navTranslucent;

/**
 cell的圆角弧度 默认为0
 */
@property (nonatomic, assign) CGFloat cellCornerRadio;

/**
 导航条颜色，默认 [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor *navBarColor;

/**
 导航标题颜色，默认 [UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *navTitleColor;

/**
 底部工具条底色，默认 [UIColor whiteColor]
 */
@property (nonatomic, strong) UIColor *bottomViewBgColor;

/**
 底部工具栏按钮 可交互 状态标题颜色，底部 toolbar 按钮可交互状态title颜色均使用这个，确定按钮 可交互 的背景色为这个，默认MediaColor(80, 180, 234)
 */
@property (nonatomic, strong) UIColor *bottomBtnsNormalTitleColor;

/**
 底部工具栏按钮 不可交互 状态标题颜色，底部 toolbar 按钮不可交互状态颜色均使用这个，确定按钮 不可交互 的背景色为这个，默认MediaColor(200, 200, 200)
 */
@property (nonatomic, strong) UIColor *bottomBtnsDisableBgColor;


/**
 遮罩层颜色，内部会默认调整颜色的透明度为0.2， 默认 blackColor
 */
@property (nonatomic, strong) UIColor *selectedMaskColor;

/**
 裁剪左视图图片 默认颜色生成
 */
@property (nonatomic, strong) UIImage *leftCutImage;

/**
 裁剪右视图图片 默认颜色生成
 */
@property (nonatomic, strong) UIImage *rightCutImage;

/**
 裁剪播放进度条
 */
@property (nonatomic, strong) UIImage *cutBarImage;

@end
