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

#endif /* EnumHeader_h */
