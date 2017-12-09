//
//  MediaEditVideoController.m
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11 / 21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaEditVideoController.h"
#import "MediaDefine.h"
#import "MediaPhotoBrowser.h"
#import <AVFoundation/AVFoundation.h>
#import "MediaPhotoManager.h"
#import "MediaPhotoModel.h"
#import "MediaProgressHUD.h"
#import "ToastUtils.h"
#import "MediaExtension.h"

#define kMediaItemHeight 50.0
#define kMediaItemWidth (kMediaItemHeight * 2 / 3)
#define kCustomMediaItemWidth (kMediaItemHeight * 5 / 6)

/////// ----- cell
@interface MediaEditVideoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation MediaEditVideoCell

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end

@protocol MediaEditFrameViewDelegate <NSObject>

- (void)editViewValidRectChanged;

- (void)editViewValidRectEndChanged;

@end

///////  -  -  -  -  - 编辑框
@interface MediaEditFrameView : UIView
{
    UIImageView *_leftView;
    UIImageView *_rightView;
}

@property (nonatomic, assign) CGRect validRect;
@property (nonatomic, assign) CGFloat rightViewMaxX;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, weak) id<MediaEditFrameViewDelegate> delegate;
@property (nonatomic, strong) MediaPhotoConfiguration *configuration;
@end

@implementation MediaEditFrameView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (MediaPhotoConfiguration *)configuration{
    if (!_configuration) {
        _configuration = [MediaPhotoConfiguration customPhotoConfiguration];
    }
    return _configuration;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect left = _leftView.frame;
    CGRect right = _rightView.frame;
    if (self.configuration.uploadImmediately) {
        //扩大下有效范围
        left.origin.x  -= kCustomMediaItemWidth / 2;
        left.size.width += kCustomMediaItemWidth / 2;
        
        right.size.width += kCustomMediaItemWidth / 2;
    } else {
        //扩大下有效范围
        left.origin.x  -= kMediaItemWidth / 2;
        left.size.width += kMediaItemWidth / 2;
        
        right.size.width += kMediaItemWidth / 2;
    }
   
    
    if (CGRectContainsPoint(left, point)) {
        return _leftView;
    }
    if (CGRectContainsPoint(right, point)) {
        return _rightView;
    }
    return nil;
}

- (void)setupUI
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    
    if (self.configuration.uploadImmediately) {
        _leftView = [[UIImageView alloc] initWithImage:GetImageWithName(@"drag_left_view")];
        _leftView.contentMode = UIViewContentModeLeft;
        _leftView.userInteractionEnabled = YES;
        _leftView.tag = 0;
        UIPanGestureRecognizer *lg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_leftView addGestureRecognizer:lg];
        [self addSubview:_leftView];
        
        _rightView = [[UIImageView alloc] initWithImage:GetImageWithName(@"drag_right_view")];
        _rightView.userInteractionEnabled = YES;
        _rightView.contentMode = UIViewContentModeRight;
        _rightView.tag = 1;
        UIPanGestureRecognizer *rg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_rightView addGestureRecognizer:rg];
        [self addSubview:_rightView];
    } else {
        _leftView = [[UIImageView alloc] initWithImage:GetImageWithName(@"ic_left")];
        _leftView.userInteractionEnabled = YES;
        _leftView.tag = 0;
        UIPanGestureRecognizer *lg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_leftView addGestureRecognizer:lg];
        [self addSubview:_leftView];
        
        _rightView = [[UIImageView alloc] initWithImage:GetImageWithName(@"ic_right")];
        _rightView.userInteractionEnabled = YES;
        _rightView.tag = 1;
        UIPanGestureRecognizer *rg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_rightView addGestureRecognizer:rg];
        [self addSubview:_rightView];
    }
}

