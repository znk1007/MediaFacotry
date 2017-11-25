//
//  DataDownloadProgress.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/25.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataDownloadProgress : NSObject

/**
 续传数据大小
 */
@property (nonatomic, readonly) int64_t resumeBytesWritten;

/**
 本次写入数据大小
 */
@property (nonatomic, readonly) int64_t bytesWritten;

/**
 已下载总大小
 */
@property (nonatomic, readonly) int64_t totalBytesWritten;

/**
 下载目标文件总大小
 */
@property (nonatomic, readonly) int64_t totalBytesExpectedToWrite;

/**
 下载进度
 */
@property (nonatomic, readonly) float progress;

/**
 下载进度
 */
@property (nonatomic, readonly) float speed;

/**
 下载剩余时间
 */
@property (nonatomic, readonly) int remainingTime;

@end
