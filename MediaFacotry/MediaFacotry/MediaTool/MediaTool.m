//
//  MediaTool.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaTool.h"
#import "CommonHeader.h"

@interface MediaTool () <PHPhotoLibraryChangeObserver>
/**
 相册权限发生变化
 */
@property (nonatomic, copy) void (^ _Nullable photoAlbumAuthorizedChanged)(void);
/**
 预览模式
 */
@property (nonatomic, assign) BOOL preview;

/**
 启用动画
 */
@property (nonatomic, assign) BOOL animate;
@end

@implementation MediaTool

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupDefault];
    }
    return self;
}

- (void)setupDefault{
    _maxSelectCount = 9;
    _maxPreviewCount = 20;
    _maxVideoDuration = 120;
    _maxEditVideoTime = 10;
    
    _allowMixSelect = YES;
    _allowSelectImage = YES;
    _allowSelectVideo = YES;
    _allowSelectGif = YES;
    _allowSelectLivePhoto = NO;
    _allowTakePhotoInLibrary = YES;
    _allowForceTouch = YES;
    _allowEditImage = YES;
    _allowEditVideo = NO;
    _allowSelectOriginal = YES;
    _allowSlideSelect = YES;
    _allowDragSelect = NO;
    _editAfterSelectThumbnailImage = NO;
    _showCaptureImageOnTakePhotoBtn = YES;
    _sortAscending = YES;
    _showSelectBtn = NO;
    _showSelectedMask = NO;
    _shouldAnialysisAsset = NO;
    _preview = NO;
    _animate = NO;
    _useCustomCamera = NO;
    _allowRecordVideo = YES;
    _maxRecordDuration = 8;
    _photoAlbumAuthorizedChanged = nil;
    _sessionPreset = MediaCaptureSessionPreset640x480;
    _exportType = MediaVideoExportTypeMP4;
    if (!self.photoAlbumAuthorized) {
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    }
    
}

#pragma mark - getter

- (NSMutableArray<MediaModel *> *)arrSelectedModels{
    if (!_arrSelectedModels) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}


#pragma mark - setter

- (void)setMaxEditVideoTime:(NSInteger)maxEditVideoTime{
    _maxEditVideoTime = MAX(maxEditVideoTime, 10);
}

- (void)setMaxSelectCount:(NSInteger)maxSelectCount{
    _maxSelectCount = MAX(maxSelectCount, 1);
}


- (void)setMaxRecordDuration:(NSInteger)maxRecordDuration{
    _maxRecordDuration = MAX(maxRecordDuration, 3);
}

#pragma mark - getter

- (BOOL)photoAlbumAuthorized{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

- (BOOL)cameraAuthorized{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

- (BOOL)cameraAvailable{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        return YES;
    }
    return NO;
}


#pragma mark - Public Method

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_photoAlbumAuthorizedChanged) {
            _photoAlbumAuthorizedChanged();
        }
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    });
}

/**
 监测相册权限变化
 */
- (void)watchAlbumAuthorizeChange:(void(^)(void))change{
    if (!self.photoAlbumAuthorized) {
        _photoAlbumAuthorizedChanged = change;
        //注册实施监听相册变化
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
    }
}

/**
 获取时长

 @param duration 时长
 @return NSInteger
 */
- (NSInteger)getDuration:(NSString *)duration{
    NSArray *arr = [duration componentsSeparatedByString:@":"];
    NSInteger d = 0;
    for (int i = 0; i < arr.count; i++) {
        d += [arr[i] integerValue] * pow(60, (arr.count-1-i));
    }
    return d;
}

/**
 按钮动画

 @return CAKeyframeAnimation
 */
- (CAKeyframeAnimation *)viewStatusChangedAnimation{
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

/**
 视图动画from to
 
 @param from 起始
 @param to 结束
 @param duration 时长
 @param path 路径
 @return CABasicAnimation
 */
- (CABasicAnimation * _Nullable)viewPositionAnimationFrom:(id _Nullable )from toValue:(id _Nullable )to animationDuration:(CFTimeInterval)duration keyPath:(NSString *_Nullable)path {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:path];
        animation.fromValue = from;
        animation.toValue   = to;
        animation.duration = duration;
        animation.repeatCount = 0;
        animation.autoreverses = NO;
        //以下两个设置，保证了动画结束后，layer不会回到初始位置
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        return animation;
}

@end


