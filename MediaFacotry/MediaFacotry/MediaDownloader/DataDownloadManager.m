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

NSString *const managerDataDownloadDefaultDirectoryName = @"DataDownloadCache";
NSString *const dataDownloadDefaultPlistName = @"dataDownloadFileInfo.plist";

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

- (NSString *)downloadDirectory{
    if (!_downloadDirectory) {
        _downloadDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:managerDataDownloadDefaultDirectoryName];
    }
    return _downloadDirectory;
}

- (NSMutableDictionary *)downloadingModelDict{
    if (!_downloadingModelDict) {
        _downloadingModelDict = [NSMutableDictionary dictionary];
    }
    return _downloadingModelDict;
}

- (NSMutableArray<DataDownloadModel *> *)waitingDownloadModels{
    if (!_waitingDownloadModels) {
        _waitingDownloadModels = [NSMutableArray array];
    }
    return _waitingDownloadModels;
}

- (NSMutableArray<DataDownloadModel *> *)downloadingModels{
    if (!_downloadingModels) {
        _downloadingModels = [NSMutableArray array];
    }
    return _downloadingModels;
}


#pragma mark - Public Method

#pragma mark - 删除资源文件

/**
 删除当前下载并清空文件
 
 @param model DataDownloadModel
 */
- (void)deleteDownloadWithModel:(DataDownloadModel *)model{
    if (!model || !model.filePath) {
        return;
    }
    //如果文件存在则删除
    if ([self.fileManager fileExistsAtPath:model.filePath]) {
        //删除任务
        model.task.taskDescription = nil;
        [model.task cancel];
        model.task = nil;
        //删除输出流
        if (model.stream.streamStatus > NSStreamStatusNotOpen && model.stream.streamStatus < NSStreamStatusClosed) {
            [model.stream close];
        }
        model.stream = nil;
        //删除沙盒中的资源
        NSError *error = nil;
        [self.fileManager removeItemAtPath:model.filePath error:&error];
        if (error) {
            NSLog(@"删除资源文件失败---> %@",error);
        }
        [self removeDownloadingModelWithURLString:model.downloadURL];
        //删除资源总长度
        if ([self.fileManager fileExistsAtPath:[self plistFilePathWithDownloadModel:model]]) {
            @synchronized (self){
                NSMutableDictionary *dict = [self fileSizePlistWithDownloadModel:model];
                [dict removeObjectForKey:model.downloadURL];
                [dict writeToFile:[self plistFilePathWithDownloadModel:model] atomically:YES];
            }
        }
    }
}

/**
 删除directory下所有下载文件
 
 @param directory 文件路径
 */
- (void)deleteAllDownloadWithDownloadDirectory:(NSString *)directory{
    if (!directory) {
        directory = self.downloadDirectory;
    }
    if ([self.fileManager fileExistsAtPath:directory]) {
        //删除任务
        for (DataDownloadModel *model in [self.downloadingModelDict allValues]) {
            if ([model.downloadDirectory isEqualToString:directory]) {
                //删除DataDownloadModel任务
                model.task.taskDescription = nil;
                [model.task cancel];
                model.task = nil;
                //删除DataDownloadModel流
                if (model.stream.streamStatus > NSStreamStatusNotOpen && model.stream.streamStatus < NSStreamStatusClosed) {
                    [model.stream close];
                }
                model.stream = nil;
            }
        }
        //删除沙盒所有文件资源
        [self.fileManager removeItemAtPath:directory error:nil];
    }
}

#pragma mark - 下载相关

/**
 下载方式三，先初始化 DataDownloadModel，delegate回调
 
 @param model DataDownloadModel
 @param delegate 下载代理
 */
- (void)downloadWithModel:(DataDownloadModel *)model downloadDelegate:(id<DataDownloadDelegate>)delegate{
    _delegate = delegate;
    [self downloadWithModel:model];
}

/**
 下载方式三，代理方式，通过delegate回调
 
 @param URLString 下载地址
 @param targetPath 保存路径
 @param delegate 下载代理
 */
