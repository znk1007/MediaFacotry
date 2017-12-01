//
//  DataDownloadHeader.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/25.
//  Copyright © 2017年 HM. All rights reserved.
//

#ifndef DataDownloadHeader_h
#define DataDownloadHeader_h

@class DataDownloadProgress;
@class DataDownloadModel;

#pragma mark - 下载枚举
typedef enum {
    /**未开始下载或下载已删除*/
    DataDownloadStateNone,
    /**下载等待中*/
    DataDownloadStateReady,
    /**正在下载*/
    DataDownloadStateRunning,
    /**下载暂停*/
    DataDownloadStateSuspended,
    /**下载完成*/
    DataDownloadStateCompleted,
    /**下载失败*/
    DataDownloadStateFailed
}DataDownloadState;

#pragma mark - 清楚缓存状态
typedef enum {
    /**未知状态*/
    DataDownloadCleanStateUnkown,
    /**无相关数据*/
    DataDownloadCleanStateNoData,
    /**清楚成功*/
    DataDownloadCleanStateSuccess,
    /**清楚失败*/
    DataDownloadCleanStateFailed
}DataDownloadCleanState;

#pragma mark - 下载block
/**
 下载进度block
 
 @param progress 下载进度
 */
typedef void(^DataDownloadProgressBlock)(DataDownloadProgress *progress);

/**
 下载状态block
 
 @param state 状态
 @param filePath 文件路径
 @param error 错误
 */
typedef void(^DataDownloadStateBlock)(DataDownloadState state, NSString *filePath, NSError *error);

#pragma mark - 下载代理
/**下载代理*/

@protocol DataDownloadDelegate <NSObject>

@optional
/**
 下载进度代理
 
 @param model   DataDownloadModel
 @param progress DataDownloadProgress
 */
- (void)downloadModel:(DataDownloadModel *)model didUpdateDownloadProgress:(DataDownloadProgress *)progress;

/**
 下载状态代理

 @param model DataDownloadModel
 @param state DataDownloadState
 @param filePath 保存路径
 @param error 错误
 */
- (void)downloadModel:(DataDownloadModel *)model didChangeState:(DataDownloadState)state dowloadFilePath:(NSString *)filePath downlaodError:(NSError *)error;


@end


#endif /* DataDownloadHeader_h */
