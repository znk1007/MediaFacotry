//
//  MediaButton.h
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/26.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    /**静默加载*/
    MediaFactoryImageOptionsNormal,
    /**遮罩加载*/
    MediaFactoryImageOptionsCover,
    /**菊花加载*/
    MediaFactoryImageOptionsIndicator,
    /**菊花+遮罩加载*/
    MediaFactoryImageOptionsCoverAndIndicator,
    /**进度条加载*/
    MediaFactoryImageOptionsProgressBar,
    /**遮罩+进度条加载*/
    MediaFactoryImageOptionsCorverAndProgressBar,
}MediaFactoryImageOptions;

@interface UIButton (MediaFacotry)

@end
