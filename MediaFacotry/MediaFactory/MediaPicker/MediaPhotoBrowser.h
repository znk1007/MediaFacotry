//
//  MediaPhotoBrowser.h
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaDefine.h"
#import "MediaPhotoConfiguration.h"

@class MediaPhotoModel;

@interface MediaImageNavigationController : UINavigationController

@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;

/**
 是否选择了原图
 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

@property (nonatomic, copy) NSMutableArray<MediaPhotoModel *> * _Nullable arrSelectedModels;

/**
 相册框架配置
 */
@property (nonatomic, strong) MediaPhotoConfiguration * _Nonnull configuration;

/**
 点击确定选择照片回调
 */
@property (nonatomic, copy) void (^ _Nullable callSelectImageBlock)(MediaPickProgressCompletion _Nullable progress);

/**
 编辑图片后回调
 */
@property (nonatomic, copy) void (^ _Nullable callSelectClipImageBlock)(UIImage * _Nullable image, PHAsset * _Nullable phAsset, MediaPickProgressCompletion _Nullable progress);

/**
 取消block
 */
@property (nonatomic, copy) void (^ _Nullable cancelBlock)(void);

@end



@interface MediaPhotoBrowser : UITableViewController

@end
