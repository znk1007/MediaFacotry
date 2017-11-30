//
//  MediaPhoto.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/29.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPhoto.h"
#import "MediaGIFImageView.h"

static NSString * const mediaPhotoCreationDateKey = @"creationDate";
static NSString * const mediaPhotoMediaTypeKey = @"mediaType";
static NSString * const mediaPhotoAssetFileNameKey = @"filename";
static NSString * const mediaPhotoAssetGIFKey = @"GIF";

@implementation MediaPhoto

#pragma mark - getter
- (NSString *)albumName{
    if (!_albumName || [_albumName isEqualToString:@""]) {
        _albumName = [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey];
    }
    return _albumName;
}

#pragma mark - 处理相册
/**
 保存图片到系统相册
 
 @param image 图片
 @param completion 完成回调
 */
- (void)saveToAlbumWithImage:(UIImage *_Nullable)image completion:(void(^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        if (completion) {
            completion(NO, nil);
        }
    } else {
        __block PHObjectPlaceholder *placeholderAsset = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            placeholderAsset = changeRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) {
                    completion(NO, nil);
                }
                return ;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *targetCollection = [self customAssetCollection];
            if (!targetCollection) {
                if (completion) {
                    completion(NO, nil);
                }
            }
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:targetCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) {
                    completion(success, asset);
                }
            }];
        }];
    }
}

/**
 保存图片到系统相册二
 
 @param url 资源路径
 @param completion 完成回调
 */
- (void)saveToAblumWithImageURL:(NSURL *_Nullable)url completion:(void (^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        if (completion) {
            completion(NO, nil);
        }
    } else {
        __block PHObjectPlaceholder *placeholderAsset = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
            placeholderAsset = changeRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) {
                    completion(NO, nil);
                }
                return ;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *targetCollection = [self customAssetCollection];
            if (!targetCollection) {
                if (completion) {
                    completion(NO, nil);
                }
            }
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:targetCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) {
                    completion(success, asset);
                }
            }];
        }];
    }
}

/**
 保存视频到系统相册
 
 @param url 资源路径
 @param completion 完成回调
 */
- (void)saveToAblumWithVideoURL:(NSURL *_Nullable)url completion:(void (^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
        if (completion) {
            completion(NO, nil);
        }
    } else {
        __block PHObjectPlaceholder *placeholderAsset = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *changeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
            placeholderAsset = changeRequest.placeholderForCreatedAsset;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                if (completion) {
                    completion(NO, nil);
                }
                return ;
            }
            PHAsset *asset = [self getAssetFromlocalIdentifier:placeholderAsset.localIdentifier];
            PHAssetCollection *targetCollection = [self customAssetCollection];
            if (!targetCollection) {
                if (completion) {
                    completion(NO, nil);
                }
            }
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:targetCollection] addAssets:@[asset]];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) {
                    completion(success, asset);
                }
            }];
        }];
    }
}

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
- (NSArray <MediaModel *> *_Nullable)fetchAllAssetFormAlbumWithAscending:(BOOL)ascending limitCount:(NSInteger)limitCount allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGIF:(BOOL)allowSelectGIF allowSelectLivePhoto:(BOOL)allowSelectLivePhoto{
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (!ascending) {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:mediaPhotoCreationDateKey ascending:ascending]];
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithOptions:options];
    return [self fetchPhotoWithFetchResult:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage allowSelectGif:allowSelectGIF allowSelectLivePhoto:allowSelectLivePhoto limitCount:limitCount];
}

/**
 获取相机胶卷相册列表对象
 
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @return MediaListModel
 */
- (MediaListModel *_Nullable)fetchCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (!allowSelectVideo) {
        options.predicate = [NSPredicate predicateWithFormat:@"%@ == %ld", mediaPhotoMediaTypeKey,PHAssetMediaTypeImage];
    }
    if (!allowSelectImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"%@ == %ld", mediaPhotoMediaTypeKey,PHAssetMediaTypeVideo];
    }
    if (!self.sortAscending) {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:mediaPhotoCreationDateKey ascending:self.sortAscending]];
    }
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    __block MediaListModel *list = nil;
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        //获取相册内asset result
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
            PHFetchResult <PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            list = [self fetchAlbumModeWithTitle:[self transformCollectionTitleWithCollection:collection] result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage];
            list.isCameraRoll = YES;
        }
    }];
    return list;
}

