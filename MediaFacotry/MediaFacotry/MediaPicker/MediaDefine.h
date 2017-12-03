//
//  MediaDefine.h
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#ifndef MediaDefine_h
#define MediaDefine_h

#import "MediaProgressHUD.h"
#import "NSBundle+MediaPhotoBrowser.h"

#define MediaPhotoBrowserCameraText @"MediaPhotoBrowserCameraText"
#define MediaPhotoBrowserAblumText @"MediaPhotoBrowserAblumText"
#define MediaPhotoBrowserCancelText @"MediaPhotoBrowserCancelText"
#define MediaPhotoBrowserOriginalText @"MediaPhotoBrowserOriginalText"
#define MediaPhotoBrowserDoneText @"MediaPhotoBrowserDoneText"
#define MediaPhotoBrowserOKText @"MediaPhotoBrowserOKText"
#define MediaPhotoBrowserBackText @"MediaPhotoBrowserBackText"
#define MediaPhotoBrowserPhotoText @"MediaPhotoBrowserPhotoText"
#define MediaPhotoBrowserPreviewText @"MediaPhotoBrowserPreviewText"
#define MediaPhotoBrowserLoadingText @"MediaPhotoBrowserLoadingText"
#define MediaPhotoBrowserHandleText @"MediaPhotoBrowserHandleText"
#define MediaPhotoBrowserSaveImageErrorText @"MediaPhotoBrowserSaveImageErrorText"
#define MediaPhotoBrowserMaxSelectCountText @"MediaPhotoBrowserMaxSelectCountText"
#define MediaPhotoBrowserNoCameraAuthorityText @"MediaPhotoBrowserNoCameraAuthorityText"
#define MediaPhotoBrowserNoAblumAuthorityText @"MediaPhotoBrowserNoAblumAuthorityText"
#define MediaPhotoBrowserNoMicrophoneAuthorityText @"MediaPhotoBrowserNoMicrophoneAuthorityText"
#define MediaPhotoBrowseriCloudPhotoText @"MediaPhotoBrowseriCloudPhotoText"
#define MediaPhotoBrowserGifPreviewText @"MediaPhotoBrowserGifPreviewText"
#define MediaPhotoBrowserVideoPreviewText @"MediaPhotoBrowserVideoPreviewText"
#define MediaPhotoBrowserLivePhotoPreviewText @"MediaPhotoBrowserLivePhotoPreviewText"
#define MediaPhotoBrowserNoPhotoText @"MediaPhotoBrowserNoPhotoText"
#define MediaPhotoBrowserCannotSelectVideo @"MediaPhotoBrowserCannotSelectVideo"
#define MediaPhotoBrowserCannotSelectGIF @"MediaPhotoBrowserCannotSelectGIF"
#define MediaPhotoBrowserCannotSelectLivePhoto @"MediaPhotoBrowserCannotSelectLivePhoto"
#define MediaPhotoBrowseriCloudVideoText @"MediaPhotoBrowseriCloudVideoText"
#define MediaPhotoBrowserEditText @"MediaPhotoBrowserEditText"
#define MediaPhotoBrowserSaveText @"MediaPhotoBrowserSaveText"
#define MediaPhotoBrowserMaxVideoDurationText @"MediaPhotoBrowserMaxVideoDurationText"
#define MediaPhotoBrowserLoadNetImageFailed @"MediaPhotoBrowserLoadNetImageFailed"
#define MediaPhotoBrowserSaveVideoFailed @"MediaPhotoBrowserSaveVideoFailed"

#define MediaPhotoBrowserCameraRoll @"MediaPhotoBrowserCameraRoll"
#define MediaPhotoBrowserPanoramas @"MediaPhotoBrowserPanoramas"
#define MediaPhotoBrowserVideos @"MediaPhotoBrowserVideos"
#define MediaPhotoBrowserFavorites @"MediaPhotoBrowserFavorites"
#define MediaPhotoBrowserTimelapses @"MediaPhotoBrowserTimelapses"
#define MediaPhotoBrowserRecentlyAdded @"MediaPhotoBrowserRecentlyAdded"
#define MediaPhotoBrowserBursts @"MediaPhotoBrowserBursts"
#define MediaPhotoBrowserSlomoVideos @"MediaPhotoBrowserSlomoVideos"
#define MediaPhotoBrowserSelfPortraits @"MediaPhotoBrowserSelfPortraits"
#define MediaPhotoBrowserScreenshots @"MediaPhotoBrowserScreenshots"
#define MediaPhotoBrowserDepthEffect @"MediaPhotoBrowserDepthEffect"
#define MediaPhotoBrowserLivePhotos @"MediaPhotoBrowserLivePhotos"
#define MediaPhotoBrowserAnimated @"MediaPhotoBrowserAnimated"

#define kMediaRGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#define media_weak(var)   __weak typeof(var) weakSelf = var
#define media_strong(var) __strong typeof(var) strongSelf = var

#define Media_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Media_IS_IPHONE_X (Media_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0f)
#define Media_SafeAreaBottom (Media_IS_IPHONE_X ? 34 : 0)

#define kZLPhotoBrowserBundle [NSBundle bundleForClass:[self class]]