- (void)downloadWithURLString:(NSString *)URLString targetSavePath:(NSString *)targetPath downloadDelegate:(id<DataDownloadDelegate>)delegate{
    DataDownloadModel *model = [self downloadWithURLString:URLString targetSavePath:targetPath downloadProgress:nil downloadState:nil];
    if (!model) {
        return;
    }
    _delegate = delegate;
    [self downloadWithModel:model];
}

/**
 下载方式一，block回调
 
 @param URLString 下载地址
 @param targetPath 保存路径
 @param progressBlock 进度block
 @param stateBlock 状态block
 @return DataDownloadModel
 */
- (DataDownloadModel *)downloadWithURLString:(NSString *)URLString targetSavePath:(NSString *)targetPath downloadProgress:(DataDownloadProgressBlock)progressBlock downloadState:(DataDownloadStateBlock)stateBlock{
    //校验URLString是否合规
    if (!URLString || [URLString isEqualToString:@""] || ![URLString hasPrefix:@"http://"] || ![URLString hasPrefix:@"https://"]) {
        return nil;
    }
    //检查是否有等待下载队列
    DataDownloadModel *model = [self currentDownloadingModelWithURLString:URLString];
    if (!model || ![model.filePath isEqualToString:targetPath]) {
        model = [[DataDownloadModel alloc] initWithURLString:URLString filePath:targetPath];
    }
    [self downloadWithModel:model downloadProgress:progressBlock downloadState:stateBlock];
    return model;
}

/**
 下载方式二，初始化DataDownloadModel后 下载，block回调
 
 @param model DataDownloadModel
 @param progressBlock 进度block
 @param stateBlock 状态block
 */
- (void)downloadWithModel:(DataDownloadModel *)model downloadProgress:(DataDownloadProgressBlock)progressBlock downloadState:(DataDownloadStateBlock)stateBlock{
    //block
    if (progressBlock) {
        model.progressBlock = progressBlock;
    }
    if (stateBlock) {
        model.stateBlock = stateBlock;
    }
    //下载
    [self downloadWithModel:model];
}

/**
 下载方式四，初始化 DataDownloadModel， 如用delegate，需赋值
 
 @param model DataDownloadModel
 */
- (void)downloadWithModel:(DataDownloadModel *)model{
    if (!model) {
        return;
    }
    if (model.state == DataDownloadStateReady) {
        [self downloadModel:model didChangeState:DataDownloadStateReady dowloadFilePath:nil downlaodError:nil];
        return;
    }
    //检查DataDownloadModel已下载
    if ([self isDownloadCompletedWithDownloadModel:model]) {
        model.state = DataDownloadStateCompleted;
        [self downloadModel:model didChangeState:DataDownloadStateCompleted dowloadFilePath:model.filePath downlaodError:nil];
        return;
    }
    //检查下载任务是否存在
    if (model.task && model.task.state == NSURLSessionTaskStateRunning) {
        model.state = DataDownloadStateRunning;
        [self downloadModel:model didChangeState:DataDownloadStateRunning dowloadFilePath:nil downlaodError:nil];
        return;
    }
    
    //下载 || 恢复下载任务
    [self resumeDownloadWithModel:model];
}



/**
 当前下载

 @param URLString 下载路径
 @return DataDownloadModel
 */
- (DataDownloadModel *)currentDownloadingModelWithURLString:(NSString *)URLString{
    return [self.downloadingModelDict objectForKey:URLString];
}

/**
 当前下载DataDownloadModel的DataDownloadProgress
 
 @param model DataDownloadModel
 @return DataDownloadProgress
 */
- (DataDownloadProgress *)currentProgressWithDownloadModel:(DataDownloadModel *)model{
    DataDownloadProgress *progress = [[DataDownloadProgress alloc] init];
    progress.totalBytesExpectedToWrite = [self fileSizeInPlistWithDownloadModel:model];
    progress.totalBytesWritten = MIN([self fileSizeWithDownloadModel:model], progress.totalBytesExpectedToWrite);
    progress.progress = progress.totalBytesExpectedToWrite > 0 ? 1.0*progress.totalBytesWritten/progress.totalBytesExpectedToWrite : 0;
    return progress;
}

/**
 是否已下载完成

 @param model DataDownloadModel
 @return BOOL
 */