- (void)panAction:(UIGestureRecognizer *)pan
{
    if (self.configuration.uploadImmediately) {
        self.layer.borderColor = kMediaRGB(255, 96, 94).CGColor;
    } else {
        self.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.4].CGColor;
    }
    CGPoint point = [pan locationInView:self];
    
    CGRect rct = self.validRect;
    
    const CGFloat W = GetViewWidth(self);
    CGFloat minX = 0;
    CGFloat maxX = W;
    
    switch (pan.view.tag) {
        case 0: {
            //left
            if (self.configuration.uploadImmediately) {
                maxX = rct.origin.x  +  rct.size.width  - (kCustomMediaItemWidth * (self.configuration.minRecoredDuration));
            } else {
                maxX = rct.origin.x  +  rct.size.width  - (kMediaItemWidth * (self.configuration.minRecoredDuration));
            }
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width  -= (point.x  - rct.origin.x);
            rct.origin.x = point.x;
        }
            break;
            
        case 1:
        {
            if (self.configuration.uploadImmediately) {
                //right
                minX = (rct.origin.x  +  kCustomMediaItemWidth / 2);
                maxX = W  - kCustomMediaItemWidth / 2;

                point.x = MIN(MAX(minX, MIN(point.x, maxX)), _rightViewMaxX - kCustomMediaItemWidth / 2);
                point.y = 0;
                
                rct.size.width = MIN(MAX((point.x  - rct.origin.x  +  kCustomMediaItemWidth / 2), self.configuration.minRecoredDuration * kCustomMediaItemWidth), _frameCount * kCustomMediaItemWidth);
               
            } else {
                //right
                minX = rct.origin.x  +  kMediaItemWidth / 2;
                maxX = W  - kMediaItemWidth / 2;
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = 0;
                
                
                rct.size.width = MIN((point.x  - rct.origin.x  +  kMediaItemWidth / 2), _frameCount * kMediaItemWidth);
            }
            
        }
            break;
    }
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            if (self.delegate && [self.delegate respondsToSelector:@selector(editViewValidRectChanged)]) {
                [self.delegate editViewValidRectChanged];
            }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.layer.borderColor = [UIColor clearColor].CGColor;
            if (self.delegate && [self.delegate respondsToSelector:@selector(editViewValidRectEndChanged)]) {
                [self.delegate editViewValidRectEndChanged];
            }
            break;
            
        default:
            break;
    }
    
    self.validRect = rct;
}

- (void)setFrameCount:(NSInteger)frameCount{
    _frameCount = frameCount;
    CGRect tempRect = self.validRect;
    CGFloat validWidth = 0;
    if (self.configuration.uploadImmediately) {
        validWidth = frameCount * kCustomMediaItemWidth;
    } else {
        validWidth = frameCount * kMediaItemWidth;
    }
    tempRect.size.width = validWidth;
    self.validRect = tempRect;
    _rightViewMaxX = validWidth;
}


- (void)setValidRect:(CGRect)validRect
{
    _validRect = validRect;
    if (self.configuration.uploadImmediately) {
        _leftView.frame = CGRectMake(validRect.origin.x, 0, kCustomMediaItemWidth / 2, kMediaItemHeight);
        _rightView.frame = CGRectMake(validRect.origin.x + validRect.size.width  - kCustomMediaItemWidth / 2, 0, kCustomMediaItemWidth / 2, kMediaItemHeight);
    } else {
        _leftView.frame = CGRectMake(validRect.origin.x, 0, kMediaItemWidth / 2, kMediaItemHeight);
        _rightView.frame = CGRectMake(validRect.origin.x + validRect.size.width  - kMediaItemWidth / 2, 0, kMediaItemWidth / 2, kMediaItemHeight);
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.validRect);
    if (self.configuration.uploadImmediately) {
        CGContextSetStrokeColorWithColor(context, kMediaRGB(255, 96, 94).CGColor);
    } else {
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    
    CGContextSetLineWidth(context, 4.0);
    
    CGPoint topPoints[2];
    topPoints[0] = CGPointMake(self.validRect.origin.x, 0);
    topPoints[1] = CGPointMake(self.validRect.origin.x + self.validRect.size.width, 0);
    
    CGPoint bottomPoints[2];
    bottomPoints[0] = CGPointMake(self.validRect.origin.x, kMediaItemHeight);
    bottomPoints[1] = CGPointMake(self.validRect.origin.x + self.validRect.size.width, kMediaItemHeight);
    
    CGContextAddLines(context, topPoints, 2);
    CGContextAddLines(context, bottomPoints, 2);
    
    CGContextDrawPath(context, kCGPathStroke);
}

@end


///////  -  -  -  -  - editvc
@interface MediaEditVideoController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MediaEditFrameViewDelegate>
{
    UIView *_bottomView;
    UIButton *_cancelBtn;
    UIButton *_doneBtn;
    
    NSTimer *_timer;
    
    //下方collectionview偏移量
    CGFloat _offsetX;
    
    UIView *_indicatorLine;
    
    AVAsset *_avAsset;
    
    NSTimeInterval _interval;
}

@property (nonatomic, strong) NSMutableArray<UIImage *> *arrImages;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) MediaEditFrameView *editView;
@property (nonatomic, assign) CGSize squareSize;
@property (nonatomic, assign) CGRect circularFrame;
//@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *clipLabel;
@property (nonatomic, assign) NSInteger frameCount;
@end

