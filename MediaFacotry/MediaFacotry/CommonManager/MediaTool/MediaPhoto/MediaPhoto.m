//
//  MediaPhoto.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/29.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPhoto.h"

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
//            list = [self fetchAlbumModeWithTitle:<#(NSString *)#> result:<#(PHFetchResult<PHAsset *> *)#> allowSelectVideo:<#(BOOL)#> allowSelectImage:<#(BOOL)#>]
        }
    }];
    return nil;
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


#pragma mark - private method

- (NSString *)transformCollectionTitleWithCollection:(PHAssetCollection *)collection{
    if (collection.assetCollectionType == PHAssetCollectionTypeAlbum) {
        return collection.localizedTitle;
    }
    return nil;
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
