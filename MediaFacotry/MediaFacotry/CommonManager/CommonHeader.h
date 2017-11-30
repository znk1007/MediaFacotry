//
//  CommonHeader.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h
#import "MediaFactory.h"

#pragma mark - 常用宏定义
/**颜色*/
#define MediaColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

/**MediaViewImgViewController*/
#define kItemMargin 40

/**MediaViewImageCell 不建议设置太大，太大的话会导致图片加载过慢*/
#define kMaxImageWidth 480

/**屏幕宽*/
#define kMediaScreenWidth   [UIScreen mainScreen].bounds.size.width
/**屏幕高*/
#define kMediaScreenHeight  [UIScreen mainScreen].bounds.size.height

/**手机适配*/
#define Media_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define Media_IS_IPHONE_X (Media_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0f)
#define Media_SafeAreaBottom (Media_IS_IPHONE_X ? 34 : 0)

#pragma mark - 裁剪相关
#define kMediaEditItemHeight 50.0f
#define kMediaEditItemWidth kMediaEditItemHeight * 2 / 3.0f

/**裁剪系数*/
#define ClippingRatioValue1 @"value1"
#define ClippingRatioValue2 @"value2"
#define ClippingRatioTitleFormat @"titleFormat"

/**app名称*/
//app名字
#define kMediaAPPName [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"] ? : [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey]

#pragma mark - ///////////////国际化相关\\\\\\\\\\\\\\\\\

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



static inline NSDictionary *
GetCustomClipRatio() {
    return @{ClippingRatioValue1: @(0), ClippingRatioValue2: @(0), ClippingRatioTitleFormat: @"Custom"};
}

static inline NSDictionary * GetClipRatio(NSInteger value1, NSInteger value2) {
    return @{ClippingRatioValue1: @(value1), ClippingRatioValue2: @(value2), ClippingRatioTitleFormat: @"%g : %g"};
}


#endif /* CommonHeader_h */
