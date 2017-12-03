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
 选取结果，如uploadImmediately为YES，MediaPickProgressCompletion可用
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

/**
 显示相册

 @param target 容器控制器
 @param preview 是否预览
 @param animate 动画
 @param imageOnly 只选图片
 @param limitCount 选择图片限制
 @param useCustomStyle 自定义样式
 @param useCustomCamera 自定义相机
 @param uploadImmediately 立即上传
 @param completion 完成block
 */
- (void)showLibraryWithTargetViewController:(UIViewController * _Nonnull)target needPreview:(BOOL)preview animate:(BOOL)animate showImageOnly:(BOOL)imageOnly limitCount:(NSInteger)limitCount useCustomStyle:(BOOL)useCustomStyle useCustomCamera:(BOOL)useCustomCamera uploadImmediately:(BOOL)uploadImmediately mediaPickCompletion:(void(^_Nullable)(NSArray<UIImage *> * _Nullable image, NSArray<NSString *> * _Nullable filePaths, int mediaLength, MediaPickProgressCompletion _Nullable progress))completion;

@end
