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
        [self show];
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
 @param uploadImmediately 是否立即上传
 */
- (void)showLibraryWithTargetViewController:(UIViewController * _Nonnull)target needPreview:(BOOL)preview animate:(BOOL)animate uploadImmediately:(BOOL)uploadImmediately{
    self.photo.sender = target;
    MediaPhotoConfiguration *configuration = [MediaPhotoConfiguration defaultPhotoConfiguration];
    configuration.uploadImmediately = uploadImmediately;
    self.photo.configuration = configuration;
    if (preview) {
        [self.photo showPreviewAnimated:YES];
    } else {
        [self.photo showPhotoLibrary];
    }
}

#pragma mark - Method
- (void)show{
    
}

- (void)hide{
    
}
@end