- (BOOL)isDownloadCompletedWithDownloadModel:(DataDownloadModel *)model{
    long long fileSize = [self fileSizeInPlistWithDownloadModel:model];
    if (fileSize > 0 && fileSize == [self fileSizeWithDownloadModel:model]) {
        return YES;
    }
    return NO;
}

/**
 恢复DataDownloadModel下载
 
 @param model DataDownloadModel
 */
- (void)resumeDownloadWithModel:(DataDownloadModel *)model{
    if (!model) {
        return;
    }
    if (![self canResumeDownloadModel:model]) {
        return;
    }
    //如果task不存在 或 取消下载
    if (!model.task || model.task.state == NSURLSessionTaskStateCanceling) {
        NSString *URLString = model.downloadURL;
        //创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
        //设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-",[self fileSizeWithDownloadModel:model]];
        [request setValue:range forHTTPHeaderField:@"Range"];
        //创建流
        model.stream = [NSOutputStream outputStreamToFileAtPath:model.filePath append:YES];
        //下载时间
        model.downloadDate = [NSDate date];
        //保存当前DataDownloadModel
        self.downloadingModelDict[model.downloadURL] = model;
        //创建下载任务
        model.task = [self.downloadSession dataTaskWithRequest:request];
        model.task.taskDescription = URLString;
    }
    [model.task resume];
    model.state = DataDownloadStateRunning;
    [self downloadModel:model didChangeState:DataDownloadStateRunning dowloadFilePath:nil downlaodError:nil];
}

/**
 停止当前model下载
 
 @param model DataDownloadModel
 */
- (void)suspendDownloadWithModel:(DataDownloadModel *)model{
    if (!model.manualCancle) {
        model.manualCancle = YES;
        [model.task cancel];
    }
}

/**
 删除当前下载并清空文件
 
 @param model DataDownloadModel
 */
- (void)cancelDownloadWithModel:(DataDownloadModel *)model{
    if (!model) {
        return;
    }
    if (!model.task && model.state == DataDownloadStateReady) {
        [self removeDownloadingModelWithURLString:model.downloadURL];
        @synchronized (self){
            [self.waitingDownloadModels removeObject:model];
        }
        model.state = DataDownloadStateNone;
        [self downloadModel:model didChangeState:DataDownloadStateNone dowloadFilePath:nil downlaodError:nil];
        return;
    }
    if (model.state != DataDownloadStateCompleted && model.state != DataDownloadStateFailed) {
        [model.task cancel];
    }
}

#pragma mark - 资源大小

/**
 DataDownloadManager所下载所有文件大小
 
 @return DataDownloadManager所下载所有文件大小，单位M
 */
- (double)dataSizeForDataDownloadManager{
    NSString *defaultPath = self.downloadDirectory;
    if (![self.fileManager fileExistsAtPath:defaultPath]) {
        return 0;
    }
    __block double totalSize = 0;
    __weak typeof(self) weakSelf = self;
    NSArray *subFolders = [self.fileManager subpathsAtPath:defaultPath];
    [subFolders enumerateObjectsUsingBlock:^(NSString * _Nonnull subpath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [defaultPath stringByAppendingPathComponent:subpath];
        totalSize += [weakSelf fileSizeAtPath:filePath];
    }];
    return totalSize;
}

/**
 某个文件夹下数据大小
 
 @param directory 缓存文件夹
 @return 文件大小，单位M
 */
- (double)dataSizeWithDownloadDirectory:(NSString *)directory{
    if (![self.fileManager fileExistsAtPath:directory]) {
        return 0;
    }
    __block double totalSize = 0;
    __weak typeof(self) weakSelf = self;
    NSArray *subFolders = [self.fileManager subpathsAtPath:directory];
    [subFolders enumerateObjectsUsingBlock:^(NSString * _Nonnull subpath, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [directory stringByAppendingPathComponent:subpath];
        totalSize += [weakSelf fileSizeAtPath:filePath];
    }];
    return totalSize;
}


/**
 清楚缓存
 
 @param completion 清除完成block
 */
