//
//  MediaFactory.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaFactory.h"
#import "MediaPhotoActionSheet.h"

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
 @param editImmedately 选择后立即编辑，仅当limitCount=1时
 @param useCustomCamera 自定义相机
 @param uploadImmediately 立即上传
 @param completion 完成block
 */
- (void)showLibraryWithTargetViewController:(UIViewController * _Nonnull)target needPreview:(BOOL)preview animate:(BOOL)animate showImageOnly:(BOOL)imageOnly limitCount:(NSInteger)limitCount editImmedately:(BOOL)editImmedately useCustomCamera:(BOOL)useCustomCamera uploadImmediately:(BOOL)uploadImmediately mediaPickCompletion:(void(^_Nullable)(NSArray<UIImage *> * _Nullable image, NSArray<NSString *> * _Nullable filePaths, int mediaLength, MediaPickProgressCompletion _Nullable progress))completion{
    self.photo.sender = target;
    MediaPhotoConfiguration *configuration = [MediaPhotoConfiguration customPhotoConfiguration];
    configuration.maxSelectCount = limitCount;
    configuration.editAfterSelectThumbnailImage = editImmedately;
    configuration.useSystemCamera = !useCustomCamera;
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
}

@end
