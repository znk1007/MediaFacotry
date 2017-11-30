//
//  MediaCamera.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaCamera.h"
NSString *const MediaCameraErrorDomain = @"MediaCameraErrorDomain";

@interface UIImage (MediaCameraFixOrientation)
- (UIImage *)fixOrientation;
@end

@interface MediaCamera ()<AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate>

/**
 预览
 */
@property (strong, nonatomic) UIView *preview;

/**
 图片输出
 */
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

/**
 会话
 */
@property (strong, nonatomic) AVCaptureSession *session;

/**
 视频设备
 */
@property (strong, nonatomic) AVCaptureDevice *videoCaptureDevice;

/**
 音频设备
 */
@property (strong, nonatomic) AVCaptureDevice *audioCaptureDevice;

/**
 视频输入
 */
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;

/**
 音频输入
 */
@property (strong, nonatomic) AVCaptureDeviceInput *audioDeviceInput;

/**
 预览图层
 */
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

/**
 手势
 */
@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;

/**
 聚焦
 */
@property (strong, nonatomic) CALayer *focusBoxLayer;

/**
 聚焦动画
 */
@property (strong, nonatomic) CAAnimation *focusBoxAnimation;

/**
 视频文件输出
 */
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;

/**
 捏合手势
 */
@property (strong, nonatomic) UIPinchGestureRecognizer *pinchGesture;

/**
 开始手势缩放
 */
@property (nonatomic, assign) CGFloat beginGestureScale;

/**
 缩放系数
 */
@property (nonatomic, assign) CGFloat effectiveScale;

/**
 回调
 */
@property (nonatomic, copy) void (^didRecordCompletionBlock)(MediaCamera *camera, NSURL *outputFileUrl, NSError *error);
@end

@implementation MediaCamera

#pragma mark - Initialize

- (instancetype)init
{
    return [self initWithVideoEnabled:NO];
}

- (instancetype)initWithVideoEnabled:(BOOL)videoEnabled
{
    return [self initWithQuality:AVCaptureSessionPresetHigh position:MediaCameraPositionRear videoEnabled:videoEnabled];
}

- (instancetype)initWithQuality:(NSString *)quality position:(MediaCameraPosition)position videoEnabled:(BOOL)videoEnabled
{
    self = [super initWithNibName:nil bundle:nil];
    if(self) {
        [self setupWithQuality:quality position:position videoEnabled:videoEnabled];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupWithQuality:AVCaptureSessionPresetHigh
                      position:MediaCameraPositionRear
                  videoEnabled:YES];
    }
    return self;
}

- (void)setupWithQuality:(NSString *)quality
                position:(MediaCameraPosition)position
            videoEnabled:(BOOL)videoEnabled
{
    _cameraQuality = quality;
    _position = position;
    _fixOrientationAfterCapture = NO;
    _tapToFocus = YES;
    _useDeviceOrientation = NO;
    _flash = MediaCameraFlashOff;
    _mirror = MediaCameraMirrorAuto;
    _videoEnabled = videoEnabled;
    _recording = NO;
    _zoomingEnabled = YES;
    _effectiveScale = 1.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.autoresizingMask = UIViewAutoresizingNone;
    
    self.preview = [[UIView alloc] initWithFrame:CGRectZero];
    self.preview.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.preview];
    
    // tap to focus
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewTapped:)];
    self.tapGesture.numberOfTapsRequired = 1;
    [self.tapGesture setDelaysTouchesEnded:NO];
    [self.preview addGestureRecognizer:self.tapGesture];
    
    //pinch to zoom
    if (_zoomingEnabled) {
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        self.pinchGesture.delegate = self;
        [self.preview addGestureRecognizer:self.pinchGesture];
    }
    
    // add focus box to view
    [self addDefaultFocusBox];
}

#pragma mark Pinch Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        _beginGestureScale = _effectiveScale;
    }
    return YES;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.preview];
        CGPoint convertedLocation = [self.preview.layer convertPoint:location fromLayer:self.view.layer];
        if ( ! [self.preview.layer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer) {
        _effectiveScale = _beginGestureScale * recognizer.scale;
        if (_effectiveScale < 1.0f)
            _effectiveScale = 1.0f;
        if (_effectiveScale > self.videoCaptureDevice.activeFormat.videoMaxZoomFactor)
            _effectiveScale = self.videoCaptureDevice.activeFormat.videoMaxZoomFactor;
        NSError *error = nil;
        if ([self.videoCaptureDevice lockForConfiguration:&error]) {
            [self.videoCaptureDevice rampToVideoZoomFactor:_effectiveScale withRate:100];
            [self.videoCaptureDevice unlockForConfiguration];
        } else {
            [self passError:error];
        }
    }
}