- (void)cleanData:(void(^)(DataDownloadCleanState state))completion{
    dispatch_queue_async_safe(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSError *folderErr = nil;
        NSString *defaultPath = self.downloadDirectory;
        NSArray *subFolders = [self.fileManager contentsOfDirectoryAtPath:defaultPath error:&folderErr];
        if (folderErr || !subFolders) {
            if (completion) {
                dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                    completion(DataDownloadCleanStateFailed);
                });
            }
            return ;
        }
        if (subFolders.count == 0) {
            if (completion) {
                dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                    completion(DataDownloadCleanStateNoData);
                });
            }
            return ;
        }
        [subFolders enumerateObjectsUsingBlock:^(NSString *  _Nonnull subpath, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *filePath = [defaultPath stringByAppendingPathComponent:subpath];
            if ([self.fileManager fileExistsAtPath:filePath]) {
                [self.fileManager removeItemAtPath:filePath error:nil];
            }
        }];
        if (completion) {
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                completion(DataDownloadCleanStateSuccess);
            });
        }
    });
}

/**
 清除文件夹缓存
 
 @param directory 文件夹路径
 @param completion 清除完成block
 */
- (void)cleanDataWithDirectory:(NSString *)directory completion:(void(^)(DataDownloadCleanState state))completion{
    if (!directory || [directory isEqualToString:@""]) {
        if (completion) {
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                completion(DataDownloadCleanStateFailed);
            });
        }
        return;
    }
    dispatch_queue_async_safe(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        NSError *folderErr = nil;
        NSString *defaultPath = directory;
        NSArray *subFolders = [self.fileManager contentsOfDirectoryAtPath:defaultPath error:&folderErr];
        if (folderErr || !subFolders) {
            if (completion) {
                dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                    completion(DataDownloadCleanStateFailed);
                });
            }
            return ;
        }
        if (subFolders.count == 0) {
            if (completion) {
                dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                    completion(DataDownloadCleanStateNoData);
                });
            }
            return ;
        }
        [subFolders enumerateObjectsUsingBlock:^(NSString *  _Nonnull subpath, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *filePath = [defaultPath stringByAppendingPathComponent:subpath];
            if ([self.fileManager fileExistsAtPath:filePath]) {
                [self.fileManager removeItemAtPath:filePath error:nil];
            }
        }];
        if (completion) {
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                completion(DataDownloadCleanStateSuccess);
            });
        }
    });
}

/**
 清除DataDownloadModel文件缓存
 
 @param model DataDownloadModel
 @param completion 清除完成block
 */
- (void)cleanDataWithModel:(DataDownloadModel *)model completion:(void(^)(DataDownloadCleanState state))completion{
    if (!model) {
        if (completion) {
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                completion(DataDownloadCleanStateFailed);
            });
        }
        return;
    }
    NSString *defaultPath = model.filePath;
    if (!defaultPath || [defaultPath isEqualToString:@""]) {
        if (completion) {
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                completion(DataDownloadCleanStateFailed);
            });
        }
        return;
    }
    dispatch_queue_async_safe(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        if (![self.fileManager fileExistsAtPath:defaultPath]) {
            if (completion) {
                dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                    completion(DataDownloadCleanStateFailed);
                });
            }
            return;
        }
        NSError *removeErr = nil;
        [self.fileManager removeItemAtPath:defaultPath error:&removeErr];
        if (removeErr) {
            if (completion) {
                dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                    completion(DataDownloadCleanStateFailed);
                });
            }
            return;
        }
        if (completion) {
            dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
                completion(DataDownloadCleanStateSuccess);
            });
        }
    });
}

/**
 获取保存路径下文件大小
 
 @param model DataDownloadModel
 @return 文件大小，单位M
 */
- (double)dataSizeWithDownloadModel:(DataDownloadModel *)model{
    if (!model) {
        return 0;
    }
    return [self fileSizeAtPath:model.filePath];
}

#pragma mark - Private Method

/**
 计算保存路径下文件大小
 
 @param filePath 文件路径
 @return 文件大小，单位M
 */