@implementation MediaEditVideoController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"  -  -  -  - %s", __FUNCTION__);
}


- (NSMutableArray<UIImage *> *)arrImages
{
    if (!_arrImages) {
        _arrImages = [NSMutableArray array];
    }
    return _arrImages;
}

//- (UIProgressView *)progressView{
//    if (!_progressView) {
//        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 2.f, CGRectGetWidth(self.view.frame), 1.f)];
//        _progressView.progressTintColor = kMediaRGB(255, 96, 94);
//        _progressView.hidden = YES;
//    }
//    return _progressView;
//}

- (UILabel *)clipLabel{
    if (!_clipLabel) {
        _clipLabel = [[UILabel alloc] init];
        _clipLabel.textAlignment = NSTextAlignmentCenter;
        _clipLabel.font = [UIFont systemFontOfSize:16];
        _clipLabel.textColor = [UIColor whiteColor];
    }
    return _clipLabel;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"裁剪";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

- (void)setFrameCount:(NSInteger)frameCount{
    _frameCount = frameCount;
    self.editView.frameCount = _frameCount;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self drawClipPath];
    [self analysisAssetImages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    MediaPhotoConfiguration *configuration = ((MediaImageNavigationController *)self.navigationController).configuration;
    
    CGFloat bottomViewH = 44;
    CGFloat bottomBtnH = 30;
    CGFloat bottomSubviewW = 60;
    CGFloat bottomSubviewY = 7;
    if (configuration.uploadImmediately) {
        _bottomView.frame = CGRectMake(0, 20, kMediaViewWidth, kMediaItemHeight);
        _cancelBtn.frame = CGRectMake(10 + inset.left, bottomSubviewY, GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserCancelText), 15, YES, bottomBtnH), bottomBtnH);
        _doneBtn.frame = CGRectMake(kMediaViewWidth  - bottomSubviewW  - inset.right, bottomSubviewY, bottomSubviewW, bottomBtnH);
        self.titleLabel.frame = CGRectMake((CGRectGetWidth(_bottomView.frame) - bottomSubviewW) / 2, bottomSubviewY, bottomSubviewW, bottomBtnH);
        
        self.playerLayer.frame = CGRectMake(0, inset.top > 0 ? inset.top + CGRectGetMaxY(_bottomView.frame) : CGRectGetMaxY(_bottomView.frame), CGRectGetWidth(self.view.frame), kMediaViewHeight  - inset.bottom);
        
        self.editView.frame = CGRectMake((kMediaViewWidth  - kCustomMediaItemWidth * 8) / 2, kMediaViewHeight  - 100  - inset.bottom, kCustomMediaItemWidth * 8, kMediaItemHeight);
        self.editView.validRect = self.editView.bounds;
        
        self.clipLabel.frame = CGRectMake(CGRectGetMinX(self.editView.frame), CGRectGetMinY(self.editView.frame) - 20, CGRectGetWidth(self.editView.frame), 20);
        
        self.collectionView.frame = CGRectMake(inset.left  +  CGRectGetMinX(self.editView.frame), kMediaViewHeight  - 100  - inset.bottom, CGRectGetWidth(self.editView.frame), kMediaItemHeight);
        CGFloat leftOffset = ((kMediaViewWidth  - kCustomMediaItemWidth * 8) / 2  - inset.left  - CGRectGetMinX(self.editView.frame));
        CGFloat rightOffset = ((kMediaViewWidth  - kCustomMediaItemWidth * 8) / 2  - inset.right);
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, leftOffset, 0, rightOffset)];
        [self.collectionView setContentOffset:CGPointMake(_offsetX  - leftOffset, 0)];
        
    } else {
        self.playerLayer.frame = CGRectMake(15, inset.top>0 ? inset.top : 30, kMediaViewWidth  - 30, kMediaViewHeight  - 160  - inset.bottom);
        
        self.editView.frame = CGRectMake((kMediaViewWidth  - kMediaItemWidth * 10) / 2, kMediaViewHeight  - 100  - inset.bottom, kMediaItemWidth * 10, kMediaItemHeight);
        self.editView.validRect = self.editView.bounds;
        
        self.collectionView.frame = CGRectMake(inset.left, kMediaViewHeight  - 100  - inset.bottom, kMediaViewWidth  - inset.left  - inset.right, kMediaItemHeight);
        CGFloat leftOffset = ((kMediaViewWidth  - kMediaItemWidth * 10) / 2  - inset.left);
        CGFloat rightOffset = ((kMediaViewWidth  - kMediaItemWidth * 10) / 2  - inset.right);
        [self.collectionView setContentInset:UIEdgeInsetsMake(0, leftOffset, 0, rightOffset)];
        [self.collectionView setContentOffset:CGPointMake(_offsetX  - leftOffset, 0)];
        
        _bottomView.frame = CGRectMake(0, kMediaViewHeight  - bottomViewH  - inset.bottom, kMediaViewWidth, kMediaItemHeight);
        _cancelBtn.frame = CGRectMake(10 + inset.left, 7, GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserCancelText), 15, YES, bottomBtnH), bottomBtnH);
        _doneBtn.frame = CGRectMake(kMediaViewWidth  - 70  - inset.right, 7, 60, bottomBtnH);
    }
}

