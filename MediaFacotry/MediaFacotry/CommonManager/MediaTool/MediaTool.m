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
    _allowSelectImage = YES;
    _allowSelectVideo = YES;
    _allowSelectGif = YES;
    _allowSelectLivePhoto = NO;
    _allowTakePhotoInLibrary = YES;
    _allowForceTouch = YES;
    _allowEditImage = YES;
    _allowEditVideo = YES;
    _allowSelectOriginal = YES;
    _allowSlideSelect = YES;
    _allowDragSelect = NO;
    _editAfterSelectThumbnailImage = NO;
    _allowMixSelect = YES;
    _showCaptureImageOnTakePhotoBtn = YES;
    _sortAscending = YES;
    _showSelectBtn = NO;
    _showSelectedMask = NO;
    _shouldAnialysisAsset = NO;
    _preview = NO;
    _animate = NO;
    _useCustomCamera = NO;
    _photoAlbumAuthorizedChanged = nil;
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

- (NSArray<NSDictionary *> *)clipRatios{
    if (!_clipRatios) {
        _clipRatios = @[GetCustomClipRatio(),
                        GetClipRatio(1, 1),
                        GetClipRatio(4, 3),
                        GetClipRatio(3, 2),
                        GetClipRatio(16, 9)];
    }
    return _clipRatios;
}

#pragma mark - setter

- (void)setMaxEditVideoTime:(NSInteger)maxEditVideoTime{
    _maxEditVideoTime = MAX(maxEditVideoTime, 10);
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


@end


