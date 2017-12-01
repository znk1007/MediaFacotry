//
//  MeidaGIFImageView.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/29.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaGIFImageView.h"

@import MobileCoreServices;
@import ImageIO;
@import QuartzCore;

#ifndef FLT_EPSILON
#define FLT_EPSILON __FLT_EPSILON__
#endif

#pragma mark - inline method

/**
 获取gif图片每一帧时延

 @param imageSource 图片资源
 @param index 帧下标
 @return 时延
 */
static inline NSTimeInterval cgImageSourceGetGifFrameByDelay(CGImageSourceRef imageSource, NSUInteger index){
    NSTimeInterval frameDuration = 0;
    CFDictionaryRef theImageProperties;
    if ((theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL))) {
        CFDictionaryRef gifProperties;
        if (CFDictionaryGetValueIfPresent(theImageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties)) {
            const void *frameDurationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &frameDurationValue)) {
                frameDuration = [(__bridge NSNumber *)frameDurationValue doubleValue];
                if (frameDuration <= 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &frameDurationValue)) {
                        frameDuration = [((__bridge NSNumber *)frameDurationValue) doubleValue];
                    }
                }
            }
        }
        CFRelease(theImageProperties);
    }
#ifndef OLExactGIFRepresentation
    if (frameDuration < 0.02 - FLT_EPSILON) {
        frameDuration = 0.1;
    }
#endif
    return frameDuration;
}

/**
 检查图片资源是否包好gif动图

 @param imageSource 图片资源
 @return BOOL
 */
static inline BOOL cgImageSourceContainsAnimatedGif(CGImageSourceRef imageSource){
    return imageSource && UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF) && CGImageSourceGetCount(imageSource) > 1;
}

/**
 路径下的资源文件是否符合2倍图

 @param path 资源路径
 @return BOOL
 */
static inline BOOL is2xRetinaFilePath(NSString *path){
    NSRange retinaSuffixRange = [[path lastPathComponent] rangeOfString:@"@2x" options:NSCaseInsensitiveSearch];
    return retinaSuffixRange.length && retinaSuffixRange.location != NSNotFound;
}
/**
 路径下的资源文件是否符合3倍图
 
 @param path 资源路径
 @return BOOL
 */
static inline BOOL is3xRetinaFilePath(NSString *path){
    NSRange retinaSuffixRange = [[path lastPathComponent] rangeOfString:@"@3x" options:NSCaseInsensitiveSearch];
    return retinaSuffixRange.length && retinaSuffixRange.location != NSNotFound;
}

@interface MediaGIFImage()

/**
 git帧图片集合
 */
@property (nonatomic, readwrite) NSMutableArray *images;

/**
 每一帧时长
 */
@property (nonatomic, readwrite) NSTimeInterval *frameDurations;

/**
 总时长
 */
@property (nonatomic, readwrite) NSTimeInterval totalDuration;

/**
 循环次数
 */
@property (nonatomic, readwrite) NSUInteger loopCount;

/**
 递增资源
 */
@property (nonatomic, readwrite) CGImageSourceRef incrementalSource;

@end
/**预取数*/
static NSUInteger _prefetchedNum = 10;

@implementation MediaGIFImage
{
    dispatch_queue_t readFrameQueue;
    CGImageSourceRef _imageSourceRef;
    CGFloat _scale;
}
@synthesize images = _images;

#pragma mark - 重写UIImage部分方法 start

+ (UIImage *)imageNamed:(NSString *)name{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    return ([[NSFileManager defaultManager] fileExistsAtPath:path]) ? [self imageWithContentsOfFile:path] : nil;
}

+ (UIImage *)imageWithContentsOfFile:(NSString *)path{
    CGFloat scale = is3xRetinaFilePath(path) ? 3.0f : is2xRetinaFilePath(path) ? 2.0f : 1.0f;
    return [self imageWithData:[NSData dataWithContentsOfFile:path] scale:scale];
}

+ (UIImage *)imageWithData:(NSData *)data{
    return [self imageWithData:data scale:1.0f];
}

