//
//  MediaFactory.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//
#import "MediaStyle.h"
#import "MediaTool.h"

@import UIKit;
@import AVFoundation;
@import Photos;





@interface MediaFactory : NSObject

/**
 控件样式类
 */
@property (nonatomic, readonly) MediaStyle * _Nonnull style;

/**
 媒体工具类
 */
@property (nonatomic, readonly) MediaTool * _Nonnull tool;

/**
 MediaFactory单例

 @return MediaFactory
 */
+ (MediaFactory *_Nonnull)sharedFactory;

/**
 显示相册
 */
- (void)show;

/**
 退出相册
 */
- (void)hide;

@end
