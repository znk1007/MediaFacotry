//
//  DataDownloader.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/25.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataDownloadModel.h"

@interface DataDownloadManager : NSObject

/**
 下载代理
 */
@property (nonatomic, assign) id <DataDownloadDelegate> delegate;

/**
 等待下载的模型
 */
@property (nonatomic, readonly) NSMutableArray <DataDownloadModel *> *waitingDownloadModels;

/**
 正在下载的模型
 */
@property (nonatomic, readonly) NSMutableArray <DataDownloadModel *> *downloadingModels;

/**
 最大下载数
 */
@property (nonatomic, assign) NSInteger maxDownloadCount;

/**
 等待下载队列，默认YES，先进先出，设置NO则先进后出
 */
@property (nonatomic, assign) BOOL resumeDownloadFIFO;

/**
 全部并发，默认NO，设置YES，则忽略maxDownloadCount
 */
@property (nonatomic, assign) BOOL isBatchDownload;

/**
 下载单例

 @return DataDownloadManager
 */
+ (DataDownloadManager *)defaultManager;

/**
 下载方式一，block回调

 @param URLString 下载地址
 @param targetPath 保存路径
 @param progressBlock 进度block
 @param stateBlock 状态block
 @return DataDownloadModel
 */
- (DataDownloadModel *)downloadWithURLString:(NSString *)URLString targetSavePath:(NSString *)targetPath downloadProgress:(DataDownloadProgressBlock)progressBlock downloadState:(DataDownloadStateBlock)stateBlock;

/**
 下载方式二，初始化DataDownloadModel后 下载，block回调

 @param model DataDownloadModel
 @param progressBlock 进度block
 @param stateBlock 状态block
 */
- (void)downloadWithModel:(DataDownloadModel *)model downloadProgress:(DataDownloadProgressBlock)progressBlock downloadState:(DataDownloadStateBlock)stateBlock;

/**
 下载方式三，代理方式，通过delegate回调

 @param URLString 下载地址
 @param targetPath 保存路径
 @param delegate 下载代理
 */
- (void)downloadWithURLString:(NSString *)URLString targetSavePath:(NSString *)targetPath downloadDelegate:(id<DataDownloadDelegate>)delegate;


/**
 下载方式三，先初始化 DataDownloadModel，delegate回调

 @param model DataDownloadModel
 @param delegate 下载代理
 */
- (void)downloadWithModel:(DataDownloadModel *)model downloadDelegate:(id<DataDownloadDelegate>)delegate;

/**
 恢复当前model下载，如当前DataDownloadModel处于停止状态才会重新下载

 @param model DataDownloadModel
 */
- (void)resumeDownloadWithModel:(DataDownloadModel *)model;

/**
 停止当前model下载

 @param model DataDownloadModel
 */
- (void)suspendDownloadWithModel:(DataDownloadModel *)model;

/**
 取消当前model下载

 @param model DataDownloadModel
 */
- (void)cancelDownloadWithModel:(DataDownloadModel *)model;
/**
 换算文件大小

 @param contentLength 文件长度
 @return 换算结果
 */
+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength;

/**
 文件单位

 @param contentLength 文件长度
 @return 计算后文件单位
 */
+ (NSString *)calculateUnit:(unsigned long long)contentLength;
@end
