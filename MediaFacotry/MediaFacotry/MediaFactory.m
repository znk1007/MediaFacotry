//
//  MediaFactory.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaFactory.h"
#import "MediaPhotoActionSheet.h"
#import "MediaPhotoManager.h"

@interface MediaFactory ()

/**
 相册
 */
@property (nonatomic, strong) MediaPhotoActionSheet * _Nullable photo;
@end

@implementation MediaFactory
/**
 MediaFactory单例
 
 @return MediaFactory
 */
+ (MediaFactory *)sharedFactory{
    static MediaFactory *factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[self alloc] init];
    });
    return factory;
}

- (instancetype)init{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (MediaPhotoActionSheet *)photo{
    if (!_photo) {
        _photo = [[MediaPhotoActionSheet alloc] init];
    }
    return _photo;
}

#pragma mark - 相册模块

#pragma mark - public method

/**
 显示相册
 
 @param target 容器控制器
 @param preview 是否预览
 @param animate 动画
 @param imageOnly 只选图片
 @param limitCount 选择图片限制
 @param pickOnly 仅仅选择图片，如为YES，当limitCount=1时，editImmedately无效
 @param editImmedately 选择后立即编辑，仅当limitCount=1时
 @param useCustomCamera 自定义相机
 @param uploadImmediately 立即上传
 @param completion 完成block
 */
- (void)showLibraryWithTargetViewController:(UIViewController * _Nonnull)target needPreview:(BOOL)preview animate:(BOOL)animate showImageOnly:(BOOL)imageOnly limitCount:(NSInteger)limitCount editImmedately:(BOOL)editImmedately useCustomCamera:(BOOL)useCustomCamera pickOnly:(BOOL)pickOnly uploadImmediately:(BOOL)uploadImmediately mediaPickCompletion:(void(^_Nullable)(NSArray<UIImage *> * _Nullable image, NSArray<NSString *> * _Nullable filePaths, NSArray <NSString *> * _Nullable mediaLength, MediaPickProgressCompletion _Nullable progress))completion{
    self.photo.sender = target;
    MediaPhotoConfiguration *configuration = [MediaPhotoConfiguration customPhotoConfiguration];
    configuration.maxSelectCount = limitCount;
    configuration.pickOnly = pickOnly;
    if (pickOnly) {
        configuration.editAfterSelectThumbnailImage = NO;
        configuration.allowEditImage = NO;
        configuration.allowEditVideo = NO;
    } else {
        configuration.editAfterSelectThumbnailImage = uploadImmediately;
        configuration.allowEditImage = uploadImmediately;
        configuration.allowEditVideo = uploadImmediately;
    }
    
    configuration.useSystemCamera = !useCustomCamera;
    configuration.clipImageSize = CLIP_SQAURE;
    if (imageOnly) {
        configuration.allowSelectImage = YES;
        configuration.allowSelectVideo = NO;
        configuration.allowSelectGif = NO;
        configuration.allowSelectLivePhoto = NO;
    }
    self.photo.configuration = configuration;
    if (preview) {
        [self.photo showPreviewAnimated:YES];
    } else {
        [self.photo showPhotoLibrary];
    }
    if (completion) {
        self.photo.selectImageBlock = ^(NSArray<UIImage *> * _Nullable images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal, MediaPickProgressCompletion  _Nullable progress) {
            NSUInteger limitIndex = MIN(images.count, assets.count);
            NSMutableArray <UIImage *> *imgs = [NSMutableArray arrayWithCapacity:limitIndex];
            NSMutableArray <NSString *> *paths = [NSMutableArray arrayWithCapacity:limitIndex];
            NSMutableArray <NSString *> *lengths = [NSMutableArray arrayWithCapacity:limitIndex];
            for (NSUInteger i = 0; i < limitIndex; i++) {
                UIImage *image = images[i];
                PHAsset *asset = assets[i];
                [MediaPhotoManager requestVideoAssetForAsset:asset completion:^(AVAsset * _Nullable avAsset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    [imgs addObject:image];
                    if (avAsset) {
                        [paths addObject:[[(AVURLAsset *)avAsset URL] absoluteString]];
                        [lengths addObject:[NSString stringWithFormat:@"%ld",(long)asset.duration]];
                    }
                }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(imgs, paths, lengths, progress);
            });
        };
    }
}

@end