+ (UIImage *)imageWithData:(NSData *)data scale:(CGFloat)scale{
    if (!data) {
        return NULL;
    }
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    UIImage *image;
    
    if (cgImageSourceContainsAnimatedGif(imageSource)) {
        image = [[self alloc] initWithCGImageSource:imageSource scale:scale];
    }else{
        image = [super imageWithData:data scale:scale];
    }
    if (imageSource) {
        CFRelease(imageSource);
    }
    return image;
}

- (instancetype)initWithContentsOfFile:(NSString *)path{
    CGFloat scale = is3xRetinaFilePath(path) ? 3.0f : is2xRetinaFilePath(path) ? 2.0f : 1.0f;
    return [self initWithData:[NSData dataWithContentsOfFile:path] scale:scale];
}

- (instancetype)initWithData:(NSData *)data{
    return [self initWithData:data scale:1.0f];
}

- (instancetype)initWithData:(NSData *)data scale:(CGFloat)scale{
    if (!data) {
        return NULL;
    }
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
    if (cgImageSourceContainsAnimatedGif(imageSource)) {
        self = [self initWithCGImageSource:imageSource scale:scale];
    }else{
        if (scale == 1.0f) {
            self = [super initWithData:data];
        }else{
            self = [super initWithData:data scale:scale];
        }
    }
    if (imageSource) {
        CFRelease(imageSource);
    }
    return self;
}

- (CGSize)size{
    if (self.images.count) {
        return [(UIImage *)[self.images objectAtIndex:0] size];
    }
    return [super size];
}

- (CGImageRef)CGImage{
    if (self.images.count) {
        return [(UIImage *)[self.images objectAtIndex:0] CGImage];
    } else {
        return [super CGImage];
    }
}

- (UIImageOrientation)imageOrientation{
    if (self.images.count) {
        return [(UIImage *)[self.images objectAtIndex:0] imageOrientation];
    } else {
        return [super imageOrientation];
    }
}

- (CGFloat)scale{
    if (self.images.count) {
        return [(UIImage *)[self.images objectAtIndex:0] scale];
    }else{
        return [super scale];
    }
}

- (NSTimeInterval)duration{
    return self.images ? self.totalDuration : [super duration];
}


#pragma mark - 初始化图片资源，转UIImage对象
- (UIImage *)initWithCGImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale{
    self = [super init];
    if (!imageSource || !self) {
        return NULL;
    }
    CFRetain(imageSource);
    NSUInteger numberOfFrames = CGImageSourceGetCount(imageSource);
    NSDictionary *imageProperties = CFBridgingRelease(CGImageSourceCopyProperties(imageSource, NULL));
    NSDictionary *gifProperties = [imageProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    self.frameDurations = (NSTimeInterval *)malloc(numberOfFrames * sizeof(NSTimeInterval));
    self.loopCount = [gifProperties[(NSString *)kCGImagePropertyGIFLoopCount] unsignedIntegerValue];
    self.images = [NSMutableArray arrayWithCapacity:numberOfFrames];
    NSNull *aNull = [NSNull null];
    for (NSUInteger i = 0; i < numberOfFrames; ++i) {
        [self.images addObject:aNull];
        NSTimeInterval frameDuration = cgImageSourceGetGifFrameByDelay(imageSource, i);
        self.frameDurations[i] = frameDuration;
        self.totalDuration += frameDuration;
    }
    NSUInteger num = MIN(_prefetchedNum, numberOfFrames);
    for (NSUInteger i = 0; i < num; i++) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, i, NULL);
        if (image != NULL) {
            [self.images replaceObjectAtIndex:i withObject:[UIImage imageWithCGImage:image scale:_scale orientation:UIImageOrientationUp]];
            CFRelease(image);
        }else{
            [self.images replaceObjectAtIndex:i withObject:[NSNull null]];
        }
    }
    _imageSourceRef = imageSource;
    CFRetain(_imageSourceRef);
    CFRelease(imageSource);
    _scale = scale;
    readFrameQueue = dispatch_queue_create("com.huangsam.gifreadframe", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (UIImage *)frameAtIndex:(NSUInteger)idx{
    UIImage *frame = NULL;
    @synchronized(self.images){
        frame = self.images[idx];
    }
    if (!frame) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(_imageSourceRef, idx, NULL);
        if (image != NULL) {
            frame = [UIImage imageWithCGImage:image scale:_scale orientation:UIImageOrientationUp];
            CFRelease(image);
        }
    }
    if (self.images.count > _prefetchedNum) {
        if (idx != 0) {
            [self.images replaceObjectAtIndex:idx withObject:[NSNull null]];
        }
        NSUInteger nextReadIdx = (idx + _prefetchedNum);
        for (NSUInteger i = idx + 1; i <= nextReadIdx; i++) {
            NSUInteger _idx = i % self.images.count;
            if ([self.images[_idx] isKindOfClass:[NSNull class]]) {
                dispatch_async(readFrameQueue, ^{
                    CGImageRef image = CGImageSourceCreateImageAtIndex(_imageSourceRef, _idx, NULL);
                    @synchronized(self.images){
                        if (image != NULL) {
                            [self.images replaceObjectAtIndex:_idx withObject:[UIImage imageWithCGImage:image scale:_scale orientation:UIImageOrientationUp]];
                            CFRelease(image);
                        }else{
                            [self.images replaceObjectAtIndex:_idx withObject:[NSNull null]];
                        }
                    }
                });
            }
        }
    }
    return frame;
}



