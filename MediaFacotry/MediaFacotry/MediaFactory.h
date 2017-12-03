//
//  MediaFactory.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

@import UIKit;

@interface MediaFactory : NSObject

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
