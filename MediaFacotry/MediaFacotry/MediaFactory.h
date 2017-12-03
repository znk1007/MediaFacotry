//
//  MediaFactory.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

@import UIKit;

@class MediaPhotoActionSheet;

typedef void(^MediaPickProgressCompletion)(BOOL finished, BOOL hideAfter, float progress, NSString * _Nullable errorDesc);

@interface MediaFactory : NSObject
/**
 MediaFactory单例
 
 @return MediaFactory
 */
+ (MediaFactory *_Nonnull)sharedFactory;

#pragma mark - 相册模块
/**
 选取结果，如uploadImmediately为YES，则MediaPickProgressCompletion不为nil
 */
@property (nonatomic, copy) void(^ _Nullable MediaPickCompletion)(NSArray<UIImage *> * _Nullable image, NSArray<NSString *> * _Nullable filePaths, int mediaLength, MediaPickProgressCompletion _Nullable progress);

/**
 显示相册

 @param target 容器控制器
 @param preview 是否预览
 @param animate 动画
 @param uploadImmediately 是否立即上传
 */
- (void)showLibraryWithTargetViewController:(UIViewController * _Nonnull)target needPreview:(BOOL)preview animate:(BOOL)animate uploadImmediately:(BOOL)uploadImmediately;

@end
