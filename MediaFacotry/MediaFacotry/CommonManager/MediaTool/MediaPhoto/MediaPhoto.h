//
//  MediaPhoto.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/29.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaModel.h"

@interface MediaPhoto : NSObject
/**
 保存到指定的相册名, 默认CFBundleName
 */
@property (nonatomic, copy) NSString * _Nullable albumName;

/**
 相册资源排序
 */
@property (nonatomic, assign) BOOL sortAscending;
/**
 保存图片到系统相册一
 
 @param image 图片
 @param completion 完成回调
 */
- (void)saveToAlbumWithImage:(UIImage *_Nullable)image completion:(void(^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion;

/**
 保存图片到系统相册二

 @param url 资源路径
 @param completion 完成回调
 */
- (void)saveToAlbumWithImageURL:(NSURL *_Nullable)url completion:(void (^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion;

/**
 保存视频到系统相册

 @param url 资源路径
 @param completion 完成回调
 */
- (void)saveToAlbumWithVideoURL:(NSURL *_Nullable)url completion:(void (^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion;

/**
 根据指定参数配置获取系统相册资源

 @param ascending 排序
 @param limitCount 最大限制
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @param allowSelectGIF 可选GIF
 @param allowSelectLivePhoto 可选LivePhoto
 @return 相册资源
 */
- (NSArray <MediaModel *> *_Nullable)fetchAllAssetFormAlbumWithAscending:(BOOL)ascending limitCount:(NSInteger)limitCount allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGIF:(BOOL)allowSelectGIF allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;

/**
 获取相机胶卷相册列表对象

 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @return MediaListModel
 */
- (MediaListModel *_Nullable)fetchCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage;

/**
 获取相机胶卷相册列表对象

 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @param completion 完成回调
 */
- (void)fetchCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage completion:(void (^_Nullable)(MediaListModel * _Nullable album))completion;

/**
 获取用户所有相册列表
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选视频
 @param completion 完成回调
 */
- (void)fetchPhotoAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage completion:(void (^_Nullable)(NSArray<MediaListModel *> *_Nullable))completion;

/**
 将result中对象转换成MediaModel

 @param result PHFetchResult<PHAsset *> *
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @param allowSelectGif 可选GIF
 @param allowSelectLivePhoto 可选LivePhoto
 @return NSArray<MediaModel *> *
 */
- (NSArray<MediaModel *> *_Nullable)fetchPhotoWithFetchResult:(PHFetchResult<PHAsset *> *_Nonnull)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;

/**
 获取当前图片

 @param model MediaModel
 @param isOriginal 是否原图
 @param allowSelectGif 可选GIF
 @param completion 完成回调
 */
- (void)requestImageForAsset:(MediaModel *_Nullable)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^_Nullable)(UIImage * _Nullable image, NSDictionary * _Nullable info))completion;

/**
 获取原图数据

 @param asset PHAsset
 @param completion 完成回调
 */
- (void)requestOriginalImageDataForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(NSData * _Nullable data, NSDictionary * _Nullable info))completion;

/**
 获取原图

 @param asset PHAsset
 @param completion 完成回调
 */
- (void)requestOriginalImageForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(UIImage * _Nullable data, NSDictionary * _Nullable info))completion;

/**
 获取指定大小的图片

 @param asset PHAsset
 @param size CGSize
 @param completion 完成回调
 @return PHImageRequestID
 */
-  (PHImageRequestID)requestImageForAsset:(PHAsset *_Nullable)asset size:(CGSize)size completion:(void (^_Nullable)(UIImage * _Nullable image, NSDictionary * _Nullable info))completion;

/**
 获取livePhoto

 @param asset PHAsset
 @param completion 完成回调
 */
-  (void)requestLivePhotoForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info))completion PHOTOS_AVAILABLE_IOS_TVOS(9_1, 10_0);

/**
 获取视频

 @param asset PHAsset
 @param completion 完成回调
 */
- (void)requestVideoForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(AVPlayerItem * _Nullable item, NSDictionary * _Nullable info))completion;

 /**
  解析图片，使用顺序单个解析，缓解了框架同时解析大量图片造成的内存暴涨
  如果一下选择20张及以上照片(原图)建议使用自行解析

  @param assets NSArray<PHAsset *> *
  @param original 是否原图
  @param completion 完成回调
  */
- (void)anialysisAssets:(NSArray<PHAsset *> *_Nullable)assets original:(BOOL)original completion:(void (^_Nullable)(NSArray<UIImage *> * _Nullable images))completion;

/**
 缩放图片

 @param image 图片
 @param original 是否原图
 @return UIImage
 */
-  (UIImage *_Nullable)scaleImage:(UIImage *_Nullable)image original:(BOOL)original;

/**
 枚举转换
 
 @param asset PHAsset
 @return MediaAssetType
 */
- (MediaAssetType)transformAssetType:(PHAsset *_Nullable)asset;

/**
 获取视频时长
 
 @param asset PHAsset
 @return 视频时长
 */
- (NSString *_Nullable)getDuration:(PHAsset *_Nullable)asset;

/**
 判断图片是否存储在本地/或者已经从iCloud上下载到本地

 @param asset PHAsset
 @return BOOL
 */
-  (BOOL)judgeAssetisInLocalAblum:(PHAsset *_Nullable)asset;

/**
 获取图片字节大小

 @param photos NSArray<MediaModel *> *
 @param completion 完成回调
 */
-  (void)fetchPhotosBytesWithArray:(NSArray<MediaModel *> *_Nullable)photos completion:(void (^_Nullable)(NSString * _Nullable photosBytes))completion;

/**
 标记已选model

 @param originalArray NSArray<MediaModel *> *
 @param selectedArray NSArray<MediaModel *> *
 */
-  (void)markSelcectedModelInArrary:(NSArray<MediaModel *> *_Nullable)originalArray selectedArray:(NSArray<MediaModel *> *_Nullable)selectedArray;

/**
  解析视频，获取每秒对应的一帧图片

 @param asset PHAsset
 @param interval 时长
 @param size CGSize
 @param completion 完成回调
 */
-  (void)fetchFrameImageForAsset:(PHAsset *_Nullable)asset interval:(NSTimeInterval)interval size:(CGSize)size completion:(void (^_Nullable)(AVAsset * _Nullable avAsset, NSArray<UIImage *> * _Nullable images))completion;

/**
 导出视频并保存到相册

 @param asset AVAsset
 @param range CMTimeRange
 @param type MediaVideoExportType
 @param completion 完成回调
 */
-  (void)exportEditedVideoForAsset:(AVAsset *_Nullable)asset range:(CMTimeRange)range type:(MediaVideoExportType)type completion:(void (^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion;

/**
 访问相册权限

 @return BOOL
 */
-  (BOOL)havePhotoLibraryAuthority;

/**
 访问相机权限

 @return BOOL
 */
-  (BOOL)haveCameraAuthority;

/**
 访问麦克风权限

 @return BOOL
 */
- (BOOL)haveMicrophoneAuthority;

@end
