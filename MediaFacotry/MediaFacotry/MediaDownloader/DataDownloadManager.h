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
 下载方式四，初始化 DataDownloadModel， 如用delegate，需赋值

 @param model DataDownloadModel
 */
- (void)downloadWithModel:(DataDownloadModel *)model;

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
 删除当前下载并清空文件

 @param model DataDownloadModel
 */
- (void)deleteDownloadWithModel:(DataDownloadModel *)model;

/**
 删除directory下所有下载文件

 @param directory 文件路径
 */
- (void)deleteAllDownloadWithDownloadDirectory:(NSString *)directory;

/**
 当前下载的DataDownloadModel

 @param URLString 下载路径
 @return DataDownloadModel
 */
- (DataDownloadModel *)currentDownloadingModelWithURLString:(NSString *)URLString;

/**
 当前下载DataDownloadModel的DataDownloadProgress

 @param model DataDownloadModel
 @return DataDownloadProgress
 */
- (DataDownloadProgress *)currentProgressWithDownloadModel:(DataDownloadModel *)model;

/**
 是否已下载完成

 @param model DataDownloadModel
 @return 完成YES，未完成NO
 */
- (BOOL)isDownloadCompletedWithDownloadModel:(DataDownloadModel *)model;

/**
 DataDownloadManager所下载所有文件大小

 @return DataDownloadManager所下载所有文件大小，单位M
 */
- (double)dataSizeForDataDownloadManager;

/**
 获取保存路径下文件大小
 
 @param model DataDownloadModel
 @return 文件大小，单位M
 */
- (double)dataSizeWithDownloadModel:(DataDownloadModel *)model;

/**
 某个文件夹下数据大小

 @param directory 缓存文件夹
 @return 文件大小，单位M
 */
- (double)dataSizeWithDownloadDirectory:(NSString *)directory;

/**
 清楚缓存 ，保留self.downloadDirectory路径文件夹

 @param completion 清除完成block
 */
- (void)cleanData:(void(^)(DataDownloadCleanState state))completion;

/**
 清除文件夹缓存，保留directory路径文件夹

 @param directory 文件夹路径
 @param completion 清除完成block
 */
- (void)cleanDataWithDirectory:(NSString *)directory completion:(void(^)(DataDownloadCleanState state))completion;

/**
 清除DataDownloadModel文件缓存

 @param model DataDownloadModel
 @param completion 清除完成block
 */
- (void)cleanDataWithModel:(DataDownloadModel *)model completion:(void(^)(DataDownloadCleanState state))completion;

/**
 换算文件大小

 @param contentLength 文件长度
 @return 换算结果
 */
+ (double)calculateFileSizeInUnit:(unsigned long long)contentLength;

/**
 文件单位

 @param contentLength 文件长度
 @return 计算后文件单位
 */
+ (NSString *)calculateUnit:(unsigned long long)contentLength;
@end
