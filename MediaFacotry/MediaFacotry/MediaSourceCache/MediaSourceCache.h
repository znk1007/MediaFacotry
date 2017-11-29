//
//  MediaSourceCache.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/29.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaSourceCache : NSObject

/**
 初始化缓存模型

 @param URLString 网络资源路径
 @return MediaSourceCache
 */
- (instancetype _Nonnull )initCacheWithURLString:(NSString * _Nonnull)URLString saveDicrectory:(NSString * _Nullable)directory;

/**
 是否已缓存

 @return BOOL
 */
- (BOOL)isCached;

/**
 获取缓存资源

 @param completion 完成block
 */
- (void)getCacheCompletion:(void(^_Nullable)(NSString * _Nullable filePath, float progress))completion;

@end