/**
 获取相机胶卷相册列表对象
 
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @param completion 完成回调
 */
- (void)fetchCameraRollAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage completion:(void (^_Nullable)(MediaListModel * _Nullable album))completion{
    if (completion) {
        completion([self fetchCameraRollAlbumList:allowSelectVideo allowSelectImage:allowSelectImage]);
    }
}

/**
 获取用户所有相册列表
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选视频
 @param completion 完成回调
 */
- (void)fetchPhotoAlbumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage completion:(void (^_Nullable)(NSArray<MediaListModel *> *_Nullable))completion{
    if (!allowSelectImage && !allowSelectVideo) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    if (!allowSelectVideo) {
        options.predicate = [NSPredicate predicateWithFormat:@"%@ == %ld", mediaPhotoMediaTypeKey, PHAssetMediaTypeImage];
    }
    if (!allowSelectImage) {
        options.predicate = [NSPredicate predicateWithFormat:@"%@ == %ld", mediaPhotoMediaTypeKey, PHAssetMediaTypeVideo];
    }
    if (!self.sortAscending) {
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:mediaPhotoCreationDateKey ascending:self.sortAscending]];
    }
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *streamAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *arrAllAlbums = @[smartAlbums, streamAlbums, userAlbums, syncedAlbums, sharedAlbums];
    NSMutableArray<MediaListModel *> *arrAlbum = [NSMutableArray array];
    for (PHFetchResult<PHAssetCollection *> *album in arrAllAlbums) {
        [album enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
            //过滤PHCollectionList对象
            if (![collection isKindOfClass:PHAssetCollection.class]) return;
            //过滤最近删除
            if (collection.assetCollectionSubtype > 215) return;
            //获取相册内asset result
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            if (!result.count) return;
            
            NSString *title = [self transformCollectionTitleWithCollection:collection];
            
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                MediaListModel *list = [self fetchAlbumModeWithTitle:title result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage];
                list.isCameraRoll = YES;
                [arrAlbum insertObject:list atIndex:0];
            } else {
                [arrAlbum addObject:[self fetchAlbumModeWithTitle:title result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage]];
            }
        }];
    }
    if (completion) {
        completion(arrAlbum);
    }
}

/**
 将result中对象转换成MediaModel
 
 @param result PHFetchResult<PHAsset *> *
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @param allowSelectGif 可选GIF
 @param allowSelectLivePhoto 可选LivePhoto
 @return NSArray<MediaModel *> *
 */
- (NSArray<MediaModel *> *_Nullable)fetchPhotoWithFetchResult:(PHFetchResult<PHAsset *> *_Nonnull)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto{
    return [self fetchPhotoWithFetchResult:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage allowSelectGif:allowSelectGif allowSelectLivePhoto:allowSelectLivePhoto limitCount:NSIntegerMax];
}

/**
 获取当前图片
 
 @param model MediaModel
 @param isOriginal 是否原图
 @param allowSelectGif 可选GIF
 @param completion 完成回调
 */
- (void)requestImageForAsset:(MediaModel *_Nullable)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^_Nullable)(UIImage * _Nullable image, NSDictionary * _Nullable info))completion{
    if (model.assetType == MediaAssetTypeGif && allowSelectGif) {
        [self requestOriginalImageDataWithAsset:model.phAsset completion:^(NSData *data, NSDictionary *info) {
            if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                UIImage *image = [MediaGIFImage imageWithData:data];
                if (completion) {
                    completion(image, info);
                }
            }
        }];
    }else{
//        if (<#condition#>) {
//            <#statements#>
//        }
    }
}

/**
 获取原图数据
 
 @param asset PHAsset
 @param completion 完成回调
 */
- (void)requestOriginalImageDataForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(NSData * _Nullable data, NSDictionary * _Nullable info))completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc]init];
    option.networkAccessAllowed = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinined && imageData) {
            if (completion) {
                completion(imageData, info);
            }
        }
    }];
}

/**
 获取原图
 
 @param asset PHAsset
 @param completion 完成回调
 */
- (void)requestOriginalImageForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(UIImage * _Nullable data, NSDictionary * _Nullable info))completion{
    [self requestImageForAsset:asset size:CGSizeMake(asset.pixelWidth, asset.pixelHeight) resizeMode:PHImageRequestOptionsResizeModeNone completion:completion];
}

