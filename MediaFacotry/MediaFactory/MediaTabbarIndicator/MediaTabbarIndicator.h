//
//  MediaTabbarIndicator.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/12/8.
//  Copyright © 2017年 HM. All rights reserved.
//

#define TabbarRedDotTag (10000)
#define DefaultRedDotWidthAndHeight (10)

#import <UIKit/UIKit.h>

typedef enum {
    /**红点*/
    MediaTabbarIndicatorTypeRedDot,
    /**数字*/
    MediaTabbarIndicatorTypeNumber,
}MediaTabbarIndicatorType;

@interface UITabBar (MediaTabbarIndicator)

/**
 显示角标

 @param index 下标
 @param items tabbar item总数
 @param type MediaTabbarIndicatorType
 @param number 数字
 */
- (void)showBadgeOnItemIndex:(int)index totalItems:(int)items indicatorType:(MediaTabbarIndicatorType)type number:(int)number;

/**
 隐藏tabbar角标

 @param index 对应下标
 */
- (void)hideBadgeOnItemIndex:(int)index;
@end
