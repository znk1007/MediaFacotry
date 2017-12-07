//
//  CommonHeader.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h
#import "MediaFactory.h"
#import "MediaButton.h"
#import "MediaImageView.h"

#pragma mark - 常用宏定义
/**颜色*/
#define MediaColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

/**宽高适配比例*/
#define WIDTH_RATE ([UIScreen mainScreen].bounds.size.width / 375.0f)
#define HEIGHT_RATE ([UIScreen mainScreen].bounds.size.height / 667.0f)

#define IMG_SCROLL_H (453 * HEIGHT_RATE)//预览图高度
#define CLIP_SQAURE CGSizeMake([UIScreen mainScreen].bounds.size.width, IMG_SCROLL_H)//裁剪框大小

#endif /* CommonHeader_h */
