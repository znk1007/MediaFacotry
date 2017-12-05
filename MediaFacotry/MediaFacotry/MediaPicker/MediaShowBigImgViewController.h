//
//  MediaShowBigImgViewController.h
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class MediaPhotoModel;

@interface MediaShowBigImgViewController : UIViewController

@property (nonatomic, strong) NSArray<MediaPhotoModel *> * _Nullable models;

@property (nonatomic, assign) NSInteger selectIndex; //选中的图片下标

@property (nonatomic, copy) void (^ _Nullable btnBackBlock)(NSArray<MediaPhotoModel *> * _Nullable selectedModels, BOOL isOriginal);


//点击选择后的图片预览数组，预览相册图片时为 UIImage，预览网络图片时候为UIImage/NSUrl
@property (nonatomic, strong) NSMutableArray * _Nullable arrSelPhotos;

/**预览 网络/本地 图片时候是否 隐藏底部工具栏和导航右上角按钮*/
@property (nonatomic, assign) BOOL hideToolBar;

//预览相册图片回调
@property (nonatomic, copy) void (^ _Nullable previewSelectedImageBlock)(NSArray<UIImage *> * _Nullable arrP, NSArray<PHAsset *> * _Nullable arrA, MediaPickProgressCompletion _Nullable progress);

//预览网络图片回调
@property (nonatomic, copy) void (^ _Nullable previewNetImageBlock)(NSArray * _Nullable photos, MediaPickProgressCompletion _Nullable progress);

//预览 相册/网络 图片时候，点击返回回调
@property (nonatomic, copy) void (^ _Nullable cancelPreviewBlock)(void);

@end
