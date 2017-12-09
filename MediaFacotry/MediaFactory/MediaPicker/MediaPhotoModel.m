//
//  MediaPhotoModel.m
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPhotoModel.h"
#import "MediaPhotoManager.h"

@implementation MediaPhotoModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(MediaAssetMediaType)type duration:(NSString *)duration
{
    MediaPhotoModel *model = [[MediaPhotoModel alloc] init];
    model.asset = asset;
    model.type = type;
    model.duration = duration;
    model.selected = NO;
    return model;
}

@end

@implementation MediaAlbumListModel


@end
