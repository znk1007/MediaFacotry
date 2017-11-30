//
//  MediaToast.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ShowToastAtTop(format, ...) \
[MediaToast showAtTop:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToast(format, ...) \
[MediaToast show:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToastLongAtTop(format, ...) \
[MediaToast showLongAtTop:[NSString stringWithFormat:format, ## __VA_ARGS__]]

#define ShowToastLong(format, ...) \
[MediaToast showLong:[NSString stringWithFormat:format, ## __VA_ARGS__]]

@interface MediaToast : NSObject
//显示提示视图, 默认显示在屏幕上方，防止被软键盘覆盖，1.5s后自动消失
+ (void)showAtTop:(NSString *)message;

//显示提示视图, 默认显示在屏幕下方，1.5s后自动消失
+ (void)show:(NSString *)message;

//显示提示视图, 默认显示在屏幕上方，防止被软键盘覆盖,3s后自动消失
+ (void)showLongAtTop:(NSString *)message;

//显示提示视图, 默认显示在屏幕下方,3s后自动消失
+ (void)showLong:(NSString *)message;
@end