#pragma mark - Camera

- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame
{
    [vc addChildViewController:self];
    self.view.frame = frame;
    [vc.view addSubview:self.view];
    [self didMoveToParentViewController:vc];
}

- (void)start
{
    [MediaCamera requestCameraPermission:^(BOOL granted) {
        if(granted) {
            // request microphone permission if video is enabled
            if(self.videoEnabled) {
                [MediaCamera requestMicrophonePermission:^(BOOL granted) {
                    if(granted) {
                        [self initialize];
                    }
                    else {
                        NSError *error = [NSError errorWithDomain:MediaCameraErrorDomain
                                                             code:MediaCameraErrorCodeMicrophonePermission
                                                         userInfo:nil];
                        [self passError:error];
                    }
                }];
            }
            else {
                [self initialize];
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:MediaCameraErrorDomain
                                                 code:MediaCameraErrorCodeCameraPermission
                                             userInfo:nil];
            [self passError:error];
        }
    }];
}

- (void)initialize
{
    self.saveWhenFinished = NO;
    if(!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = self.cameraQuality;
        
        // preview layer
        CGRect bounds = self.preview.layer.bounds;
        _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _captureVideoPreviewLayer.bounds = bounds;
        _captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        [self.preview.layer addSublayer:_captureVideoPreviewLayer];
        
        AVCaptureDevicePosition devicePosition;
        switch (self.position) {
            case MediaCameraPositionRear:
                if([self.class isRearCameraAvailable]) {
                    devicePosition = AVCaptureDevicePositionBack;
                } else {
                    devicePosition = AVCaptureDevicePositionFront;
                    _position = MediaCameraPositionFront;
                }
                break;
            case MediaCameraPositionFront:
                if([self.class isFrontCameraAvailable]) {
                    devicePosition = AVCaptureDevicePositionFront;
                } else {
                    devicePosition = AVCaptureDevicePositionBack;
                    _position = MediaCameraPositionRear;
                }
                break;
            default:
                devicePosition = AVCaptureDevicePositionUnspecified;
                break;
        }
        
        if(devicePosition == AVCaptureDevicePositionUnspecified) {
            self.videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        } else {
            self.videoCaptureDevice = [self cameraWithPosition:devicePosition];
        }
        
        NSError *error = nil;
        _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoCaptureDevice error:&error];
        
        if (!_videoDeviceInput) {
            [self passError:error];
            return;
        }
        
        if([self.session canAddInput:_videoDeviceInput]) {
            [self.session  addInput:_videoDeviceInput];
            self.captureVideoPreviewLayer.connection.videoOrientation = [self orientationForConnection];
        }
        
        // add audio if video is enabled
        if(self.videoEnabled) {
            _audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
            _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_audioCaptureDevice error:&error];
            if (!_audioDeviceInput) {
                [self passError:error];
            }
            
            if([self.session canAddInput:_audioDeviceInput]) {
                [self.session addInput:_audioDeviceInput];
            }
            
            _movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
            [_movieFileOutput setMovieFragmentInterval:kCMTimeInvalid];
            if([self.session canAddOutput:_movieFileOutput]) {
                [self.session addOutput:_movieFileOutput];
            }
        }
        
        // continiously adjust white balance
        self.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        
        // image output
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [self.session addOutput:self.stillImageOutput];
    }
    
    //if we had disabled the connection on capture, re-enable it
    if (![self.captureVideoPreviewLayer.connection isEnabled]) {
        [self.captureVideoPreviewLayer.connection setEnabled:YES];
    }
    
    [self.session startRunning];
}

- (void)stop
{
    [self.session stopRunning];
    self.session = nil;
}


#pragma mark - Image Capture

