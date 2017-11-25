//
//  DataDownloadModel.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/25.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataDownloadHeader.h"
#import "DataDownloadProgress.h"


@interface DataDownloadModel : NSObject

/**
 下载地址
 */
@property (nonatomic, readonly) NSString *downloadURL;

/**
 下载保存目录 默认cache文件夹下
 */
@property (nonatomic, copy) NSString *downloadDirectory;

/**
 下载保存路径，如设置 downloadDirectory，则文件路径指向 downloadDirectory，否则文件将保存在cache文件夹下
 */
@property (nonatomic, readonly) NSString *filePath;

/**
 文件名，下载地址中lastPathComponent
 */
@property (nonatomic, readonly) NSString *fileName;

/**
 下载状态
 */
@property (nonatomic, readonly) DataDownloadState state;

/**
 下载任务
 */
@property (nonatomic, readonly) NSURLSessionTask *task;

/**
 输出流
 */
@property (nonatomic, readonly) NSOutputStream *stream;

/**
 下载日期
 */
@property (nonatomic, readonly) NSDate *downloadDate;

/**
 断点续传数据
 */
@property (nonatomic, readonly) NSData *resumeData;

/**
 手动取消 | 暂停
 */
@property (nonatomic, readonly) BOOL manualCancle;
/**
 下载进度对象
 */
@property (nonatomic, readonly) DataDownloadProgress *progress;

/**
 下载进度block
 */
@property (nonatomic, copy) DataDownloadProgressBlock progressBlock;

/**
 下载状态block
 */
@property (nonatomic, copy) DataDownloadStateBlock stateBlock;

/**
 初始化方式一, 默认保存到到cache文件夹

 @param URLString 下载路径
 @return DataDownloadModel
 */
- (instancetype)initWithURLString:(NSString *)URLString;

/**
 初始化方式二，如filePath为nil，则与方式一一致

 @param URLString 下载路径
 @param filePath 保存路径
 @return DataDownloadModel
 */
- (instancetype)initWithURLString:(NSString *)URLString filePath:(NSString *)filePath;

@end