- (void)dealloc{
    if (_imageSourceRef) {
        CFRelease(_imageSourceRef);
    }
    free(_frameDurations);
    if (_incrementalSource) {
        CFRelease(_incrementalSource);
    }
}
@end

@interface MediaGIFImageView()

/**
 gif图片
 */
@property (nonatomic, strong) MediaGIFImage *animatedImage;

/**
 帧扫描
 */
@property (nonatomic, strong) CADisplayLink *displayLink;

/**
 累计
 */
@property (nonatomic, assign) NSTimeInterval accumulator;

/**
 当前帧下标
 */
@property (nonatomic, assign) NSUInteger currentFrameIndex;

/**
 当前帧图片
 */
@property (nonatomic, strong) UIImage *currentFrame;

/**
 循环倒计
 */
@property (nonatomic, assign) NSUInteger loopCountdown;

/**
 重复步进
 */
@property (nonatomic, assign) NSUInteger repeatStep;

@end
/**最大步进*/
const NSTimeInterval kMaxTimeStep = 1;

@implementation MediaGIFImageView
@synthesize runLoopMode = _runLoopMode;
@synthesize displayLink = _displayLink;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.currentFrameIndex = 0;
        self.repeatCount = 0;
    }
    return self;
}

#pragma mark - getter

- (CADisplayLink *)displayLink{
    if (self.superview) {
        if (!_displayLink && self.animatedImage) {
            _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeKeyFrame:)];
            [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:self.runLoopMode];
        }
    }else{
        [_displayLink invalidate];
        _displayLink = NULL;
    }
    return _displayLink;
}

- (NSString *)runLoopMode{
    return _runLoopMode ? : NSRunLoopCommonModes;
}

#pragma mark - setter

- (void)setAnimatedImage:(MediaGIFImage *)animatedImage{
    _animatedImage = animatedImage;
    if (animatedImage == NULL) {
        self.layer.contents = NULL;
    }
}

- (void)setRunLoopMode:(NSString *)runLoopMode{
    if (_runLoopMode != runLoopMode) {
        [self stopAnimating];
        NSRunLoop *runloop = [NSRunLoop mainRunLoop];
        [self.displayLink removeFromRunLoop:runloop forMode:_runLoopMode];
        [self.displayLink addToRunLoop:runloop forMode:runLoopMode];
        _runLoopMode = runLoopMode;
        [self startAnimating];
    }
}

