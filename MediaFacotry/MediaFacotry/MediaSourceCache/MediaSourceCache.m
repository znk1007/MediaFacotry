//
//  MediaSourceCache.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/29.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaSourceCache.h"
#import "DataDownloadManager.h"

@interface MediaSourceCache()<DataDownloadDelegate>

/**
 缓存下载管理
 */
@property (nonatomic, strong) DataDownloadManager *cacheManager;

/**
 缓存model
 */
@property (nonatomic, strong) DataDownloadModel *currentCacheModel;

/**
 网络资源路径
 */
@property (nonatomic, copy) NSString *cacheURLString;

/**
 缓存文件夹
 */
@property (nonatomic, copy) NSString *cacheDirecotry;

/**
 缓存下载block
 */
@property (nonatomic, copy) void(^downloadCacheBlock)(NSString * _Nullable filePath, float progress);

@end

@implementation MediaSourceCache

- (void)dealloc
{
    _cacheManager.delegate = nil;
    _currentCacheModel = nil;
    _cacheURLString = nil;
    _cacheDirecotry = nil;
    _downloadCacheBlock = nil;
}

/**
 初始化缓存模型
 
 @param URLString 网络资源路径
 @return MediaSourceCache
 */
- (instancetype _Nonnull )initCacheWithURLString:(NSString * _Nonnull)URLString saveDicrectory:(NSString * _Nullable)directory{
    self = [super init];
    if (self) {
        _cacheURLString = URLString;
        _cacheDirecotry = directory;
    }
    return self;
}

#pragma mark - getter

- (DataDownloadManager *)cacheManager{
    if (!_cacheManager) {
        _cacheManager = [DataDownloadManager defaultManager];
    }
    return _cacheManager;
}

- (DataDownloadModel *)currentCacheModel{
    if (!_currentCacheModel) {
        _currentCacheModel = [[DataDownloadModel alloc] initWithURLString:_cacheURLString filePath:_cacheDirecotry];
    }
    return _currentCacheModel;
}


#pragma mark - public method

/**
 是否已缓存
 
 @return BOOL
 */
- (BOOL)isCached{
    if (!_currentCacheModel) {
        return NO;
    }
    return [self.cacheManager isDownloadCompletedWithDownloadModel:_currentCacheModel];
}

/**
 获取缓存资源
 
 @param completion 完成block
 */
- (void)getCacheCompletion:(void(^_Nullable)(NSString * _Nullable filePath, float progress))completion{
    if ([self isCached]) {
        if (completion) {
            completion(_currentCacheModel.filePath, 1.0f);
        }
        return;
    }
    _downloadCacheBlock = completion;
    DataDownloadModel *downloadingModel = [self.cacheManager currentDownloadingModelWithURLString:_cacheURLString];
    if (downloadingModel) {
        if (downloadingModel.state == DataDownloadStateSuspended) {
            [self.cacheManager resumeDownloadWithModel:downloadingModel];
        }else if (downloadingModel.state == DataDownloadStateFailed) {
            [self startDownloadWithModel:downloadingModel];
        }
        return;
    }
    [self startDownloadWithModel:_currentCacheModel];
}

#pragma mark - private method

- (void)startDownloadWithModel:(DataDownloadModel *)model{
    [self.cacheManager downloadWithModel:model downloadDelegate:self];
}

#pragma mark - DataDownloadDelegate

- (void)downloadModel:(DataDownloadModel *)model didUpdateDownloadProgress:(DataDownloadProgress *)progress{
    if (_downloadCacheBlock) {
        _downloadCacheBlock(nil, progress.progress);
    }
}

- (void)downloadModel:(DataDownloadModel *)model didChangeState:(DataDownloadState)state dowloadFilePath:(NSString *)filePath downlaodError:(NSError *)error{
    if (_downloadCacheBlock) {
        if (model.state == DataDownloadStateCompleted) {
            _downloadCacheBlock(model.filePath, 1.0);
        } else if (model.state == DataDownloadStateFailed) {
            _downloadCacheBlock(nil, 0.0);
        }
    }
}
@end
