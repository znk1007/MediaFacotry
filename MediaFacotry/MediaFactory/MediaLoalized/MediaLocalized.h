//
//  MediaLoalized.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaLocalized : NSObject

@end

@class MediaLoalizedTool;

@protocol MediaLoalizedToolDelegate <NSObject>

/**
 结束解析

 @param tool MediaLoalizedTool
 */
- (void)localizableToolsEndParse:(MediaLoalizedTool *)tool;

/**
 结束写入

 @param tool MediaLoalizedTool
 */
- (void)localizableToolsEndWrite:(MediaLoalizedTool *)tool;

/**
 发生错误

 @param tool MediaLoalizedTool
 @param error NSError
 */
- (void)localizableToolsError:(MediaLoalizedTool *)tool error:(NSError *)error;

@end

@interface MediaLoalizedTool : NSObject

/**
 代理
 */
@property (nonatomic, assign) id<MediaLoalizedToolDelegate> delegate;

// 解析完成后，文件被存放的路径
@property (nonatomic, readonly) NSArray *languagePaths;

/**
 初始化
 
 @param filePath 各国语言文件路径（必须为 csv 文件）
 @param lanCount 语言数
 @return TCZLocalizableTools
 */
- (instancetype)initWithSourceFilePath:(NSString *)filePath languageCount:(NSUInteger)lanCount;

/**
 初始化
 
 @param fileName 各国语言文件名（必须为 csv 文件）
 @param lanCount 语言数
 @return TCZLocalizableTools
 */
- (instancetype)initWithSourceFileName:(NSString *)fileName languageCount:(NSUInteger)lanCount;


/**
 解析调用这个方法
 */
- (void)beginParse;


/**
 解析完成后国际化文件被保存的目录
 
 @return 根目录
 */
+ (NSString *)saveLocalizableRootFilePath;
@end
