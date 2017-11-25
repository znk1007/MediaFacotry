//
//  DataDownloader.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/25.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "DataDownloadManager.h"

#ifndef dispatch_queue_async_safe
#define dispatch_queue_async_safe(queue, block)                                          \
    if (strcmp(dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL), dispatch_queue_get_label(queue)) == 0) {                                         \
            block();                                                                       \
    } else {\
        dispatch_async(queue, block);                                                   \
    }
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif

NSString *const dataDownloadDefaultDirectoryName = @"DataDownloadCache";

@interface DataDownloadModel ()

/**
 下载保存路径，如设置 downloadDirectory，则文件路径指向 downloadDirectory，否则文件将保存在cache文件夹下
 */
@property (nonatomic, strong) NSString *filePath;

/**
 下载状态
 */
@property (nonatomic, assign) DataDownloadState state;

/**
 下载任务
 */
@property (nonatomic, strong) NSURLSessionTask *task;

/**
 输出流
 */
@property (nonatomic, strong) NSOutputStream *stream;

/**
 下载日期
 */
@property (nonatomic, strong) NSDate *downloadDate;

/**
 手动取消 | 暂停
 */
@property (nonatomic, assign) BOOL manualCancle;

@end

@interface DataDownloadProgress ()

/**
 续传数据大小
 */
@property (nonatomic, assign) int64_t resumeBytesWritten;

/**
 本次写入数据大小
 */
@property (nonatomic, assign) int64_t bytesWritten;

/**
 已下载总大小
 */
@property (nonatomic, assign) int64_t totalBytesWritten;

/**
 下载目标文件总大小
 */
@property (nonatomic, assign) int64_t totalBytesExpectedToWrite;

/**
 下载进度
 */
@property (nonatomic, assign) float progress;

/**
 下载进度
 */
@property (nonatomic, assign) float speed;

/**
 下载剩余时间
 */
@property (nonatomic, assign) int remainingTime;
@end

@interface DataDownloadManager()<NSURLSessionDataDelegate>

/**
 下载地址，默认
 */
@property (nonatomic, copy) NSString *downloadDirectory;

/**
 等待下载的模型
 */
@property (nonatomic, strong) NSMutableArray <DataDownloadModel *> *waitingDownloadModels;

/**
 正在下载的模型
 */
@property (nonatomic, strong) NSMutableArray <DataDownloadModel *> *downloadingModels;

/**
 文件管理
 */
@property (nonatomic, strong) NSFileManager *fileManager;

/**
 下载任务
 */
@property (nonatomic, strong) NSURLSession *downloadSession;

/**
 下载队列
 */
@property (nonatomic, strong) NSOperationQueue *downloadQueue;

/**
 正在下载的模型字典集合
 */
@property (nonatomic, strong) NSMutableDictionary *downloadingModelDict;

@end

@implementation DataDownloadManager

+ (DataDownloadManager *)defaultManager{
    static DataDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxDownloadCount = 1;
        _resumeDownloadFIFO = YES;
        _isBatchDownload = NO;
    }
    return self;
}

#pragma mark - getter

- (NSFileManager *)fileManager{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    return _fileManager;
}

- (NSURLSession *)downloadSession{
    if (!_downloadSession) {
        _downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.downloadQueue];
    }
    return _downloadSession;
}

- (NSOperationQueue *)downloadQueue{
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}


#pragma mark - Public Method


#pragma mark - Private Method

/**
 下载状态变化>代理、block统一处理

 @param model DataDownloadModel
 @param state DataDownloadState
 @param filePath 保存路径
 @param error 错误
 */
- (void)downloadModel:(DataDownloadModel *)model didChangeState:(DataDownloadState)state dowloadFilePath:(NSString *)filePath downlaodError:(NSError *)error{
    if (_delegate && [_delegate respondsToSelector:@selector(downloadModel:didChangeState:dowloadFilePath:downlaodError:)]) {
        [_delegate downloadModel:model didChangeState:state dowloadFilePath:filePath downlaodError:error];
    }
    if (model.stateBlock) {
        model.stateBlock(state, filePath, error);
    }
}

/**
 下载进度>代理、block统一处理

 @param model DataDownloadModel
 @param progress DataDownloadProgress
 */
- (void)downloadModel:(DataDownloadModel *)model didUpdateDownloadProgress:(DataDownloadProgress *)progress{
    if (_delegate && [_delegate respondsToSelector:@selector(downloadModel:didUpdateDownloadProgress:)]) {
        [_delegate downloadModel:model didUpdateDownloadProgress:progress];
    }
    if (model.progressBlock) {
        model.progressBlock(progress);
    }
}

/**
 创建文件目录

 @param directory 文件夹路径
 */
- (void)createDirectory:(NSString *)directory{
    
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
//    DataDownloadModel *downloadModel = [self do]
}


#pragma mark - Manager Calculate Tool

+ (float)calculateFileSizeInUnit:(unsigned long long)contentLength{
    if(contentLength >= pow(1024, 3)){
        return (float) (contentLength / (float)pow(1024, 3));
    }else if(contentLength >= pow(1024, 2)){
        return (float) (contentLength / (float)pow(1024, 2));
    }else if(contentLength >= 1024){
        return (float) (contentLength / (float)1024);
    }else{
        return (float) (contentLength);
    }
}

+ (NSString *)calculateUnit:(unsigned long long)contentLength{
    if(contentLength >= pow(1024, 3)){
        return @"GB";
    }else if(contentLength >= pow(1024, 2)){
        return @"MB";
    }else if(contentLength >= 1024){
        return @"KB";
    }    else{
        return @"Bytes";
    }
}

@end

