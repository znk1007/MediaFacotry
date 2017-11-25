//
//  DataDownloadModel.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/25.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "DataDownloadModel.h"

NSString *const dataDownloadDefaultDirectoryName = @"DataDownloadCache";

@interface DataDownloadModel ()
/**
 下载地址
 */
@property (nonatomic, copy) NSString *downloadURL;

/**
 下载保存路径，如设置 downloadDirectory，则文件路径指向 downloadDirectory，否则文件将保存在cache文件夹下
 */
@property (nonatomic, copy) NSString *filePath;

/**
 文件名，下载地址中lastPathComponent
 */
@property (nonatomic, copy) NSString *fileName;

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
 断点续传数据
 */
@property (nonatomic, strong) NSData *resumeData;

/**
 手动取消 | 暂停
 */
@property (nonatomic, assign) BOOL manualCancle;

@end

@implementation DataDownloadModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _progress = [[DataDownloadProgress alloc] init];
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString{
    return [self initWithURLString:URLString filePath:nil];
}

- (instancetype)initWithURLString:(NSString *)URLString filePath:(NSString *)filePath{
    self = [self init];
    if (self) {
        _downloadURL = URLString;
        _fileName = filePath.lastPathComponent;
        _filePath = filePath;
        _downloadDirectory = filePath.stringByDeletingLastPathComponent;
    }
    return self;
}

- (NSString *)fileName{
    if (!_fileName) {
        _fileName = _filePath.lastPathComponent;
    }
    return _fileName;
}

- (NSString *)downloadDirectory{
    if (!_downloadDirectory) {
        _downloadDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:dataDownloadDefaultDirectoryName];
    }
    return _downloadDirectory;
}

- (NSString *)filePath{
    if (!_filePath) {
        _filePath = [self.downloadDirectory stringByAppendingPathComponent:self.fileName];
    }
    return _filePath;
}

@end