-(void)capture:(void (^)(MediaCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage animationBlock:(void (^)(AVCaptureVideoPreviewLayer *))animationBlock
{
    if(!self.session) {
        NSError *error = [NSError errorWithDomain:MediaCameraErrorDomain
                                             code:MediaCameraErrorCodeSession
                                         userInfo:nil];
        onCapture(self, nil, nil, error);
        return;
    }
    
    // get connection and set orientation
    AVCaptureConnection *videoConnection = [self captureConnection];
    videoConnection.videoOrientation = [self orientationForConnection];
    
    BOOL flashActive = self.videoCaptureDevice.flashActive;
    if (!flashActive && animationBlock) {
        animationBlock(self.captureVideoPreviewLayer);
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        UIImage *image = nil;
        NSDictionary *metadata = nil;
        
        // check if we got the image buffer
        if (imageSampleBuffer != NULL) {
            CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
            if(exifAttachments) {
                metadata = (__bridge NSDictionary*)exifAttachments;
            }
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            image = [[UIImage alloc] initWithData:imageData];
            
            if(exactSeenImage) {
                image = [self cropImage:image usingPreviewLayer:self.captureVideoPreviewLayer];
            }
            
            if(self.fixOrientationAfterCapture) {
                image = [image fixOrientation];
            }
        }
        
        // trigger the block
        if(onCapture) {
            dispatch_async(dispatch_get_main_queue(), ^{
                onCapture(self, image, metadata, error);
            });
        }
    }];
}

-(void)capture:(void (^)(MediaCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage {
    
    [self capture:onCapture exactSeenImage:exactSeenImage animationBlock:^(AVCaptureVideoPreviewLayer *layer) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.duration = 0.1;
        animation.autoreverses = YES;
        animation.repeatCount = 0.0;
        animation.fromValue = [NSNumber numberWithFloat:1.0];
        animation.toValue = [NSNumber numberWithFloat:0.1];
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
        [layer addAnimation:animation forKey:@"animateOpacity"];
    }];
}

-(void)capture:(void (^)(MediaCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture
{
    [self capture:onCapture exactSeenImage:NO];
}

#pragma mark - Video Capture

- (void)startRecordingWithOutputUrl:(NSURL *)url didRecord:(void (^)(MediaCamera *camera, NSURL *outputFileUrl, NSError *error))completionBlock
{
    // check if video is enabled
    if(!self.videoEnabled) {
        NSError *error = [NSError errorWithDomain:MediaCameraErrorDomain
                                             code:MediaCameraErrorCodeVideoNotEnabled
                                         userInfo:nil];
        [self passError:error];
        return;
    }
    
    if(self.flash == MediaCameraFlashOn) {
        [self enableTorch:YES];
    }
    
    // set video orientation
    for(AVCaptureConnection *connection in [self.movieFileOutput connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            // get only the video media types
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                if ([connection isVideoOrientationSupported]) {
                    [connection setVideoOrientation:[self orientationForConnection]];
                }
            }
        }
    }
    
    self.didRecordCompletionBlock = completionBlock;
    
    [self.movieFileOutput startRecordingToOutputFileURL:url recordingDelegate:self];
}

- (void)stopRecording
{
    if(!self.videoEnabled) {
        return;
    }
    
    [self.movieFileOutput stopRecording];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    self.recording = YES;
    if(self.onStartRecording) self.onStartRecording(self);
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    self.recording = NO;
    [self enableTorch:NO];
    
    if(self.didRecordCompletionBlock) {
        self.didRecordCompletionBlock(self, outputFileURL, error);
    }
    if (self.saveWhenFinished) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.absoluteString)) {
            NSLog(@"可以保存到相册");
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.absoluteString, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
        }
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    NSLog(@"%@",videoPath);
    
    NSLog(@"%@",error);
    
}

- (void)enableTorch:(BOOL)enabled
{
    // check if the device has a torch, otherwise don't do anything
    if([self isTorchAvailable]) {
        AVCaptureTorchMode torchMode = enabled ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
        NSError *error;
        if ([self.videoCaptureDevice lockForConfiguration:&error]) {
            [self.videoCaptureDevice setTorchMode:torchMode];
            [self.videoCaptureDevice unlockForConfiguration];
        } else {
            [self passError:error];
        }
    }
}

#pragma mark - Helpers

- (void)passError:(NSError *)error
{
    if(self.onError) {
        __weak typeof(self) weakSelf = self;
        self.onError(weakSelf, error);
    }
}

- (AVCaptureConnection *)captureConnection
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    
    return videoConnection;
}

- (void)setVideoCaptureDevice:(AVCaptureDevice *)videoCaptureDevice
{
    _videoCaptureDevice = videoCaptureDevice;
    
    if(videoCaptureDevice.flashMode == AVCaptureFlashModeAuto) {
        _flash = MediaCameraFlashAuto;
    } else if(videoCaptureDevice.flashMode == AVCaptureFlashModeOn) {
        _flash = MediaCameraFlashOn;
    } else if(videoCaptureDevice.flashMode == AVCaptureFlashModeOff) {
        _flash = MediaCameraFlashOff;
    } else {
        _flash = MediaCameraFlashOff;
    }
    
    _effectiveScale = 1.0f;
    
    // trigger block
    if(self.onDeviceChange) {
        __weak typeof(self) weakSelf = self;
        self.onDeviceChange(weakSelf, videoCaptureDevice);
    }
}