/**
 获取指定大小的图片
 
 @param asset PHAsset
 @param size CGSize
 @param completion 完成回调
 @return PHImageRequestID
 */
-  (PHImageRequestID)requestImageForAsset:(PHAsset *_Nullable)asset size:(CGSize)size completion:(void (^_Nullable)(UIImage * _Nullable image, NSDictionary * _Nullable info))completion{
    return [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
}

/**
 获取livePhoto
 
 @param asset PHAsset
 @param completion 完成回调
 */
-  (void)requestLivePhotoForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info))completion PHOTOS_AVAILABLE_IOS_TVOS(9_1, 10_0){
    PHLivePhotoRequestOptions *option = [[PHLivePhotoRequestOptions alloc] init];
    option.version = PHImageRequestOptionsVersionCurrent;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    option.networkAccessAllowed = YES;
    
    [[PHCachingImageManager defaultManager] requestLivePhotoForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:option resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
        if (completion) {
            completion(livePhoto, info);
        }
    }];
}

/**
 获取视频
 
 @param asset PHAsset
 @param completion 完成回调
 */
- (void)requestVideoForAsset:(PHAsset *_Nullable)asset completion:(void (^_Nullable)(AVPlayerItem * _Nullable item, NSDictionary * _Nullable info))completion{
    [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:asset options:nil resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) {
            completion(playerItem, info);
        }
    }];
}

/**
 解析图片，使用顺序单个解析，缓解了框架同时解析大量图片造成的内存暴涨
 如果一下选择20张及以上照片(原图)建议使用自行解析
 
 @param assets NSArray<PHAsset *> *
 @param original 是否原图
 @param completion 完成回调
 */
- (void)anialysisAssets:(NSArray<PHAsset *> *_Nullable)assets original:(BOOL)original completion:(void (^_Nullable)(NSArray<UIImage *> * _Nullable images))completion{
    NSMutableArray *arr = [NSMutableArray array];
    
    dispatch_queue_t queue = dispatch_queue_create(nil, 0);
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(1);
    
    for (NSUInteger i = 0, j = assets.count; i < j; i++) {
        PHAsset *asset = assets[i];
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            __weak typeof(self) weakSelf = self;
            if (original) {
                [self requestOriginalImageForAsset:asset completion:^(UIImage *image, NSDictionary *info) {
                    if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
                    dispatch_semaphore_signal(sem);
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [arr addObject:[strongSelf scaleImage:image original:original]];
                    if (i == assets.count-1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) completion(arr);
                        });
                    }
                }];
            } else {
                CGFloat scale = 2;
                CGFloat width = MIN(kMediaScreenWidth, kMaxImageWidth);
                CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
                [self requestImageForAsset:asset size:size completion:^(UIImage *image, NSDictionary *info) {
                    if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
                    dispatch_semaphore_signal(sem);
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    [arr addObject:[strongSelf scaleImage:image original:original]];
                    if (i == assets.count-1) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (completion) {
                                completion(arr);
                            }
                        });
                    }
                }];
            }
        });
    }
}

/**
 缩放图片
 
 @param image 图片
 @param original 是否原图
 @return UIImage
 */
-  (UIImage *_Nullable)scaleImage:(UIImage *_Nullable)image original:(BOOL)original{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    if (data.length < 0.2*(1024*1024)) {
        //小于200k不缩放
        return image;
    }
    double scale = original ? (data.length > (1024*1024) ? .7 : .9) : (data.length > (1024*1024) ? .5 : .7);
    NSData *d = UIImageJPEGRepresentation(image, scale);
    return [UIImage imageWithData:d];
}

/**
 获取视频时长
 
 @param asset PHAsset
 @return 视频时长
 */
- (NSString *)getDuraton:(PHAsset *)asset{
    if (asset.mediaType != PHAssetMediaTypeVideo) {
        return nil;
    }
    NSInteger duration = (NSInteger)round(asset.duration);
    if (duration < 60) {
        return [NSString stringWithFormat:@"00:%02ld",duration];
    } else if (duration < 3600) {
        NSInteger m = duration / 60;
        NSInteger s = duration % 60;
        return [NSString stringWithFormat:@"%02ld:%02ld", m, s];
    } else {
        NSInteger h = duration / 3600;
        NSInteger m = (duration % 3600) / 60;
        NSInteger s = duration % 60;
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", h, m, s];
    }
}