#pragma mark  - notifies
//设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    _offsetX = self.collectionView.contentOffset.x  +  self.collectionView.contentInset.left;
}

- (void)enterBackground
{
    [self stopTimer];
}

- (void)enterForeground
{
    [self startTimer];
}

- (void)setupUI
{
    //禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerLayer = [[AVPlayerLayer alloc] init];
    [self.view.layer addSublayer:self.playerLayer];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    MediaPhotoConfiguration *configuration = ((MediaImageNavigationController *)self.navigationController).configuration;
    if (configuration.uploadImmediately) {
        layout.itemSize = CGSizeMake(kCustomMediaItemWidth, kMediaItemHeight);
    } else {
        layout.itemSize = CGSizeMake(kMediaItemWidth, kMediaItemHeight);
    }
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:MediaEditVideoCell.class forCellWithReuseIdentifier:@"MediaEditVideoCell"];
    
    [self.view addSubview:self.collectionView];
    
    [self creatBottomView];
    
    self.editView = [[MediaEditFrameView alloc] init];
    self.editView.delegate = self;
    [self.view addSubview:self.editView];
    if (configuration.uploadImmediately) {
        _indicatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, kMediaItemHeight)];
        _indicatorLine.backgroundColor = kMediaRGB(255, 96, 94);
        [self.view addSubview:self.clipLabel];
    } else {
        _indicatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, kMediaItemHeight)];
        _indicatorLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
    }
    if (configuration.uploadImmediately) {
//        [self.view addSubview:self.progressView];
    }
}

