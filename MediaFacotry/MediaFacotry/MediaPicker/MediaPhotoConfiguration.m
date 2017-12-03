//
//  MediaPhotoConfiguration.m
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPhotoConfiguration.h"

@implementation MediaPhotoConfiguration

- (void)dealloc
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MediaCustomImageNames];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MediaLanguageTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSLog(@"---- %s", __FUNCTION__);
}

+ (instancetype)customPhotoConfiguration{
    MediaPhotoConfiguration *customConfiguration = [self defaultPhotoConfiguration];
    customConfiguration.navBarColor = kMediaRGB(0, 0, 0);
    customConfiguration.uploadImmediately = YES;
    customConfiguration.clipImageSize = CGSizeZero;
    customConfiguration.editImmediately = YES;
    customConfiguration.hideBottom = YES;
    customConfiguration.hideBackText = YES;
    customConfiguration.showConfirmText = YES;
    return customConfiguration;
}

+ (instancetype)defaultPhotoConfiguration
{
    MediaPhotoConfiguration *configuration = [MediaPhotoConfiguration new];
    
    configuration.uploadImmediately = NO;
    configuration.statusBarStyle = UIStatusBarStyleLightContent;
    configuration.maxSelectCount = 9;
    configuration.maxPreviewCount = 20;
    configuration.cellCornerRadio = .0;
    configuration.allowMixSelect = YES;
    configuration.allowSelectImage = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectGif = YES;
    configuration.allowSelectLivePhoto = NO;
    configuration.allowTakePhotoInLibrary = YES;
    configuration.allowForceTouch = YES;
    configuration.allowEditImage = YES;
    configuration.allowEditVideo = NO;
    configuration.allowSelectOriginal = YES;
    configuration.maxEditVideoTime = 10;
    configuration.maxVideoDuration = 120;
    configuration.allowSlideSelect = YES;
    configuration.allowDragSelect = NO;
    configuration.clipRatios = @[GetCustomClipRatio(),
                                 GetClipRatio(1, 1),
                                 GetClipRatio(4, 3),
                                 GetClipRatio(3, 2),
                                 GetClipRatio(16, 9)];
    configuration.editAfterSelectThumbnailImage = NO;
    configuration.showCaptureImageOnTakePhotoBtn = YES;
    configuration.sortAscending = YES;
    configuration.showSelectBtn = NO;
    configuration.navBarColor = kMediaRGB(19, 153, 231);
    configuration.navTitleColor = [UIColor whiteColor];
    configuration.bottomViewBgColor = [UIColor whiteColor];
    configuration.bottomBtnsNormalTitleColor = kMediaRGB(80, 180, 234);
    configuration.bottomBtnsDisableBgColor = kMediaRGB(200, 200, 200);
    configuration.showSelectedMask = NO;
    configuration.selectedMaskColor = [UIColor blackColor];
    configuration.customImageNames = nil;
    configuration.shouldAnialysisAsset = YES;
    configuration.languageType = MediaLanguageSystem;
    configuration.useSystemCamera = NO;
    configuration.allowRecordVideo = YES;
    configuration.maxRecordDuration = 10;
    configuration.sessionPreset = MediaCaptureSessionPreset1280x720;
    configuration.exportVideoType = MediaExportVideoTypeMov;
    
    return configuration;
}

- (void)setMaxSelectCount:(NSInteger)maxSelectCount
{
    _maxSelectCount = MAX(maxSelectCount, 1);
    
    if (maxSelectCount > 1) {
        _showSelectBtn = YES;
    }
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn
{
    if (self.maxSelectCount > 1) {
        _showSelectBtn = YES;
    } else {
        _showSelectBtn = showSelectBtn;
    }
}

- (void)setAllowSelectLivePhoto:(BOOL)allowSelectLivePhoto
{
    if (@available(iOS 9.0, *)) {
        _allowSelectLivePhoto = allowSelectLivePhoto;
    } else {
        _allowSelectLivePhoto = NO;
    }
}

- (void)setMaxEditVideoTime:(NSInteger)maxEditVideoTime
{
    _maxEditVideoTime = MAX(maxEditVideoTime, 10);
}

- (void)setCustomImageNames:(NSArray<NSString *> *)customImageNames
{
    _customImageNames = customImageNames;
    [[NSUserDefaults standardUserDefaults] setValue:customImageNames forKey:MediaCustomImageNames];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setLanguageType:(MediaLanguageType)languageType
{
    [[NSUserDefaults standardUserDefaults] setValue:@(languageType) forKey:MediaLanguageTypeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSBundle resetLanguage];
}

- (void)setMaxRecordDuration:(NSInteger)maxRecordDuration
{
    _maxRecordDuration = MAX(maxRecordDuration, 1);
}

@end
