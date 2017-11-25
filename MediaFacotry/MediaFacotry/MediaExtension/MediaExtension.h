//
//  MediaExtension.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaExtension : NSObject

@end

#pragma mark - UIView

@interface UIView (MediaExtension)

/**
 x坐标
 */
@property (nonatomic,assign)CGFloat x;

/**
 y坐标
 */
@property (nonatomic,assign)CGFloat y;

/**
 宽
 */
@property (nonatomic,assign)CGFloat height;

/**
 高
 */
@property (nonatomic,assign)CGFloat width;

/**
 中心x坐标
 */
@property (nonatomic,assign)CGFloat centerX;

/**
 中心y坐标
 */
@property (nonatomic,assign)CGFloat centerY;

/**
 原始坐标
 */
@property (nonatomic,assign)CGPoint origin;

/**
 宽高
 */
@property (nonatomic,assign)CGSize size;

@end

#pragma mark - UIImage

@interface UIImage (MediaExtension)

/**
 改变图片颜色

 @param color 颜色
 @return 修改颜色后的图片
 */
- (UIImage *)transformImageWithColor:(UIColor *)color;

@end

#pragma mark - UIImage

@interface UIButton (MediaExtension)

/**
 按键缩放效果

 @param top 上嵌
 @param left 左嵌
 @param bottom 下嵌
 @param right 右嵌
 */
- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;
@end

#pragma mark - NSString

@interface NSString (MediaExtension)

/**
 适配View宽高

 @param fontSize 字体大小
 @param fixed 是否固定高
 @param value 固定值
 @return 自适应后的宽高
 */
- (CGFloat)matchView:(CGFloat)fontSize isHeightFixed:(BOOL)fixed fixedValue:(CGFloat)value;

@end
