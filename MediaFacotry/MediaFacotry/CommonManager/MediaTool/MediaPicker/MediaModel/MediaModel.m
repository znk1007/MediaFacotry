//
//  MediaModel.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaModel.h"

@implementation MediaModel
+ (instancetype)initModelWithPHAsset:(PHAsset *)phAsset mediaType:(MediaAssetType)type mediaDuration:(NSString *)duration{
    MediaModel *model = [[MediaModel alloc] init];
    model.phAsset = phAsset;
    model.assetType = type;
    model.duration = duration;
    model.selected = NO;
    return model;
}
@end

@implementation MediaListModel

@end
