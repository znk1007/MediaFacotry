//
//  MediaTool.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaModel.h"

@import Photos;
@import AVFoundation;

/**
 回传信息

 @param success MediaFactoryPickCompletion 事件操作是否成功
 @param hide 是否隐藏相应的视图或者控制器
 @param progress 事件完成进度
 @param desc 事件描述
 */
typedef void(^MediaFactoryTransferCompletion)(BOOL success, BOOL hide, CGFloat progress, NSString * _Nullable desc);

@interface MediaTool : NSObject

/**
 相册容器控制器
 */
@property (nonatomic, strong) UIViewController * _Nonnull targetController;

/**
 获取媒体数据
 */
@property (nonatomic, copy) void(^ _Nullable MediaFactoryPickCompletion)(NSArray<UIImage *> * _Nullable images, NSArray <NSString *> * _Nullable filePaths,int fileLength, MediaFactoryTransferCompletion _Nullable transferCompletion);

/**
 最大选择数 默认9张
 */
@property (nonatomic, assign) NSInteger maxSelectCount;

/**
 预览图最大显示数 默认20张
 */
@property (nonatomic, assign) NSInteger maxPreviewCount;

/**
 是否允许混合选择，即可以同时选择image(image/gif/livephoto)、video类型
 */
@property (nonatomic, assign) BOOL allowMixSelect;

/**
 是否允许选择照片 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectImage;

/**
 是否允许选择视频 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectVideo;

/**
 是否允许选择Gif 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectGif;

/**
 是否允许选择Live Photo，默认NO
 */
@property (nonatomic, assign) BOOL allowSelectLivePhoto;

/**
 是否允许相册内部拍照 默认YES
 */
@property (nonatomic, assign) BOOL allowTakePhotoInLibrary;

/**
 是否Force Touch 功能 默认YES
 */
@property (nonatomic, assign) BOOL allowForceTouch;

/**
 是否允许编辑图片，选择一张时候才允许编辑，默认YES
 */
@property (nonatomic, assign) BOOL allowEditImage;

/**
 是否允许编辑视频，选择一张时候才允许编辑，默认NO，编辑视频
 */
@property (nonatomic, assign) BOOL allowEditVideo;

/**
 是否允许选择原图，默认YES
 */
@property (nonatomic, assign) BOOL allowSelectOriginal;

/**
 编辑视频时最大裁剪时间，单位：秒，默认10s
 
 @discussion 当该参数为10s时，所选视频时长必须大于等于10s才允许进行编辑
 */
@property (nonatomic, assign) NSInteger maxEditVideoTime;

/**
 允许选择视频的最大时长，单位：秒， 默认 120s
 */
@property (nonatomic, assign) NSInteger maxVideoDuration;

/**
 是否允许滑动选择 默认 YES
 */
@property (nonatomic, assign) BOOL allowSlideSelect;

/**
 预览界面是否允许拖拽选择 默认 NO
 */
@property (nonatomic, assign) BOOL allowDragSelect;

/**
 在小图界面选择图片后直接进入编辑界面，默认NO， 仅在allowEditImage为YES且maxSelectCount为1 的情况下，置为YES有效
 */
@property (nonatomic, assign) BOOL editAfterSelectThumbnailImage;

/**
 是否在相册内部拍照按钮上面实时显示相机俘获的影像 默认 YES
 */
@property (nonatomic, assign) BOOL showCaptureImageOnTakePhotoBtn;

/**
 是否升序排列，预览界面不受该参数影响，默认升序 YES
 */
@property (nonatomic, assign) BOOL sortAscending;

/**
 控制单选模式下，是否显示选择按钮，默认 NO，多选模式不受控制
 */
@property (nonatomic, assign) BOOL showSelectBtn;

/**
 是否在已选择的图片上方覆盖一层已选中遮罩层，默认 NO
 */
@property (nonatomic, assign) BOOL showSelectedMask;

/**
 回调时候是否允许框架解析图片，默认YES
 
 如果选择了大量图片，框架一下解析大量图片会耗费一些内存，开发者此时可置为NO，拿到assets数组后自行解析，该值为NO时，回调的图片数组为nil
 */
@property (nonatomic, assign) BOOL shouldAnialysisAsset;

/**
 是否选择了原图
 */
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

/**
 已选的model
 */
@property (nonatomic, copy) NSMutableArray<MediaModel *> * _Nullable arrSelectedModels;

/**
 点击确定选择照片回调
 */
@property (nonatomic, copy) void (^ _Nullable callSelectImageBlock)(void);

/**
 编辑图片后回调
 */
@property (nonatomic, copy) void (^ _Nullable callSelectClipImageBlock)(UIImage *_Nullable editedImage, PHAsset *_Nullable editedPHAsset);

/**
 取消block
 */
@property (nonatomic, copy) void (^ _Nullable cancelBlock)(void);

/**
 相册是否授权
 */
@property (nonatomic, readonly) BOOL photoAlbumAuthorized;

/**
 相机是否可用
 */
@property (nonatomic, readonly) BOOL cameraAvailable;

/**
 使用自定义相机 默认NO
 */
@property (nonatomic, assign) BOOL useCustomCamera;

/**
 是否允许录制视频(当useCustomCamera为NO时无效)，默认YES
 */
@property (nonatomic, assign) BOOL allowRecordVideo;

/**
 最大录制时长 最小3s，默认8s
 */
@property (nonatomic, assign) NSInteger maxRecordDuration;

/**
 相机是否授权
 */
@property (nonatomic, readonly) BOOL cameraAuthorized;

/**
 视频导出类型 默认MediaVideoExportTypeMP4
 */
@property (nonatomic, assign) MediaVideoExportType exportType;

/**
 拍照预设 默认MediaCaptureSessionPreset640x480
 */
@property (nonatomic, assign) MediaCaptureSessionPreset sessionPreset;

/**
 监测相册权限变化
 */
- (void)watchAlbumAuthorizeChange:(void(^_Nullable)(void))change;

/**
 获取时长
 
 @param duration 时长
 @return NSInteger
 */
- (NSInteger)getDuration:(NSString *_Nullable)duration;

/**
 视图动画
 
 @return CAKeyframeAnimation
 */
- (CAKeyframeAnimation *_Nullable)viewStatusChangedAnimation;


/**
 视图动画from to

 @param from 起始
 @param to 结束
 @param duration 时长
 @param path 路径
 @return CABasicAnimation
 */
- (CABasicAnimation * _Nullable)viewPositionAnimationFrom:(id _Nullable )from toValue:(id _Nullable )to animationDuration:(CFTimeInterval)duration keyPath:(NSString *_Nullable)path;

@end