- (void)creatBottomView
{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    //下方视图
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
    [self.view addSubview:_bottomView];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (configuration.uploadImmediately) {
        [_cancelBtn setImage:GetImageWithName(@"navBackBtn") forState:UIControlStateNormal];
    } else {
        [_cancelBtn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCancelText) forState:UIControlStateNormal];
        
    }
    [_cancelBtn addTarget:self action:@selector(cancelBtn_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_cancelBtn];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserDoneText) forState:UIControlStateNormal];
    [_doneBtn setBackgroundColor:configuration.uploadImmediately ? [UIColor clearColor]: configuration.bottomBtnsNormalTitleColor];
    [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _doneBtn.layer.masksToBounds = YES;
    _doneBtn.layer.cornerRadius = 3.0f;
    [_doneBtn addTarget:self action:@selector(btnDone_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_doneBtn];
    
    if (configuration.uploadImmediately) {
        [_bottomView addSubview:self.titleLabel];
    }
}

//绘制裁剪框
-(void)drawClipPath
{
    MediaPhotoConfiguration *configuration = ((MediaImageNavigationController *)self.navigationController).configuration;
    if (configuration.uploadImmediately) {
        if (CGSizeEqualToSize(configuration.clipImageSize, CGSizeZero)) {
            CGFloat clipW = [UIScreen mainScreen].bounds.size.width;
            CGFloat clipH = clipW * (16 / 9.0);
            self.squareSize = CGSizeMake(clipW, clipH);
        }else{
            self.squareSize = configuration.clipImageSize;
        }
        CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat ScreenHeight = [UIScreen mainScreen].bounds.size.height;
        CGPoint center = self.view.center;
        UIBezierPath * path= [UIBezierPath bezierPathWithRect:CGRectMake(0, 64, ScreenWidth, ScreenHeight)];
        CAShapeLayer *layer = [CAShapeLayer layer];
        self.circularFrame = CGRectMake(center.x - self.squareSize.width / 2, center.y - self.squareSize.height / 2, self.squareSize.width, self.squareSize.height);
        NSLog(@"circular frame %@",NSStringFromCGRect(self.circularFrame));
        [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(center.x - self.squareSize.width / 2, center.y - self.squareSize.height / 2, self.squareSize.width, self.squareSize.height)]];
        [path setUsesEvenOddFillRule:YES];
        layer.path = path.CGPath;
        layer.fillRule = kCAFillRuleEvenOdd;
        layer.fillColor = [[UIColor blackColor] CGColor];
        layer.opacity = 0.5;
        [self.view.layer addSublayer:layer];
    }
}

#pragma mark  - 解析视频每一帧图片
- (void)analysisAssetImages
{
    MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
    [hud show];
    
    media_weak(self);
    [MediaPhotoManager requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            media_strong(weakSelf);
            if (!item) {
                return;
            }
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            strongSelf.playerLayer.player = player;
        });
    }];
    
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    _interval = ceil(configuration.maxEditVideoTime / 3.0);
    
    [MediaPhotoManager analysisEverySecondsImageForAsset:self.model.asset interval:_interval size:configuration.uploadImmediately ? CGSizeMake(kCustomMediaItemWidth * 5, kMediaItemHeight * 5) : CGSizeMake(kMediaItemWidth * 5, kMediaItemHeight * 5) completion:^(AVAsset *avAsset, NSArray<UIImage *> *images) {
        [hud hide];
        media_strong(weakSelf);
        strongSelf.frameCount = images.count;
        strongSelf -> _avAsset = avAsset;
        [strongSelf.arrImages addObjectsFromArray:images];
        [strongSelf.collectionView reloadData];
        [strongSelf startTimer];
    }];
}

#pragma mark  - action
- (void)cancelBtn_click
{
    [self stopTimer];
    
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    if (configuration.editAfterSelectThumbnailImage &&
        configuration.maxSelectCount == 1) {
        [nav.arrSelectedModels removeAllObjects];
    }
    
    UIViewController *vc = [self.navigationController popViewControllerAnimated:NO];
    if (!vc) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)btnDone_click
{
    [self stopTimer];
    
    MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
    [hud show];
    
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    media_weak(self);
    __weak typeof(nav) weakNav = nav;
    __weak typeof(configuration) weakConfiguration = configuration;
    [MediaPhotoManager exportEditVideoForAsset:_avAsset range:[self getTimeRange] type:nav.configuration.exportVideoType completion:^(BOOL isSuc, PHAsset *asset, NSURL *fileUrl, UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide];
            if (isSuc) {
//                media_strong(weakSelf);
                __strong typeof(weakNav) strongNav = weakNav;
                __strong typeof(weakConfiguration) strongConfiguration = weakConfiguration;
//                weakSelf.progressView.hidden = NO;
                MediaPhotoModel *model = [MediaPhotoModel modelWithAsset:asset type:MediaAssetMediaTypeVideo duration:nil];
                model.image = [self getClipFirstFrameImage:image];
                model.fileUrl = fileUrl;
                [strongNav.arrSelectedModels removeAllObjects];
                [strongNav.arrSelectedModels addObject:model];
                if (strongNav.callSelectImageBlock) {
                    if (strongConfiguration.uploadImmediately) {
                        strongNav.callSelectImageBlock(^(BOOL finished, BOOL hideAfter, float progress, NSString * _Nullable errorDesc) {
                            
                        });
                    } else {
                        strongNav.callSelectImageBlock(nil);
                    }
                }
            } else {
                media_strong(weakSelf);
                [strongSelf startTimer];
                ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserSaveVideoFailed));
            }
        });
    }];
}