/**
 判断图片是否存储在本地/或者已经从iCloud上下载到本地
 
 @param asset PHAsset
 @return BOOL
 */
-  (BOOL)judgeAssetisInLocalAblum:(PHAsset *_Nullable)asset{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.networkAccessAllowed = NO;
    option.synchronous = YES;
    __block BOOL isInLocalAblum = YES;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isInLocalAblum = imageData ? YES : NO;
    }];
    return isInLocalAblum;
}

/**
 获取图片字节大小
 
 @param photos NSArray<MediaModel *> *
 @param completion 完成回调
 */
-  (void)fetchPhotosBytesWithArray:(NSArray<MediaModel *> *_Nullable)photos completion:(void (^_Nullable)(NSString * _Nullable photosBytes))completion{
    __block NSInteger dataLength = 0;
    __block NSInteger count = photos.count;
    __weak typeof(self) weakSelf = self;
    for (int i = 0; i < photos.count; i++) {
        MediaModel *model = photos[i];
        [[PHCachingImageManager defaultManager] requestImageDataForAsset:model.phAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dataLength += imageData.length;
            count--;
            if (count <= 0) {
                if (completion) {
                    completion([strongSelf transformDataLength:dataLength]);
                }
            }
        }];
    }
}

/**
 枚举转换
 
 @param asset PHAsset
 @return MediaAssetType
 */
- (MediaAssetType)transformAssetType:(PHAsset *)asset{
    switch (asset.mediaType) {
        case PHAssetMediaTypeAudio:
        {
            return MediaAssetTypeAudio;
        }
            break;
        case PHAssetMediaTypeVideo:
        {
            return MediaAssetTypeVideo;
        }
            break;
        case PHAssetMediaTypeImage:
        {
            if ([[asset valueForKey:mediaPhotoAssetFileNameKey] hasSuffix:mediaPhotoAssetGIFKey]) {
                return MediaAssetTypeGif;
            }
            return MediaAssetTypeImage;
        }
            break;
            
        default:
        {
            return MediaAssetTypeUnkown;
        }
            break;
    }
}

/**
 标记已选model
 
 @param originalArray NSArray<MediaModel *> *
 @param selectedArray NSArray<MediaModel *> *
 */
-  (void)markSelcectedModelInArrary:(NSArray<MediaModel *> *_Nullable)originalArray selectedArray:(NSArray<MediaModel *> *_Nullable)selectedArray{
    NSMutableArray *selIdentifiers = [NSMutableArray array];
    for (MediaModel *model in selectedArray) {
        [selIdentifiers addObject:model.phAsset.localIdentifier];
    }
    for (MediaModel *model in originalArray) {
        if ([selIdentifiers containsObject:model.phAsset.localIdentifier]) {
            model.selected = YES;
        } else {
            model.selected = NO;
        }
    }
}

/**
 解析视频，获取每秒对应的一帧图片
 
 @param asset PHAsset
 @param interval 时长
 @param size CGSize
 @param completion 完成回调
 */
-  (void)fetchFrameImageForAsset:(PHAsset *_Nullable)asset interval:(NSTimeInterval)interval size:(CGSize)size completion:(void (^_Nullable)(AVAsset * _Nullable avAsset, NSArray<UIImage *> * _Nullable images))completion{
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        [self fetchFrameImageWithAVAsset:asset interval:interval size:size completion:completion];
    }];
}

/**
 导出视频并保存到相册
 
 @param asset AVAsset
 @param range CMTimeRange
 @param type MediaVideoExportType
 @param completion 完成回调
 */
-  (void)exportEditedVideoForAsset:(AVAsset *_Nullable)asset range:(CMTimeRange)range type:(MediaVideoExportType)type completion:(void (^_Nullable)(BOOL success, PHAsset * _Nullable asset))completion{
    NSString *exportFilePath = [self transformVideoExportFilePath:type];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    NSURL *exportFileUrl = [NSURL fileURLWithPath:exportFilePath];
    exportSession.outputURL = exportFileUrl;
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.timeRange = range;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export canceled");
                break;
            case AVAssetExportSessionStatusCompleted:{
                NSLog(@"Export completed");
                [self saveToAblumWithVideoURL:exportFileUrl completion:^(BOOL success, PHAsset * _Nullable asset) {
                    if (success) {
                        NSLog(@"导出的的视频路径: %@", exportFilePath);
                    } else {
                        NSLog(@"导出视频失败");
                    }
                }];
            }
                break;
                
            default:
                NSLog(@"Export other");
                break;
        }
    }];
}

