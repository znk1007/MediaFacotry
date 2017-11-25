//
//  DataDownloadProgress.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/25.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "DataDownloadProgress.h"

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

@implementation DataDownloadProgress
- (instancetype)init
{
    self = [super init];
    if (self) {
        _remainingTime = 0;
        _resumeBytesWritten = 0;
        _bytesWritten = 0;
        _totalBytesWritten = 0;
        _totalBytesExpectedToWrite = 0;
        _progress = 0.0f;
        _speed = 0.0f;
    }
    return self;
}
@end