#pragma mark - public method

- (void)reStart{
    if (self.displayLink.paused == NO) {
        return;
    }
    self.displayLink.paused = NO;
}

- (void)stop{
    [self.displayLink invalidate];
    self.displayLink = NULL;
    self.animatedImage = NULL;
}

#pragma mark - 重新UIImageView部分方法

- (void)setImage:(UIImage *)image{
    if (image == self.image) {
        return;
    }
    [self stopAnimating];
    self.currentFrameIndex = 0;
    self.loopCountdown = 0;
    self.accumulator = 0;
    self.repeatStep = 0;
    if ([image isKindOfClass:[MediaGIFImage class]] && image.images) {
        if ([image.images[0] isKindOfClass:[UIImage class]]) {
            [super setImage:image.images[0]];
        } else {
            [super setImage:NULL];
        }
        self.currentFrame = NULL;
        self.animatedImage = (MediaGIFImage *)image;
        self.loopCountdown = self.animatedImage.loopCount ? : NSUIntegerMax;
        [self startAnimating];
    }else{
        self.animatedImage = NULL;
        [super setImage:image];
    }
    [self.layer setNeedsDisplay];
}

- (BOOL)isAnimating{
    return [super isAnimating] || (self.displayLink && !self.displayLink.isPaused);
}

- (void)stopAnimating{
    if (!self.animatedImage) {
        [super stopAnimating];
        return;
    }
    self.loopCountdown = 0;
    self.displayLink.paused = YES;
}

- (void)startAnimating{
    if (!self.animatedImage) {
        [super startAnimating];
        return;
    }
    if (self.isAnimating) {
        return;
    }
    self.loopCountdown = self.animatedImage.loopCount ? : NSUIntegerMax;
    self.displayLink.paused = NO;
}

- (void)setHighlighted:(BOOL)highlighted{
    if (!self.animatedImage) {
        [super setHighlighted:highlighted];
    }
}

- (UIImage *)image{
    return self.animatedImage ? : [super image];
}

- (CGSize)sizeThatFits:(CGSize)size{
    return self.image.size;
}

#pragma mark - 重写CALayer方法

- (void)displayLayer:(CALayer *)layer{
    if (!self.animatedImage || [self.animatedImage.images count] == 0) {
        return;
    }
    if (self.currentFrame && ![self.currentFrame isKindOfClass:[NSNull class]]) {
        layer.contents = (__bridge id)([self.currentFrame CGImage]);
    }
}



#pragma mark - CADisplayLink事件
- (void)changeKeyFrame:(CADisplayLink *)link{
    if (self.currentFrameIndex >= [self.animatedImage.images count]) {
        return;
    }
    self.accumulator += fmin(link.duration, kMaxTimeStep);
    while (self.accumulator >= self.animatedImage.frameDurations[self.currentFrameIndex]) {
        self.accumulator -= self.animatedImage.frameDurations[self.currentFrameIndex];
        if (++self.currentFrameIndex >= [self.animatedImage.images count]) {
            if (--self.loopCountdown == 0) {
                [self stopAnimating];
                return;
            }
            self.currentFrameIndex = 0;
            if (self.repeatCount != 0) {
                self.repeatStep += 1;
                if (self.repeatStep >= self.repeatCount) {
                    [self stopAnimating];
                    self.repeatStep = 0;
                }
            }
        }
        self.currentFrameIndex = MIN(self.currentFrameIndex, [self.animatedImage.images count] - 1);
        self.currentFrame = [self.animatedImage frameAtIndex:self.currentFrameIndex];
        [self.layer setNeedsDisplay];
    }
}

#pragma mark - 重写UIView方法

- (void)didMoveToWindow{
    [super didMoveToWindow];
    if (self.window) {
        [self startAnimating];
    } else {
        //不能sync同步
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.window) {
                [self stopAnimating];
            }
        });
    }
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    if (self.superview) {
        [self displayLink];
    } else {
        //不能sync同步
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayLink];
        });
    }
}



@end