/**
 访问相册权限
 
 @return BOOL
 */
-  (BOOL)havePhotoLibraryAuthority{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}

/**
 访问相机权限
 
 @return BOOL
 */
-  (BOOL)haveCameraAuthority{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

/**
 访问麦克风权限
 
 @return BOOL
 */
- (BOOL)haveMicrophoneAuthority{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

#pragma mark - private method

/**
 视频保存格式

 @param type MediaVideoExportType
 @return 临时路径
 */
- (NSString *)transformVideoExportFilePath:(MediaVideoExportType)type{
    NSTimeInterval interval = [[[NSDate alloc] init] timeIntervalSince1970];
    NSString *format = type == MediaVideoExportTypeMOV ? @"mov" : type == MediaVideoExportTypeMP4 ? @"mp4" : @"3gp";
    NSString *exportFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.%@", interval, format]];
    return exportFilePath;
}

/**
 获取视频每秒第一帧图片

 @param asset AVAsset
 @param interval NSTimeInterval
 @param size CGSize
 @param completion 完成回调
 */
- (void)fetchFrameImageWithAVAsset:(AVAsset *)asset interval:(NSTimeInterval)interval size:(CGSize)size completion:(void (^)(AVAsset *, NSArray<UIImage *> *))completion{
    long duration = round(asset.duration.value) / asset.duration.timescale;
    
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.maximumSize = size;
    generator.appliesPreferredTrackTransform = YES;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    
    //每秒的第一帧
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < duration; i += interval) {
        /*
         CMTimeMake(a,b) a当前第几帧, b每秒钟多少帧
         */
        //这里加上0.35 是为了避免解析0s图片必定失败的问题
        CMTime time = CMTimeMake((i + 0.35) * asset.duration.timescale, asset.duration.timescale);
        NSValue *value = [NSValue valueWithCMTime:time];
        [arr addObject:value];
    }
    NSMutableArray *arrImages = [NSMutableArray array];
    __block long count = 0;
    [generator generateCGImagesAsynchronouslyForTimes:arr completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        switch (result) {
            case AVAssetImageGeneratorSucceeded:
                [arrImages addObject:[UIImage imageWithCGImage:image]];
                break;
            case AVAssetImageGeneratorFailed:
                NSLog(@"第%ld秒图片解析失败", count);
                break;
            case AVAssetImageGeneratorCancelled:
                NSLog(@"取消解析视频图片");
                break;
        }
        count++;
        if (count == arr.count && completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(asset, arrImages);
            });
        }
    }];
}

/**
 长度转换

 @param dataLength 数据大小
 @return 数据大小字符串
 */
-  (NSString *)transformDataLength:(NSInteger)dataLength {
    NSString *bytes = @"";
    if (dataLength >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%.1fM",dataLength/1024/1024.0];
    } else if (dataLength >= 1024) {
        bytes = [NSString stringWithFormat:@"%.0fK",dataLength/1024.0];
    } else {
        bytes = [NSString stringWithFormat:@"%zdB",dataLength];
    }
    return bytes;
}

/**
 获取图片

 @param asset PHAsset
 @param size CGSize
 @param resizeMode PHImageRequestOptionsResizeMode
 @param completion 完成回调
 @return PHImageRequestID
 */
