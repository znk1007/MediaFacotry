//
//  MediaRecordButton.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaRecordButton.h"

#define DEGREES_2_RADIANS(x) (0.0174532925 * (x))
@interface RingProgressView : UIView
@property(nonatomic, strong) UIColor *trackTintColor;
@property(nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic) float progress;
@end

@implementation RingProgressView

@synthesize trackTintColor = _trackTintColor;
@synthesize progressTintColor =_progressTintColor;
@synthesize progress = _progress;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGPoint centerPoint = CGPointMake(rect.size.height / 2, rect.size.width / 2);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2;
    
    CGFloat pathWidth = radius * 0.3f;
    
    CGFloat radians = DEGREES_2_RADIANS((self.progress*359.9)-90);
    CGFloat xOffset = radius*(1 + 0.85*cosf(radians));
    CGFloat yOffset = radius*(1 + 0.85*sinf(radians));
    CGPoint endPoint = CGPointMake(xOffset, yOffset);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //    [self.trackTintColor setFill];
    CGContextSetFillColorWithColor(context, self.trackTintColor.CGColor);
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathMoveToPoint(trackPath, NULL, centerPoint.x, centerPoint.y);
    //    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, DEGREES_2_RADIANS(270), DEGREES_2_RADIANS(-90), NO);
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, 0, 359.9, NO);
    
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextFillPath(context);
    CGPathRelease(trackPath);
    
    [self.progressTintColor setFill];
    CGMutablePathRef progressPath = CGPathCreateMutable();
    CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, DEGREES_2_RADIANS(270), radians, NO);
    CGPathCloseSubpath(progressPath);
    CGContextAddPath(context, progressPath);
    CGContextFillPath(context);
    CGPathRelease(progressPath);
    
    CGContextAddEllipseInRect(context, CGRectMake(centerPoint.x - pathWidth/2, 0, pathWidth, pathWidth));
    CGContextFillPath(context);
    
    CGContextAddEllipseInRect(context, CGRectMake(endPoint.x - pathWidth/2, endPoint.y - pathWidth/2, pathWidth, pathWidth));
    CGContextFillPath(context);
    
    CGContextSetBlendMode(context, kCGBlendModeClear);;
    CGFloat innerRadius = radius * 0.7;
    CGPoint newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius);
    CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius*2, innerRadius*2));
    CGContextFillPath(context);
}

#pragma mark - Property Methods

- (UIColor *)trackTintColor
{
    if (!_trackTintColor)
    {
        _trackTintColor = [UIColor colorWithRed:204 / 255.0 green:204 / 255.0 blue:204 / 255.0 alpha:0.3f];
    }
    return _trackTintColor;
}

- (UIColor *)progressTintColor
{
    if (!_progressTintColor)
    {
        _progressTintColor = [UIColor clearColor];
    }
    return _progressTintColor;
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    [self setNeedsDisplay];
}

@end

@interface MediaRecordButton ()
@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, strong) RingProgressView *ringProgress;
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, assign) NSTimeInterval tempInterval;
@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) BOOL isTimeOut;
@property (nonatomic, copy) void(^recordState)(MediaRecordButtonState state);
@property (nonatomic, copy) void(^recordTime)(NSInteger time);
@end

@implementation MediaRecordButton

- (void)videoRecordState:(void (^)(MediaRecordButtonState))completion{
    _recordState = completion;
}

- (void)videoRecordTime:(void(^)(NSInteger time))completion{
    _recordTime = completion;
}

- (void)dealloc {
    
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
    if (self.link) {
        [self.link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.link invalidate];
        self.link = nil;
    }
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    _isCancel = NO;
    _isTimeOut = NO;
    _singleTap = NO;
    _progress = 0.0;
    _tempInterval = 0;
    _interval = 10;
    [self addSubview:self.ringProgress];
    [self addSubview:self.dotView];
}

#pragma mark - setter

- (void)setSingleTap:(BOOL)singleTap{
    _singleTap = singleTap;
    if (_singleTap) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:singleTap];
    } else {
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        [self addGestureRecognizer:longPress];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [self addGestureRecognizer:singleTap];
    }
}

#pragma mark - getter
- (CADisplayLink *)link {
    if (_link == nil) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(beginRun:)];
        if (@available(iOS 10.0, *)) {
            [_link setPreferredFramesPerSecond:60];
        } else {
            // Fallback on earlier versions
        }
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    return _link;
}

- (void)beginRun:(CADisplayLink *)link {
    _tempInterval += 1 / 60.0;
    _progress = _tempInterval / self.interval;
    if (_recordTime) {
        _recordTime((NSInteger)_tempInterval);
    }
    if (_tempInterval >= self.interval) {
        _isTimeOut = YES;
        NSLog(@"超时了");
        [self stop];
        if (self.recordState) {
            self.recordState(MediaRecordButtonStateTimeout);
        }
    }
    self.ringProgress.progressTintColor = MediaColor(255, 96, 94);
    self.ringProgress.progress = _progress;
}

- (void)stop{
    [self.link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.link invalidate];
    self.link = nil;
    _isCancel = NO;
    _tempInterval = 0;
    _progress = 0;
    self.ringProgress.progressTintColor = [UIColor clearColor];
}

- (RingProgressView *)ringProgress{
    if (!_ringProgress) {
        _ringProgress = [[RingProgressView alloc] initWithFrame:self.bounds];
    }
    return _ringProgress;
}

- (UIView *)dotView{
    if (!_dotView) {
        CGFloat wh = 15.f;
        _dotView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - wh) / 2, (CGRectGetHeight(self.frame) - wh) / 2, wh, wh)];
        _dotView.backgroundColor = MediaColor(255, 96, 94);
        _dotView.layer.cornerRadius = wh / 2;
        _dotView.layer.masksToBounds = YES;
    }
    return _dotView;
}

- (void)singleTap:(UITapGestureRecognizer *)tap{
    NSLog(@"single tap");
    if (self.recordState) {
        self.recordState(MediaRecordButtonStateSingleTap);
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)gesture {
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self link];
            if (self.recordState) {
                self.recordState(MediaRecordButtonStateBegin);
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint point = [gesture locationInView:self];
            if (CGRectContainsPoint(self.ringProgress.frame, point)) {
                _isCancel = NO;
                if (self.recordState) {
                    self.recordState(MediaRecordButtonStateMoving);
                }
            } else {
                _isCancel = YES;
                if (self.recordState) {
                    self.recordState(MediaRecordButtonStateWillCancel);
                }
            }
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:{
            _isCancel = YES;
            if (self.recordState) {
                self.recordState(MediaRecordButtonStateDidCancel);
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{
            if (_isCancel) {
                if (self.recordState) {
                    self.recordState(MediaRecordButtonStateDidCancel);
                }
            } else if(!_isTimeOut){
                if (self.recordState) {
                    self.recordState(MediaRecordButtonStateEnd);
                }
            }
            _isTimeOut = NO;
            [self stop];
        }
            break;
        default:
            break;
    }
}

#pragma mark - setter

- (void)setResetProgress:(BOOL)resetProgress{
    _resetProgress = resetProgress;
    if (resetProgress) {
        self.ringProgress.progress = 0.f;
        self.ringProgress.progressTintColor = [UIColor clearColor];
    } else {
        
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
