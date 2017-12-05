//
//  MediaFactory.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

@import UIKit;

/**
 进度block
 
 @param finished 完成
 @param hideAfter 是否隐藏
 @param progress 进度
 @param errorDesc 错误描述
 */
typedef void(^MediaPickProgressCompletion)(BOOL finished, BOOL hideAfter, float progress, NSString * _Nullable errorDesc);

@class MediaPhotoActionSheet;

@interface MediaFactory : NSObject
/**
 MediaFactory单例
 
 @return MediaFactory
 */
+ (MediaFactory *_Nonnull)sharedFactory;

#pragma mark - 相册模块

/**
 显示相册

 @param target 容器控制器
 @param preview 是否预览
 @param animate 动画
 @param imageOnly 只选图片
 @param limitCount 选择图片限制
 @param editImmedately 选择后立即编辑，仅当limitCount=1时
 @param useCustomCamera 自定义相机
 @param uploadImmediately 立即上传
 @param completion 完成block
 */
- (void)showLibraryWithTargetViewController:(UIViewController * _Nonnull)target needPreview:(BOOL)preview animate:(BOOL)animate showImageOnly:(BOOL)imageOnly limitCount:(NSInteger)limitCount editImmedately:(BOOL)editImmedately useCustomCamera:(BOOL)useCustomCamera uploadImmediately:(BOOL)uploadImmediately mediaPickCompletion:(void(^_Nullable)(NSArray<UIImage *> * _Nullable image, NSArray<NSString *> * _Nullable filePaths, NSArray <NSString *> * _Nullable mediaLength, MediaPickProgressCompletion _Nullable progress))completion;

@end
