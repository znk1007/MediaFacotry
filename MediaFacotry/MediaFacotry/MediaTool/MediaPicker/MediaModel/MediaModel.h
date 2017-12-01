//
//  MediaModel.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnumHeader.h"

@import Photos;



@interface MediaModel : NSObject
/**
 媒体类型
 */
@property (nonatomic, assign) MediaAssetType assetType;
/**
 asset对象
 */
@property (nonatomic, strong) PHAsset *phAsset;

/**
 媒体视频时长
 */
@property (nonatomic, copy) NSString *duration;

/**
 是否被选中
 */
@property (nonatomic, assign, getter=isSelected) BOOL selected;

/**
 图片URL地址
 */
@property (nonatomic, strong) NSURL *imageUrl;

/**
 图片
 */
@property (nonatomic, strong) UIImage *image;

/**
 初始化model

 @param phAsset 媒体资源
 @param type 媒体类型
 @param duration 时长
 @return model
 */
+ (instancetype)initModelWithPHAsset:(PHAsset *)phAsset mediaType:(MediaAssetType)type mediaDuration:(NSString *)duration;

@end

@interface MediaListModel : NSObject

/**
 标题
 */
@property (nonatomic, copy) NSString *title;

/**
 总数
 */
@property (nonatomic, assign) NSInteger count;

/**
 相机是否在运行
 */
@property (nonatomic, assign) BOOL isCameraRoll;

/**
 获取结果
 */
@property (nonatomic, strong) PHFetchResult *result;

/**
 相册第一张图asset对象
 */
@property (nonatomic, strong) PHAsset *headImageAsset;

/**
 Media model 数组
 */
@property (nonatomic, strong) NSArray<MediaModel *> *models;

/**
 已选Media model
 */
@property (nonatomic, strong) NSArray *selectedModels;

/**
 已选数目
 */
@property (nonatomic, assign) NSUInteger selectedCount;
@end
