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

#pragma mark - 常用宏定义
/**颜色*/
#define MediaColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

/**MediaViewImgViewController*/
#define kItemMargin 40

/**MediaViewImageCell 不建议设置太大，太大的话会导致图片加载过慢*/
#define kMaxImageWidth 500

/**屏幕宽*/
#define kMediaScreenWidth   [UIScreen mainScreen].bounds.size.width
/**屏幕高*/
#define kMediaScreenHeight  [UIScreen mainScreen].bounds.size.height


/**裁剪系数*/
#define ClippingRatioValue1 @"value1"
#define ClippingRatioValue2 @"value2"
#define ClippingRatioTitleFormat @"titleFormat"

static inline NSDictionary *
GetCustomClipRatio() {
    return @{ClippingRatioValue1: @(0), ClippingRatioValue2: @(0), ClippingRatioTitleFormat: @"Custom"};
}

static inline NSDictionary * GetClipRatio(NSInteger value1, NSInteger value2) {
    return @{ClippingRatioValue1: @(value1), ClippingRatioValue2: @(value2), ClippingRatioTitleFormat: @"%g : %g"};
}
#endif /* CommonHeader_h */
