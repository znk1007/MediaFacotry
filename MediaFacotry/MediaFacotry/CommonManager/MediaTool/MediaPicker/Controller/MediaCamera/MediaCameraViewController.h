//
//  MediaCameraViewController.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MediaCameraViewController : UIViewController
@property (nonatomic, assign) CFTimeInterval maxRecordTime;

//是否允许录制视频
@property (nonatomic, assign) BOOL allowRecordVideo;

//最大录制时长
@property (nonatomic, assign) NSInteger maxRecordDuration;

@property (nonatomic, assign) MediaCaptureSessionPreset sessionPreset;

@property (nonatomic, assign) MediaVideoExportType videoType;

//录制视频时候进度条颜色
@property (nonatomic, strong) UIColor *circleProgressColor;

/**
 确定回调，如果拍照则videoUrl为nil，如果视频则image为nil
 */
@property (nonatomic, copy) void (^doneBlock)(UIImage *image, NSURL *videoUrl);
@end
