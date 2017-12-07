//
//  MediaPhotoManager.h
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "MediaPhotoModel.h"
#import "MediaDefine.h"

@class MediaAlbumListModel;

@interface MediaPhotoManager : NSObject

/**
 * @brief 设置排序模式
 */
+ (void)setSortAscending:(BOOL)ascending;


/**
 * @brief 保存图片到系统相册
 */
+ (void)saveImageToAblum:(UIImage *_Nullable)image completion:(void (^_Nullable)(BOOL suc, PHAsset * _Nullable asset))completion;

/**
 * @brief 保存视频到系统相册
 */
+ (void)saveVideoToAblum:(NSURL *_Nullable)url completion:(void (^_Nullable)(BOOL suc, PHAsset * _Nullable asset))completion;

/**
 * @brief 在全部照片中获取指定个数、排序方式的部分照片，在跳往预览大图界面时候video和gif均为no，不受参数影响
 */
+ (NSArray<MediaPhotoModel *> *_Nullable)getAllAssetInPhotoAlbumWithAscending:(BOOL)ascending limitCount:(NSInteger)limit allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;


/**
 * @brief 获取相机胶卷相册列表对象
 */
+ (MediaAlbumListModel *_Nullable)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage;


/**
 block 获取相机胶卷相册列表对象
 */
+ (void)getCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage completion:(void (^_Nullable)(MediaAlbumListModel * _Nullable album))completion;

/**
 * @brief 获取用户所有相册列表
 */
+ (void)getPhotoAblumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage completion:(void (^_Nullable)(NSArray<MediaAlbumListModel *> *_Nullable))completion;

/**
 * @brief 将result中对象转换成MediaPhotoModel
 */
+ (NSArray<MediaPhotoModel *> *_Nullable)getPhotoInResult:(PHFetchResult<PHAsset *> *_Nullable)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;

/**
 * @brief 获取选中的图片
 */
+ (void)requestSelectedImageForAsset:(MediaPhotoModel *_Nullable)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^_Nullable)(UIImage * _Nullable image, NSDictionary * _Nullable info))completion;


/**
 获取原图data，转换gif图
 */
+ (void)requestOriginalImageDataForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(NSData * _Nullable data, NSDictionary * _Nullable info))completion;

/**
 * @brief 获取原图
 */
+ (void)requestOriginalImageForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(UIImage * _Nullable image, NSDictionary * _Nullable info))completion;

/**
 * @brief 根据传入size获取图片
 */
+ (PHImageRequestID)requestImageForAsset:(PHAsset *_Nullable)asset size:(CGSize)size completion:(void (^_Nullable)(UIImage * _Nullable image, NSDictionary * _Nullable info))completion;


/**
 * @brief 获取live photo
 */
+ (void)requestLivePhotoForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info))completion NS_AVAILABLE_IOS(9_1);

/**
 * @brief 获取视频
 */
+ (void)requestVideoForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(AVPlayerItem * _Nullable item, NSDictionary * _Nullable info))completion;

/**
 获取视频asset

 @param asset PHAsset
 @param completion 完成block
 */
+ (void)requestVideoAssetForAsset:(PHAsset *_Nullable)asset completion:(void(^_Nullable)(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info))completion;

#pragma mark - 逐个解析asset方法
/**
 自行解析图片方法
 
 使用顺序单个解析，缓解了框架同时解析大量图片造成的内存暴涨
 如果一下选择20张及以上照片(原图)建议使用自行解析
 
 请求到图片后做了一个大小的压缩（原图时并未压缩尺寸）来缓解内存的占用
 */
+ (void)anialysisAssets:(NSArray<PHAsset *> *_Nullable)assets original:(BOOL)original completion:(void (^_Nullable)(NSArray<UIImage *> * _Nullable images))completion;

/**
 @brief 缩放图片
 */
+ (UIImage *_Nullable)scaleImage:(UIImage *_Nullable)image original:(BOOL)original;

/**
 * @brief 将系统mediatype转换为自定义mediatype
 */
+ (MediaAssetMediaType)transformAssetType:(PHAsset *_Nullable)asset;

/**
 * @brief 转换视频时长
 */
+ (NSString *_Nullable)getDuration:(PHAsset *_Nullable)asset;

/**
 * @brief 判断图片是否存储在本地/或者已经从iCloud上下载到本地
 */
+ (BOOL)judgeAssetisInLocalAblum:(PHAsset *_Nullable)asset;

/**
 * @brief 获取图片字节大小
 */
+ (void)getPhotosBytesWithArray:(NSArray<MediaPhotoModel *> *_Nullable)photos completion:(void (^_Nullable)(NSString * _Nullable photosBytes))completion;

/**
 * @brief 标记源数组中已被选择的model
 */
+ (void)markSelcectModelInArr:(NSArray<MediaPhotoModel *> *_Nullable)dataArr selArr:(NSArray<MediaPhotoModel *> *_Nullable)selArr;

/**
 * @brief 将image data转换为gif图片，sdwebimage
 */
+ (UIImage *_Nullable)transformToGifImageWithData:(NSData *_Nullable)data;

#pragma mark - 编辑视频相关

/**
 解析视频，获取每秒对应的一帧图片

 @param size 图片size
 */
+ (void)analysisEverySecondsImageForAsset:(PHAsset *_Nullable)asset interval:(NSTimeInterval)interval size:(CGSize)size completion:(void (^_Nullable)(AVAsset * _Nullable avAsset, NSArray<UIImage *> * _Nullable images))completion;

/**
 导出视频并保存到相册
 
 @param range 需要到处的视频间隔
 */
+ (void)exportEditVideoForAsset:(AVAsset *_Nullable)asset range:(CMTimeRange)range type:(MediaExportVideoType)type completion:(void (^_Nullable)(BOOL isSuc, PHAsset * _Nullable asset, NSURL * _Nullable fileUrl, UIImage * _Nullable image))completion;

/**
 获取second秒的帧图片

 @param videoUrl 视频URL地址
 @param second 第几秒
 @return UIImage
 */
+ (UIImage *_Nullable)getThumbImageWithVideoURL:(NSURL *_Nullable)videoUrl second:(int64_t)second;

#pragma mark - 相册、相机、麦克风权限相关
/**
 是否有相册访问权限
 */
+ (BOOL)havePhotoLibraryAuthority;

/**
 是否有相机访问权限
 */
+ (BOOL)haveCameraAuthority;

/**
 是否有麦克风访问权限
 */
+ (BOOL)haveMicrophoneAuthority;

@end