- (double)fileSizeAtPath:(NSString *)filePath{
    if (!filePath || [filePath isEqualToString:@""]) {
        return 0;
    }
    BOOL isDirectory = NO;
    BOOL isExist = [self.fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isExist && !isDirectory) {
        NSError *err = nil;
        NSDictionary <NSFileAttributeKey, id> *fileAttr = [self.fileManager attributesOfItemAtPath:filePath error:&err];
        if (err) {
            return 0;
        }
        unsigned long long size = fileAttr.fileSize;
        return [[self class] calculateFileSizeInUnit:size];
    }
    return 0;
}

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
    if (![self.fileManager fileExistsAtPath:directory]) {
        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

/**
 获取保存路径下文件大小

 @param model DataDownloadModel
 @return 文件大小
 */
- (long long)fileSizeWithDownloadModel:(DataDownloadModel *)model{
    if (!model) {
        return 0;
    }
    NSString *filePath = model.filePath;
    if (![self.fileManager fileExistsAtPath:filePath]) {
        return 0;
    }
    return [[self.fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
}

/**
 plist文件路径

 @param model DataDownloadModel
 @return plist文件路径
 */
- (NSString *)plistFilePathWithDownloadModel:(DataDownloadModel *)model{
    return [model.downloadDirectory stringByAppendingPathComponent:dataDownloadDefaultPlistName];
}

/**
 获取plist文件内容

 @param model DataDownloadModel
 @return plist文件内容
 */
- (NSMutableDictionary *)fileSizePlistWithDownloadModel:(DataDownloadModel *)model{
    NSMutableDictionary *downloadFileSizePlist = [NSMutableDictionary dictionaryWithContentsOfFile:[self plistFilePathWithDownloadModel:model]];
    if (!downloadFileSizePlist) {
        downloadFileSizePlist = [NSMutableDictionary dictionary];
    }
    return downloadFileSizePlist;
}

/**
 移除当前URLString对应的下载

 @param URLString 下载路径
 */
- (void)removeDownloadingModelWithURLString:(NSString *)URLString{
    [self.downloadingModelDict removeObjectForKey:URLString];
}

/**
 plist文件保存下载数据的大小

 @param model DataDownloadModel
 @return 已下载数据大小
 */
- (long long)fileSizeInPlistWithDownloadModel:(DataDownloadModel *)model{
    NSDictionary *downloadedFileSizePlist = [NSDictionary dictionaryWithContentsOfFile:[self plistFilePathWithDownloadModel:model]];
    return [downloadedFileSizePlist[model.downloadURL] longLongValue];
}

/**
 下载下一个数据模型

 @param model DataDownloadModel
 */
- (void)willResumeNextWithDownlaodModel:(DataDownloadModel *)model{
    if (_isBatchDownload) {
        return;
    }
    @synchronized (self){
        [self.downloadingModels removeObject:model];
        //是否有未下载
        if (self.waitingDownloadModels.count > 0) {
            [self resumeDownloadWithModel:_resumeDownloadFIFO ? self.waitingDownloadModels.firstObject : self.waitingDownloadModels.lastObject];
        }
    }
}

/**
 是否开启下载等待队列任务

 @param model DataDownloadModel
 */
- (BOOL)canResumeDownloadModel:(DataDownloadModel *)model{
    if (_isBatchDownload) {
        return YES;
    }
    
    @synchronized (self){
        if (self.downloadingModels.count >= _maxDownloadCount) {
            if ([self.waitingDownloadModels indexOfObject:model] == NSNotFound) {
                [self.waitingDownloadModels addObject:model];
                self.downloadingModelDict[model.downloadURL] = model;
            }
            model.state = DataDownloadStateReady;
            [self downloadModel:model didChangeState:DataDownloadStateReady dowloadFilePath:nil downlaodError:nil];
            return NO;
        }
        if ([self.waitingDownloadModels indexOfObject:model] != NSNotFound) {
            [self.waitingDownloadModels removeObject:model];
        }
        if ([self.downloadingModels indexOfObject:model] == NSNotFound) {
            [self.downloadingModels addObject:model];
        }
        return YES;
    }
}

#pragma mark - NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    DataDownloadModel *downloadModel = [self currentDownloadingModelWithURLString:dataTask.taskDescription];
    if (!downloadModel) {
        return;
    }
    //创建目录
    [self createDirectory:self.downloadDirectory];
    [self createDirectory:downloadModel.downloadDirectory];
    
    //打开输出流
    [downloadModel.stream open];
    
    //本次服务器请求数据总长度
    long long totalBytesWritten = [self fileSizeWithDownloadModel:downloadModel];
    long long totalBytesExpectedToWrite = totalBytesWritten + dataTask.countOfBytesExpectedToReceive;
    
    //保存到DataDownloadProgress
    downloadModel.progress.resumeBytesWritten = totalBytesWritten;
    downloadModel.progress.totalBytesWritten = totalBytesWritten;
    downloadModel.progress.totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    
    //存储总长度
    @synchronized (self){
        NSMutableDictionary *dic = [self fileSizePlistWithDownloadModel:downloadModel];
        dic[downloadModel.downloadURL] = @(totalBytesExpectedToWrite);
        [dic writeToFile:[self plistFilePathWithDownloadModel:downloadModel] atomically:YES];
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    DataDownloadModel *model =  [self currentDownloadingModelWithURLString:dataTask.taskDescription];
    if (!model || model.state == DataDownloadStateSuspended) {
        return;
    }
    //写入数据
    [model.stream write:data.bytes maxLength:data.length];
    //下载进度
    model.progress.bytesWritten = data.length;
    model.progress.totalBytesWritten += model.progress.bytesWritten;
    model.progress.progress = MIN(1.0, 1.0 * model.progress.totalBytesWritten / model.progress.totalBytesExpectedToWrite);
    //下载时间
    NSTimeInterval downloadTime = -1 * [model.downloadDate timeIntervalSinceNow];
    model.progress.speed = (model.progress.totalBytesExpectedToWrite - model.progress.resumeBytesWritten) / downloadTime;
    
    int64_t remainingContentLength = model.progress.totalBytesExpectedToWrite - model.progress.totalBytesWritten;
    
    model.progress.remainingTime = ceilf(remainingContentLength / model.progress.speed);
    
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
        [self downloadModel:model didUpdateDownloadProgress:model.progress];
    });
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    DataDownloadModel *model = [self currentDownloadingModelWithURLString:task.taskDescription];
    if (!model) {
        return;
    }
    //关闭流
    [model.stream close];
    model.stream = nil;
    model.task = nil;
    
    [self removeDownloadingModelWithURLString:model.downloadURL];
    
    if (model.manualCancle) {
        //暂停下载
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
            model.manualCancle = NO;
            model.state = DataDownloadStateSuspended;
            [self downloadModel:model didChangeState:model.state dowloadFilePath:nil downlaodError:nil];
            [self willResumeNextWithDownlaodModel:model];
        });
    }else if (error){
        //下载失败
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
            model.state = DataDownloadStateFailed;
            [self downloadModel:model didChangeState:DataDownloadStateFailed dowloadFilePath:nil downlaodError:error];
            [self willResumeNextWithDownlaodModel:model];
        });
    }else if ([self isDownloadCompletedWithDownloadModel:model]){
        //下载完成
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
            model.state = DataDownloadStateCompleted;
            [self downloadModel:model didChangeState:DataDownloadStateCompleted dowloadFilePath:model.filePath downlaodError:nil];
            [self willResumeNextWithDownlaodModel:model];
        });
    }else{
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^(){
            model.state = DataDownloadStateCompleted;
            [self downloadModel:model didChangeState:DataDownloadStateCompleted dowloadFilePath:model.filePath downlaodError:nil];
            [self willResumeNextWithDownlaodModel:model];
        });
    }
}

#pragma mark - Manager Calculate Tool

+ (double)calculateFileSizeInUnit:(unsigned long long)contentLength{
    if(contentLength >= pow(1024, 3)){
        return (double) (contentLength / (float)pow(1024, 3));
    }else if(contentLength >= pow(1024, 2)){
        return (double) (contentLength / (float)pow(1024, 2));
    }else if(contentLength >= 1024){
        return (double) (contentLength / (float)1024);
    }else{
        return (double) (contentLength);
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

