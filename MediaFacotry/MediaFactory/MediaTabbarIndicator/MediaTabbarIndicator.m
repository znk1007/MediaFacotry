//
//  MediaTabbarIndicator.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/12/8.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaTabbarIndicator.h"

@implementation UITabBar (MediaTabbarIndicator)
/**
 显示角标
 
 @param index 下标
 @param items tabbar item总数
 @param type MediaTabbarIndicatorType
 @param number 数字
 */
- (void)showBadgeOnItemIndex:(int)index totalItems:(int)items indicatorType:(MediaTabbarIndicatorType)type number:(int)number{
    switch (type) {
        case MediaTabbarIndicatorTypeRedDot:
        {
            [self showBadgeOnItemIndex:index totalItems:items];
        }
            break;
        case MediaTabbarIndicatorTypeNumber:
        {
            [self showBadgeOnItemIndex:index totalItems:items number:number];
        }
            break;
        default:
            break;
    }
}

- (void)showBadgeOnItemIndex:(int)index totalItems:(int)items{
    [self removeDotAtIndex:index];
    UIView *dotView = [UIView new];
    dotView.backgroundColor = [UIColor colorWithRed:(255)/255.0 green:(96)/255.0 blue:(94)/255.0 alpha:1.0];
    dotView.tag = TabbarRedDotTag + index;
    CGFloat offsetX = (index + 0.6) / items;
    CGFloat x = ceilf(offsetX * CGRectGetWidth(self.frame));
    CGFloat y = ceilf(0.1 * CGRectGetHeight(self.frame));
    dotView.frame = CGRectMake(x, y, DefaultRedDotWidthAndHeight, DefaultRedDotWidthAndHeight);
    dotView.layer.cornerRadius = CGRectGetHeight(dotView.frame) / 2;
    dotView.layer.masksToBounds = YES;
    [self addSubview:dotView];
    [self bringSubviewToFront:dotView];
}

- (void)showBadgeOnItemIndex:(int)index totalItems:(int)items number:(int)number{
    [self removeDotAtIndex:index];
    UILabel *numLabel = [UILabel new];
    numLabel.backgroundColor = [UIColor colorWithRed:(255)/255.0 green:(96)/255.0 blue:(94)/255.0 alpha:1.0];
    numLabel.tag = TabbarRedDotTag + index;
    CGFloat offsetX = (index + 0.6) / items;
    CGFloat x = ceilf(offsetX * CGRectGetWidth(self.frame));
    CGFloat y = ceilf(0.1 * CGRectGetHeight(self.frame));
    numLabel.frame = CGRectMake(x, y, DefaultRedDotWidthAndHeight, DefaultRedDotWidthAndHeight);
    numLabel.layer.cornerRadius = CGRectGetHeight(numLabel.frame) / 2;
    numLabel.layer.masksToBounds = YES;
    numLabel.text = [NSString stringWithFormat:@"%d",number];
    numLabel.font = [UIFont systemFontOfSize:8];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.textColor = [UIColor whiteColor];
    [self addSubview:numLabel];
    [self bringSubviewToFront:numLabel];
}

- (void)hideBadgeOnItemIndex:(int)index{
    [self removeDotAtIndex:index];
}

- (void)removeDotAtIndex:(int)index{
    for (UIView *dotView in self.subviews) {
        if (dotView.tag == TabbarRedDotTag + index) {
            [dotView removeFromSuperview];
        }
    }
}

@end