- (BOOL)isFlashAvailable
{
    return self.videoCaptureDevice.hasFlash && self.videoCaptureDevice.isFlashAvailable;
}

- (BOOL)isTorchAvailable
{
    return self.videoCaptureDevice.hasTorch && self.videoCaptureDevice.isTorchAvailable;
}

- (BOOL)updateFlashMode:(MediaCameraFlash)cameraFlash
{
    if(!self.session)
        return NO;
    
    AVCaptureFlashMode flashMode;
    
    if(cameraFlash == MediaCameraFlashOn) {
        flashMode = AVCaptureFlashModeOn;
    } else if(cameraFlash == MediaCameraFlashAuto) {
        flashMode = AVCaptureFlashModeAuto;
    } else {
        flashMode = AVCaptureFlashModeOff;
    }
    
    if([self.videoCaptureDevice isFlashModeSupported:flashMode]) {
        NSError *error;
        if([self.videoCaptureDevice lockForConfiguration:&error]) {
            self.videoCaptureDevice.flashMode = flashMode;
            [self.videoCaptureDevice unlockForConfiguration];
            
            _flash = cameraFlash;
            return YES;
        } else {
            [self passError:error];
            return NO;
        }
    }
    else {
        return NO;
    }
}

- (void)setWhiteBalanceMode:(AVCaptureWhiteBalanceMode)whiteBalanceMode
{
    if ([self.videoCaptureDevice isWhiteBalanceModeSupported:whiteBalanceMode]) {
        NSError *error;
        if ([self.videoCaptureDevice lockForConfiguration:&error]) {
            [self.videoCaptureDevice setWhiteBalanceMode:whiteBalanceMode];
            [self.videoCaptureDevice unlockForConfiguration];
        } else {
            [self passError:error];
        }
    }
}

- (void)setMirror:(MediaCameraMirror)mirror
{
    _mirror = mirror;
    
    if(!self.session) {
        return;
    }
    
    AVCaptureConnection *videoConnection = [_movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    AVCaptureConnection *pictureConnection = [_stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    switch (mirror) {
        case MediaCameraMirrorOff: {
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:NO];
            }
            
            if ([pictureConnection isVideoMirroringSupported]) {
                [pictureConnection setVideoMirrored:NO];
            }
            break;
        }
            
        case MediaCameraMirrorOn: {
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:YES];
            }
            
            if ([pictureConnection isVideoMirroringSupported]) {
                [pictureConnection setVideoMirrored:YES];
            }
            break;
        }
            
        case MediaCameraMirrorAuto: {
            BOOL shouldMirror = (_position == MediaCameraPositionFront);
            if ([videoConnection isVideoMirroringSupported]) {
                [videoConnection setVideoMirrored:shouldMirror];
            }
            
            if ([pictureConnection isVideoMirroringSupported]) {
                [pictureConnection setVideoMirrored:shouldMirror];
            }
            break;
        }
    }
    
    return;
}

- (MediaCameraPosition)togglePosition
{
    if(!self.session) {
        return self.position;
    }
    
    if(self.position == MediaCameraPositionRear) {
        self.cameraPosition = MediaCameraPositionFront;
    } else {
        self.cameraPosition = MediaCameraPositionRear;
    }
    
    return self.position;
}

- (void)setCameraPosition:(MediaCameraPosition)cameraPosition
{
    if(_position == cameraPosition || !self.session) {
        return;
    }
    
    if(cameraPosition == MediaCameraPositionRear && ![self.class isRearCameraAvailable]) {
        return;
    }
    
    if(cameraPosition == MediaCameraPositionFront && ![self.class isFrontCameraAvailable]) {
        return;
    }
    
    [self.session beginConfiguration];
    
    // remove existing input
    [self.session removeInput:self.videoDeviceInput];
    
    // get new input
    AVCaptureDevice *device = nil;
    if(self.videoDeviceInput.device.position == AVCaptureDevicePositionBack) {
        device = [self cameraWithPosition:AVCaptureDevicePositionFront];
    } else {
        device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    
    if(!device) {
        return;
    }
    
    // add input to session
    NSError *error = nil;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if(error) {
        [self passError:error];
        [self.session commitConfiguration];
        return;
    }
    
    _position = cameraPosition;
    
    [self.session addInput:videoInput];
    [self.session commitConfiguration];
    
    self.videoCaptureDevice = device;
    self.videoDeviceInput = videoInput;
    
    [self setMirror:_mirror];
}


// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) return device;
    }
    return nil;
}

