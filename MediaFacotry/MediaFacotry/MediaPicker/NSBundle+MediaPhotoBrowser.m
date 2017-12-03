//
//  NSBundle+MediaPhotoBrowser.m
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "NSBundle+MediaPhotoBrowser.h"
#import "MediaPhotoActionSheet.h"
#import "MediaDefine.h"

@implementation NSBundle (MediaPhotoBrowser)

+ (instancetype)MediaPhotoBrowserBundle
{
    static NSBundle *photoBrowserBundle = nil;
    if (photoBrowserBundle == nil) {
        photoBrowserBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[MediaPhotoActionSheet class]] pathForResource:@"MediaPhotoBrowser" ofType:@"bundle"]];
    }
    return photoBrowserBundle;
}

static NSBundle *bundle = nil;
+ (void)resetLanguage
{
    bundle = nil;
}

+ (NSString *)MediaLocalizedStringForKey:(NSString *)key
{
    return [self MediaLocalizedStringForKey:key value:nil];
}

+ (NSString *)MediaLocalizedStringForKey:(NSString *)key value:(NSString *)value
{
    if (bundle == nil) {
        // 从bundle中查找资源
        bundle = [NSBundle bundleWithPath:[[NSBundle MediaPhotoBrowserBundle] pathForResource:[self getLanguage] ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:value table:nil];
}

+ (NSString *)getLanguage
{
    MediaLanguageType type = [[[NSUserDefaults standardUserDefaults] valueForKey:MediaLanguageTypeKey] integerValue];
    
    NSString *language = nil;
    switch (type) {
        case MediaLanguageSystem: {
            language = [NSLocale preferredLanguages].firstObject;
            if ([language hasPrefix:@"en"]) {
                language = @"en";
            } else if ([language hasPrefix:@"zh"]) {
                if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                    language = @"zh-Hans"; // 简体中文
                } else { // zh-Hant\zh-HK\zh-TW
                    language = @"zh-Hant"; // 繁體中文
                }
            } else if ([language hasPrefix:@"ja"]) {
                language = @"ja-US";
            } else {
                language = @"en";
            }
        }
            break;
        case MediaLanguageChineseSimplified:
            language = @"zh-Hans";
            break;
        case MediaLanguageChineseTraditional:
            language = @"zh-Hant";
            break;
        case MediaLanguageEnglish:
            language = @"en";
            break;
        case MediaLanguageJapanese:
            language = @"ja-US";
            break;
    }
    return language;
}

@end
