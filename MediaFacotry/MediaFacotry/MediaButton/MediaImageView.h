//
//  MediaImageView.h
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/28.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (MediaFacotryImageView)
/**
 UIImageView 设置网络图片
 
 @param URLString 网络图片路径
 */
- (void)znk_setImageWithURLString:(NSString *_Nullable)URLString;

/**
 UIImageView 设置网络图片
 
 @param URLString 网络图片路径
 @param placeholderImage 占位图片
 */
- (void)znk_setImageWithURLString:(NSString *_Nullable)URLString placeholderImage:(UIImage *_Nullable)placeholderImage;
@end