// 图片路径
#define kZLPhotoBrowserSrcName(file) [@"MediaPhotoBrowser.bundle" stringByAppendingPathComponent:file]
#define kZLPhotoBrowserFrameworkSrcName(file) [@"Frameworks/MediaPhotoBrowser.framework/MediaPhotoBrowser.bundle" stringByAppendingPathComponent:file]

#define kMediaViewWidth      [[UIScreen mainScreen] bounds].size.width
#define kViewHeight     [[UIScreen mainScreen] bounds].size.height

//app名字
#define kAPPName [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"] ?: [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]

//自定义图片名称存于plist中的key
#define MediaCustomImageNames @"MediaCustomImageNames"
//设置框架语言的key
#define MediaLanguageTypeKey @"MediaLanguageTypeKey"

////////MediaShowBigImgViewController
#define kMediaItemMargin 40

///////MediaBigImageCell 不建议设置太大，太大的话会导致图片加载过慢
#define kMaxImageWidth 500

#define ClippingRatioValue1 @"value1"
#define ClippingRatioValue2 @"value2"
#define ClippingRatioTitleFormat @"titleFormat"

typedef NS_ENUM(NSUInteger, MediaLanguageType) {
    //跟随系统语言，默认
    MediaLanguageSystem,
    //中文简体
    MediaLanguageChineseSimplified,
    //中文繁体
    MediaLanguageChineseTraditional,
    //英文
    MediaLanguageEnglish,
    //日文
    MediaLanguageJapanese,
};

typedef NS_ENUM(NSUInteger, MediaCaptureSessionPreset) {
    MediaCaptureSessionPreset325x288,
    MediaCaptureSessionPreset640x480,
    MediaCaptureSessionPreset1280x720,
    MediaCaptureSessionPreset1920x1080,
    MediaCaptureSessionPreset3840x2160,
};

typedef NS_ENUM(NSUInteger, MediaExportVideoType) {
    MediaExportVideoTypeMov,
    MediaExportVideoTypeMp4,
    MediaExportVideoType3gp,
};

static inline void SetViewWidth(UIView *view, CGFloat width) {
    CGRect frame = view.frame;
    frame.size.width = width;
    view.frame = frame;
}

static inline CGFloat GetViewWidth(UIView *view) {
    return view.frame.size.width;
}

static inline void SetViewHeight(UIView *view, CGFloat height) {
    CGRect frame = view.frame;
    frame.size.height = height;
    view.frame = frame;
}

static inline CGFloat GetViewHeight(UIView *view) {
    return view.frame.size.height;
}

static inline NSString *  GetLocalLanguageTextValue (NSString *key) {
    return [NSBundle MediaLocalizedStringForKey:key];
}

static inline UIImage * GetImageWithName(NSString *name) {
    NSArray *names = [[NSUserDefaults standardUserDefaults] valueForKey:MediaCustomImageNames];
    if ([names containsObject:name]) {
        return [UIImage imageNamed:name];
    }
    return [UIImage imageNamed:kZLPhotoBrowserSrcName(name)]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(name)];
}

static inline CGFloat GetMatchValue(NSString *text, CGFloat fontSize, BOOL isHeightFixed, CGFloat fixedValue) {
    CGSize size;
    if (isHeightFixed) {
        size = CGSizeMake(MAXFLOAT, fixedValue);
    } else {
        size = CGSizeMake(fixedValue, MAXFLOAT);
    }
    
    CGSize resultSize;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        //返回计算出的size
        resultSize = [text boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
    }
    if (isHeightFixed) {
        return resultSize.width;
    } else {
        return resultSize.height;
    }
}

static inline void ShowAlert(NSString *message, UIViewController *sender) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(MediaPhotoBrowserOKText) style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [sender presentViewController:alert animated:YES completion:nil];
}

static inline CABasicAnimation * GetPositionAnimation(id fromValue, id toValue, CFTimeInterval duration, NSString *keyPath) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration = duration;
    animation.repeatCount = 0;
    animation.autoreverses = NO;
    //以下两个设置，保证了动画结束后，layer不会回到初始位置
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

static inline CAKeyframeAnimation * GetBtnStatusChangedAnimation() {
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animate.duration = 0.3;
    animate.removedOnCompletion = YES;
    animate.fillMode = kCAFillModeForwards;
    
    animate.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)],
                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    return animate;
}

static inline NSInteger GetDuration (NSString *duration) {
    NSArray *arr = [duration componentsSeparatedByString:@":"];
    
    NSInteger d = 0;
    for (int i = 0; i < arr.count; i++) {
        d += [arr[i] integerValue] * pow(60, (arr.count-1-i));
    }
    return d;
}


static inline NSDictionary *
GetCustomClipRatio() {
    return @{ClippingRatioValue1: @(0), ClippingRatioValue2: @(0), ClippingRatioTitleFormat: @"Custom"};
}

static inline NSDictionary * GetClipRatio(NSInteger value1, NSInteger value2) {
    return @{ClippingRatioValue1: @(value1), ClippingRatioValue2: @(value2), ClippingRatioTitleFormat: @"%g : %g"};
}

#endif /* MediaDefine_h */
