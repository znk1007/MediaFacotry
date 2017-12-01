//
//  MediaCamera.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const MediaCameraErrorDomain;

@interface MediaCamera : UIViewController
/**
 * Triggered on device change.
 */
@property (nonatomic, copy) void (^onDeviceChange)(MediaCamera *camera, AVCaptureDevice *device);

/**
 * Triggered on any kind of error.
 */
@property (nonatomic, copy) void (^onError)(MediaCamera *camera, NSError *error);

/**
 * Triggered when camera starts recording
 */
@property (nonatomic, copy) void (^onStartRecording)(MediaCamera* camera);

/**
 * Camera quality, set a constants prefixed with AVCaptureSessionPreset.
 * Make sure to caMine before caMineing -(void)initialize method, otherwise it would be late.
 */
@property (copy, nonatomic) NSString *cameraQuality;

/**
 * Camera flash mode.
 */
@property (nonatomic, readonly) MediaCameraFlash flash;

/**
 * Camera mirror mode.
 */
@property (nonatomic) MediaCameraMirror mirror;

/**
 * Position of the camera.
 */
@property (nonatomic) MediaCameraPosition position;

/**
 * White balance mode. Default is: AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
 */
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;

/**
 * Boolean value to indicate if the video is enabled.
 */
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/**
 * Boolean value to indicate if the camera is recording a video at the current moment.
 */
@property (nonatomic, getter=isRecording) BOOL recording;
/**save to album when finished*/
@property (nonatomic, setter=setSaveWhenFinished:) BOOL saveWhenFinished;
/**
 * Boolean value to indicate if zooming is enabled.
 */
@property (nonatomic, getter=isZoomingEnabled) BOOL zoomingEnabled;

/**
 * Float value to set maximum scaling factor
 */
@property (nonatomic, assign) CGFloat maxScale;

/**
 * Fixess the orientation after the image is captured is set to Yes.
 * see: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroMineer-result-image-orientation-after-upload
 */
@property (nonatomic) BOOL fixOrientationAfterCapture;

/**
 * Set NO if you don't want ot enable user triggered focusing. Enabled by default.
 */
@property (nonatomic) BOOL tapToFocus;

/**
 * Set YES if you your view controMineer does not aMineow autorotation,
 * however you want to take the device rotation into account no matter what. Disabled by default.
 */
@property (nonatomic) BOOL useDeviceOrientation;

/**
 * Use this method to request camera permission before initalizing MediaCamera.
 */
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock;

/**
 * Use this method to request microphone permission before initalizing MediaCamera.
 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock;

/**
 * 返回与给定效果的MediaCamera实例。
 *质量参数可以是任何变量从AVCaptureSessionPreset获取。
 */
- (instancetype)initWithQuality:(NSString *)quality position:(MediaCameraPosition)position videoEnabled:(BOOL)videoEnabled;

/**
 * 返回一个实例MediaCamera，默认”AVCaptureSessionPresetHigh，位置：CameraPositionBack”。
 */
- (instancetype)initWithVideoEnabled:(BOOL)videoEnabled;

/**
 * 开始运行摄像机会话。
 */
- (void)start;

/**
 * 停止正在运行的摄像机会话。
 */
- (void)stop;


/**
 * 捕捉图像。
 */
-(void)capture:(void (^)(MediaCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage animationBlock:(void (^)(AVCaptureVideoPreviewLayer *))animationBlock;

/**
 * 捕捉图像。
 */
-(void)capture:(void (^)(MediaCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage;

/**
 * 捕捉图像。
 */
-(void)capture:(void (^)(MediaCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture;

/*
 * 开始录制带有完整块的视频。将视频保存到给定URL。
 */
- (void)startRecordingWithOutputUrl:(NSURL *)url didRecord:(void (^)(MediaCamera *camera, NSURL *outputFileUrl, NSError *error))completionBlock;

/**
 * 停止录制视频。
 */
- (void)stopRecording;

/**
 * 控制器间关联
 */
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame;

/**
 * 改变相机的位置（或前面或后面）并返回最终的位置。
 */
- (MediaCameraPosition)togglePosition;

/**
 * 更新相机的闪光灯模式。如果成功，则返回true。否则为false。
 */
- (BOOL)updateFlashMode:(MediaCameraFlash)cameraFlash;

/**
 * 检查如果Flash视频是否可用
 */
- (BOOL)isFlashAvailable;

/**
 * 检查如果Torch是否可用。
 */
- (BOOL)isTorchAvailable;

/**
 * 当用户点击屏幕时，更改图层和动画显示。
 */
- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;

/**
 * 前置摄像头是否可用
 */
+ (BOOL)isFrontCameraAvailable;

/**
 * 后置摄像头是否可用
 */
+ (BOOL)isRearCameraAvailable;
/**
 *聚焦
 */
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports;
/**
 *裁剪图片
 */
- (UIImage *)cropImage:(UIImage *)image usingPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;
@end
