//
//  EnumHeader.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#ifndef EnumHeader_h
#define EnumHeader_h
/**媒体资源类型*/
typedef enum {
    MediaAssetTypeUnkown,
    MediaAssetTypeImage,
    MediaAssetTypeGif,
    MediaAssetTypeLivePhoto,
    MediaAssetTypeVideo,
    MediaAssetTypeAudio,
    MediaAssetTypeNetImage,
}MediaAssetType;

/**视频导出类型*/
typedef enum {
    MediaVideoExportTypeMOV,
    MediaVideoExportTypeMP4,
    MediaVideoExportType3GP,
}MediaVideoExportType;

/**拍照预设*/
typedef enum {
    MediaCaptureSessionPreset325x288,
    MediaCaptureSessionPreset640x480,
    MediaCaptureSessionPreset1280x720,
    MediaCaptureSessionPreset1920x1080,
    MediaCaptureSessionPreset3840x2160,
}MediaCaptureSessionPreset;

/**文字闪烁*/
typedef enum : NSUInteger {
    MediaLeftToRight,         // 从左到右
    MediaRightToLeft,         // 从右到左
    MediaAutoReverse,         // 左右来回
    MediaShimmerAll,          // 整体闪烁
} ShimmerType;              // 闪烁类型

/**自定义相机*/
typedef enum : NSUInteger {
    MediaCameraPositionRear,
    MediaCameraPositionFront
} MediaCameraPosition;
/**自定义相机*/
typedef enum : NSUInteger {
    // The default state has to be off
    MediaCameraFlashOff,
    MediaCameraFlashOn,
    MediaCameraFlashAuto
} MediaCameraFlash;
/**自定义相机*/
typedef enum : NSUInteger {
    // The default state has to be off
    MediaCameraMirrorOff,
    MediaCameraMirrorOn,
    MediaCameraMirrorAuto
} MediaCameraMirror;
/**自定义相机*/
typedef enum : NSUInteger {
    MediaCameraErrorCodeCameraPermission = 10,
    MediaCameraErrorCodeMicrophonePermission = 11,
    MediaCameraErrorCodeSession = 12,
    MediaCameraErrorCodeVideoNotEnabled = 13
} MediaCameraErrorCode;

/**录制按钮*/
typedef enum {
    MediaRecordButtonStateBegin = 0,// 开始长按
    MediaRecordButtonStateMoving, // 移动
    MediaRecordButtonStateWillCancel,// 将要取消
    MediaRecordButtonStateDidCancel,// 已经取消
    MediaRecordButtonStateEnd, // 正常结束
    MediaRecordButtonStateTimeout,//超时
    MediaRecordButtonStateSingleTap,//单击
}MediaRecordButtonState;

#endif /* EnumHeader_h */