#pragma mark - clip image

- (UIImage *)getClipFirstFrameImage:(UIImage *)originImage{
    UIImage *fixedImage = [originImage fixImageOrientation];
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat rationScale = (width / fixedImage.size.width);
    CGFloat clipX = CGRectGetMinX(self.circularFrame) / rationScale;
    CGFloat clipY = CGRectGetMinY(self.circularFrame) / rationScale;
    CGFloat clipWidth = CGRectGetWidth(self.circularFrame) / rationScale;
    CGFloat clipHeight = CGRectGetHeight(self.circularFrame) / rationScale;
    CGRect clipRect = CGRectMake(clipX, clipY, clipWidth, clipHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect(fixedImage.CGImage, clipRect);
    UIGraphicsBeginImageContext(clipRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, clipRect, imageRef);
    UIImage *clipImage = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    return clipImage;
}

#pragma mark  - timer
- (void)startTimer
{
    CGFloat duration = 0;
    MediaPhotoConfiguration *configuration = ((MediaImageNavigationController *)self.navigationController).configuration;
    if (configuration.uploadImmediately) {
        duration = _interval * self.editView.validRect.size.width / (kCustomMediaItemWidth);
    } else {
        duration = _interval * self.editView.validRect.size.width / (kMediaItemWidth);
    }
    if (duration > _frameCount) {
        duration = _frameCount;
    }
    self.clipLabel.text = [NSString stringWithFormat:@"视频已截取%lds",(long)duration];
    _timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(playPartVideo:) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    _indicatorLine.frame = CGRectMake(self.editView.validRect.origin.x, 0, 2, kMediaItemHeight);
    [self.editView addSubview:_indicatorLine];
    [UIView animateWithDuration:duration delay:.0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        _indicatorLine.frame = CGRectMake(CGRectGetMaxX(self.editView.validRect)  - 2, 0, 2, kMediaItemHeight);
    } completion:nil];
}

- (void)stopTimer
{
    [_timer invalidate];
    [_indicatorLine removeFromSuperview];
    [self.playerLayer.player pause];
}

- (CMTime)getStartTime
{
    CGRect rect = [self.collectionView convertRect:self.editView.validRect fromView:self.editView];
    CGFloat s = 0;
    MediaPhotoConfiguration *configuration = ((MediaImageNavigationController *)self.navigationController).configuration;
    if (configuration.uploadImmediately) {
        s = MAX(0, _interval * rect.origin.x / (kCustomMediaItemWidth));
    } else {
        s = MAX(0, _interval * rect.origin.x / (kMediaItemWidth));
    }
    return CMTimeMakeWithSeconds(s, self.playerLayer.player.currentTime.timescale);
}

- (CMTimeRange)getTimeRange
{
    CMTime start = [self getStartTime];
    CGFloat d = 0;
    MediaPhotoConfiguration *configuration = ((MediaImageNavigationController *)self.navigationController).configuration;
    if (configuration.uploadImmediately) {
        d = _interval * self.editView.validRect.size.width / (kCustomMediaItemWidth);
    } else {
        d = _interval * self.editView.validRect.size.width / (kMediaItemWidth);
    }
    CMTime duration = CMTimeMakeWithSeconds(d, self.playerLayer.player.currentTime.timescale);
    return CMTimeRangeMake(start, duration);
}

- (void)playPartVideo:(NSTimer *)timer
{
    [self.playerLayer.player play];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark  - edit view delegate
- (void)editViewValidRectChanged
{
    [self stopTimer];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)editViewValidRectEndChanged
{
    [self startTimer];
}

#pragma mark  - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.playerLayer.player) {
        return;
    }
    [self stopTimer];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self startTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startTimer];
}

#pragma mark  - collection view data sources
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaEditVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaEditVideoCell" forIndexPath:indexPath];
    
    cell.imageView.image = self.arrImages[indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark  - Navigation

// In a storyboard  - based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