#pragma mark - Focus

- (void)previewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if(!self.tapToFocus) {
        return;
    }
    
    CGPoint touchedPoint = [gestureRecognizer locationInView:self.preview];
    CGPoint pointOfInterest = [self convertToPointOfInterestFromViewCoordinates:touchedPoint
                                                                   previewLayer:self.captureVideoPreviewLayer
                                                                          ports:self.videoDeviceInput.ports];
    [self focusAtPoint:pointOfInterest];
    [self showFocusBox:touchedPoint];
}

- (void)addDefaultFocusBox
{
    CALayer *focusBox = [[CALayer alloc] init];
    focusBox.cornerRadius = 5.0f;
    focusBox.bounds = CGRectMake(0.0f, 0.0f, 70, 60);
    focusBox.borderWidth = 3.0f;
    focusBox.borderColor = [[UIColor yellowColor] CGColor];
    focusBox.opacity = 0.0f;
    [self.view.layer addSublayer:focusBox];
    
    CABasicAnimation *focusBoxAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    focusBoxAnimation.duration = 0.75;
    focusBoxAnimation.autoreverses = NO;
    focusBoxAnimation.repeatCount = 0.0;
    focusBoxAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    focusBoxAnimation.toValue = [NSNumber numberWithFloat:0.0];
    
    [self alterFocusBox:focusBox animation:focusBoxAnimation];
}

- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation
{
    self.focusBoxLayer = layer;
    self.focusBoxAnimation = animation;
}

- (void)focusAtPoint:(CGPoint)point
{
    AVCaptureDevice *device = self.videoCaptureDevice;
    if (device.isFocusPointOfInterestSupported && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        } else {
            [self passError:error];
        }
    }
}

- (void)showFocusBox:(CGPoint)point
{
    if(self.focusBoxLayer) {
        // clear animations
        [self.focusBoxLayer removeAllAnimations];
        
        // move layer to the touch point
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        self.focusBoxLayer.position = point;
        [CATransaction commit];
    }
    
    if(self.focusBoxAnimation) {
        // run the animation
        [self.focusBoxLayer addAnimation:self.focusBoxAnimation forKey:@"animateOpacity"];
    }
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.preview.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    
    CGRect bounds = self.preview.bounds;
    self.captureVideoPreviewLayer.bounds = bounds;
    self.captureVideoPreviewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    self.captureVideoPreviewLayer.connection.videoOrientation = [self orientationForConnection];
}

- (AVCaptureVideoOrientation)orientationForConnection
{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    
    if(self.useDeviceOrientation) {
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationLandscapeLeft:
                // yes to the right, this is not bug!
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    else {
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationLandscapeLeft:
                videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIInterfaceOrientationLandscapeRight:
                videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            default:
                videoOrientation = AVCaptureVideoOrientationPortrait;
                break;
        }
    }
    
    return videoOrientation;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // layout subviews is not called when rotating from landscape right/left to left/right
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.view setNeedsLayout];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self stop];
}

#pragma mark - Class Methods

+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock
{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    } else {
        completionBlock(YES);
    }
}

+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock
{
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            // return to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if(completionBlock) {
                    completionBlock(granted);
                }
            });
        }];
    }
}

+ (BOOL)isFrontCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (BOOL)isRearCameraAvailable
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = previewLayer.frame.size;
    
    if ( [previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize] ) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in ports) {
            if (port.mediaType == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([previewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (UIImage *)cropImage:(UIImage *)image usingPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
{
    CGRect previewBounds = previewLayer.bounds;
    CGRect outputRect = [previewLayer metadataOutputRectOfInterestForRect:previewBounds];
    
    CGImageRef takenCGImage = image.CGImage;
    size_t width = CGImageGetWidth(takenCGImage);
    size_t height = CGImageGetHeight(takenCGImage);
    CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height,
                                 outputRect.size.width * width, outputRect.size.height * height);
    
    CGImageRef cropCGImage = CGImageCreateWithImageInRect(takenCGImage, cropRect);
    image = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:image.imageOrientation];
    CGImageRelease(cropCGImage);
    
    return image;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