-  (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *, NSDictionary *))completion{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = resizeMode;//控制照片尺寸
    options.networkAccessAllowed = YES;
    return [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}
/**
 获取相册名

 @param collection PHAssetCollection
 @return 相册名
 */
- (NSString *)transformCollectionTitleWithCollection:(PHAssetCollection *)collection{
    if (collection.assetCollectionType == PHAssetCollectionTypeAlbum) {
        return collection.localizedTitle;
    }
    NSString *title = @"";
    switch (collection.assetCollectionSubtype) {
        case PHAssetCollectionSubtypeSmartAlbumUserLibrary:
        {
            title = @"所有照片";
        }
            break;
        case PHAssetCollectionSubtypeSmartAlbumPanoramas:
        {
            title = @"全景照片";
        }
            break;
        case PHAssetCollectionSubtypeSmartAlbumVideos:
        {
            title = @"视频";
        }
            break;
        case PHAssetCollectionSubtypeSmartAlbumFavorites:
        {
            title = @"个人收藏";
        }
            break;
        case PHAssetCollectionSubtypeSmartAlbumTimelapses:
        {
            title = @"延时摄影";
        }
            break;
        case PHAssetCollectionSubtypeSmartAlbumRecentlyAdded:
        {
            title = @"最近添加";
        }
            break;
        case PHAssetCollectionSubtypeSmartAlbumBursts:
        {
            title = @"连拍快照";
        }
            break;
        case PHAssetCollectionSubtypeSmartAlbumSlomoVideos:
        {
            title = @"慢动作";
        }
            break;
        default:
            break;
    }
    if (@available(iOS 10.3, *)) {
        switch (collection.assetCollectionSubtype) {
            case PHAssetCollectionSubtypeSmartAlbumSelfPortraits:
            {
                title = @"自拍";
            }
                break;
            case PHAssetCollectionSubtypeSmartAlbumScreenshots:
            {
                title = @"屏幕快照";
            }
                break;
            case PHAssetCollectionSubtypeSmartAlbumDepthEffect:
            {
                title = @"人像";
            }
                break;
            case PHAssetCollectionSubtypeSmartAlbumLivePhotos:
            {
                title = @"Live Photo";
            }
                break;
                
            default:
                break;
        }
    }
    if (@available(iOS 11, *)) {
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAnimated) {
            title = @"动图";
        }
    }
    return title;
}

/**
 获取相册列表MediaListModel

 @param title 名称
 @param result PHFetchResult <PHAsset *> *
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @return MediaListModel
 */
- (MediaListModel *)fetchAlbumModeWithTitle:(NSString *)title result:(PHFetchResult <PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage{
    MediaListModel *list = [[MediaListModel alloc] init];
    list.title = title;
    list.count = result.count;
    list.result = result;
    if (self.sortAscending) {
        list.headImageAsset = result.lastObject;
    }else{
        list.headImageAsset = result.firstObject;
    }
    list.models = [self fetchPhotoWithFetchResult:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage allowSelectGif:allowSelectImage allowSelectLivePhoto:allowSelectImage];
    return list;
}

/**
 获取相册所有资源

 @param result PHFetchResult<PHAsset *>
 @param allowSelectVideo 可选视频
 @param allowSelectImage 可选图片
 @param allowSelectGif 可选GIF
 @param allowSelectLivePhoto 可选LivePhoto
 @param limit 限制数量
 @return NSArray <MediaModel *> *
 */
- (NSArray <MediaModel *> *)fetchPhotoWithFetchResult:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto limitCount:(NSInteger)limit{
    NSMutableArray<MediaModel *> *arrModel = [NSMutableArray array];
    __block NSInteger count = 1;
    __weak typeof(self) weakSelf = self;
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MediaAssetType type = [self transformAssetType:obj];
        if (type == MediaAssetTypeImage && !allowSelectImage) {
            return ;
        }
        if (type == MediaAssetTypeGif && !allowSelectGif) {
            return ;
        }
        if (type == MediaAssetTypeLivePhoto && !allowSelectLivePhoto) {
            return ;
        }
        if (type == MediaAssetTypeVideo && !allowSelectVideo) {
            return ;
        }
        if (count == limit) {
            *stop = YES;
        }
        NSString *duration = [weakSelf getDuraton:obj];
        [arrModel addObject:[MediaModel initModelWithPHAsset:obj mediaType:type mediaDuration:duration]];
    }];
    return arrModel;
}



- (void)requestOriginalImageDataWithAsset:(PHAsset *)asset completion:(void(^)(NSData *data,NSDictionary *info))completion{
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        BOOL downloadFinished = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
        if (downloadFinished && imageData && completion) {
            completion(imageData, info);
        }
    }];
}

/**
 获取asset资源
 
 @param localIdentifier 唯一标识
 @return PHAsset
 */
- (PHAsset *)getAssetFromlocalIdentifier:(NSString *)localIdentifier{
    if (!localIdentifier || [localIdentifier isEqualToString:@""]) {
        return nil;
    }
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    return result.count > 0 ? result[0] : nil;
}


/**
 获取相册对象
 
 @return PHAssetCollection
 */
- (PHAssetCollection *)customAssetCollection{
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:self.albumName]) {
            return collection;
        }
    }
    __block NSString *collectionId = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:self.albumName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        return nil;
    }
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].lastObject;
}

@end
