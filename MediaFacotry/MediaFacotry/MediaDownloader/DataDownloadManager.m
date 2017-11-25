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

@interface DataDownloadManager()

/**
 等待下载的模型
 */
@property (nonatomic, strong) NSMutableArray <DataDownloadModel *> *waitingDownloadModels;

/**
 正在下载的模型
 */
@property (nonatomic, strong) NSMutableArray <DataDownloadModel *> *downloadingModels;
@end

@implementation DataDownloadManager


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

