//
//  MediaPhotoModel.h
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, MediaAssetMediaType) {
    MediaAssetMediaTypeUnknown,
    MediaAssetMediaTypeImage,
    MediaAssetMediaTypeGif,
    MediaAssetMediaTypeLivePhoto,
    MediaAssetMediaTypeVideo,
    MediaAssetMediaTypeAudio,
    MediaAssetMediaTypeNetImage,
};

@interface MediaPhotoModel : NSObject

//asset对象
@property (nonatomic, strong) PHAsset *asset;
//asset类型
@property (nonatomic, assign) MediaAssetMediaType type;
//视频时长
@property (nonatomic, copy) NSString *duration;
//是否被选择
@property (nonatomic, assign, getter=isSelected) BOOL selected;

//网络/本地 图片url
@property (nonatomic, strong) NSURL *url ;
//图片
@property (nonatomic, strong) UIImage *image;

/**初始化model对象*/
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(MediaAssetMediaType)type duration:(NSString *)duration;

@end

@interface MediaAlbumListModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) BOOL isCameraRoll;
@property (nonatomic, strong) PHFetchResult *result;
//相册第一张图asset对象
@property (nonatomic, strong) PHAsset *headImageAsset;

@property (nonatomic, strong) NSArray<MediaPhotoModel *> *models;
@property (nonatomic, strong) NSArray *selectedModels;
//待用
@property (nonatomic, assign) NSUInteger selectedCount;

@end
