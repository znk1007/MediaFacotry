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
- (void)saveToAblumWithImageURL:(NSURL *_Nullable)url completion:(void (^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion;

/**
 保存视频到系统相册

 @param url 资源路径
 @param completion 完成回调
 */
- (void)saveToAblumWithVideoURL:(NSURL *_Nullable)url completion:(void (^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion;

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
 将result中对象转换成MediaModel

 @param result PHFetchResult<PHAsset *> *
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @param allowSelectGif 可选GIF
 @param allowSelectLivePhoto 可选LivePhoto
 @return NSArray<MediaModel *> *
 */
- (NSArray<MediaModel *> *_Nullable)fetchPhotoWithFetchResult:(PHFetchResult<PHAsset *> *_Nonnull)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;

@end
