//
//  NSBundle+MediaPhotoBrowser.h
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (MediaPhotoBrowser)

+ (instancetype)MediaPhotoBrowserBundle;

+ (void)resetLanguage;

+ (NSString *)MediaLocalizedStringForKey:(NSString *)key;

+ (NSString *)MediaLocalizedStringForKey:(NSString *)key value:(NSString *)value;

@end
