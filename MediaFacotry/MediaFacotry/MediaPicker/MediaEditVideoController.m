//
//  MediaEditVideoController.m
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
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

#define kItemWidth kItemHeight * 2/3
#define kItemHeight 50

///////-----cell
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

///////-----编辑框
@interface MediaEditFrameView : UIView
{
    UIImageView *_leftView;
    UIImageView *_rightView;
}

@property (nonatomic, assign) CGRect validRect;
@property (nonatomic, weak) id<MediaEditFrameViewDelegate> delegate;

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

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //扩大下有效范围
    CGRect left = _leftView.frame;
    left.origin.x -= kItemWidth/2;
    left.size.width += kItemWidth/2;
    CGRect right = _rightView.frame;
    right.size.width += kItemWidth/2;
    
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

- (void)panAction:(UIGestureRecognizer *)pan
{
    self.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.4].CGColor;
    CGPoint point = [pan locationInView:self];
    
    CGRect rct = self.validRect;
    
    const CGFloat W = GetViewWidth(self);
    CGFloat minX = 0;
    CGFloat maxX = W;
    
    switch (pan.view.tag) {
        case 0: {
            //left
            maxX = rct.origin.x + rct.size.width - kItemWidth;
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width -= (point.x - rct.origin.x);
            rct.origin.x = point.x;
        }
            break;
            
        case 1:
        {
            //right
            minX = rct.origin.x + kItemWidth/2;
            maxX = W - kItemWidth/2;
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width = (point.x - rct.origin.x + kItemWidth/2);
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

- (void)setValidRect:(CGRect)validRect
{
    _validRect = validRect;
    _leftView.frame = CGRectMake(validRect.origin.x, 0, kItemWidth/2, kItemHeight);
    _rightView.frame = CGRectMake(validRect.origin.x+validRect.size.width-kItemWidth/2, 0, kItemWidth/2, kItemHeight);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.validRect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    
    CGPoint topPoints[2];
    topPoints[0] = CGPointMake(self.validRect.origin.x, 0);
    topPoints[1] = CGPointMake(self.validRect.origin.x+self.validRect.size.width, 0);
    
    CGPoint bottomPoints[2];
    bottomPoints[0] = CGPointMake(self.validRect.origin.x, kItemHeight);
    bottomPoints[1] = CGPointMake(self.validRect.origin.x+self.validRect.size.width, kItemHeight);
    
    CGContextAddLines(context, topPoints, 2);
    CGContextAddLines(context, bottomPoints, 2);
    
    CGContextDrawPath(context, kCGPathStroke);
}

@end


///////-----editvc
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

@end

@implementation MediaEditVideoController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (NSMutableArray<UIImage *> *)arrImages
{
    if (!_arrImages) {
        _arrImages = [NSMutableArray array];
    }
    return _arrImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
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
    
    self.playerLayer.frame = CGRectMake(15, inset.top>0?inset.top:30, kMediaViewWidth-30, kViewHeight-160-inset.bottom);
    
    self.editView.frame = CGRectMake((kMediaViewWidth-kItemWidth*10)/2, kViewHeight-100-inset.bottom, kItemWidth*10, kItemHeight);
    self.editView.validRect = self.editView.bounds;
    self.collectionView.frame = CGRectMake(inset.left, kViewHeight-100-inset.bottom, kMediaViewWidth-inset.left-inset.right, kItemHeight);
    
    CGFloat leftOffset = ((kMediaViewWidth-kItemWidth*10)/2-inset.left);
    CGFloat rightOffset = ((kMediaViewWidth-kItemWidth*10)/2-inset.right);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, leftOffset, 0, rightOffset)];
    [self.collectionView setContentOffset:CGPointMake(_offsetX-leftOffset, 0)];
    
    CGFloat bottomViewH = 44;
    CGFloat bottomBtnH = 30;
    _bottomView.frame = CGRectMake(0, kViewHeight-bottomViewH-inset.bottom, kMediaViewWidth, kItemHeight);
    _cancelBtn.frame = CGRectMake(10+inset.left, 7, GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserCancelText), 15, YES, bottomBtnH), bottomBtnH);
    _doneBtn.frame = CGRectMake(kMediaViewWidth-70-inset.right, 7, 60, bottomBtnH);
}

#pragma mark - notifies
//设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    _offsetX = self.collectionView.contentOffset.x + self.collectionView.contentInset.left;
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
    layout.itemSize = CGSizeMake(kItemWidth, kItemHeight);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:MediaEditVideoCell.class forCellWithReuseIdentifier:@"MediaEditVideoCell"];
    
    [self.view addSubview:self.collectionView];
    
    [self creatBottomView];
    
    self.editView = [[MediaEditFrameView alloc] init];
    self.editView.delegate = self;
    [self.view addSubview:self.editView];
    
    _indicatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, kItemHeight)];
    _indicatorLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
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
    [_cancelBtn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCancelText) forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelBtn_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_cancelBtn];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserDoneText) forState:UIControlStateNormal];
    [_doneBtn setBackgroundColor:configuration.bottomBtnsNormalTitleColor];
    [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _doneBtn.layer.masksToBounds = YES;
    _doneBtn.layer.cornerRadius = 3.0f;
    [_doneBtn addTarget:self action:@selector(btnDone_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_doneBtn];
}

#pragma mark - 解析视频每一帧图片
- (void)analysisAssetImages
{
    MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
    [hud show];
    
    media_weak(self);
    [MediaPhotoManager requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            media_strong(weakSelf);
            if (!item) return;
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            strongSelf.playerLayer.player = player;
        });
    }];
    
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    _interval = configuration.maxEditVideoTime/10.0;
    
    [MediaPhotoManager analysisEverySecondsImageForAsset:self.model.asset interval:_interval size:CGSizeMake(kItemWidth*5, kItemHeight*5) complete:^(AVAsset *avAsset, NSArray<UIImage *> *images) {
        [hud hide];
        media_strong(weakSelf);
        strongSelf->_avAsset = avAsset;
        [strongSelf.arrImages addObjectsFromArray:images];
        [strongSelf.collectionView reloadData];
        [strongSelf startTimer];
    }];
}

#pragma mark - action
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
    
    media_weak(self);
    __weak typeof(nav) weakNav = nav;
    [MediaPhotoManager exportEditVideoForAsset:_avAsset range:[self getTimeRange] type:nav.configuration.exportVideoType complete:^(BOOL isSuc, PHAsset *asset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide];
            if (isSuc) {
                __strong typeof(weakNav) strongNav = weakNav;
                MediaPhotoModel *model = [MediaPhotoModel modelWithAsset:asset type:MediaAssetMediaTypeVideo duration:nil];
                [strongNav.arrSelectedModels removeAllObjects];
                [strongNav.arrSelectedModels addObject:model];
                if (strongNav.callSelectImageBlock) {
                    strongNav.callSelectImageBlock(nil);
                }
            } else {
                media_strong(weakSelf);
                [strongSelf startTimer];
                ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserSaveVideoFailed));
            }
        });
    }];
}

#pragma mark - timer
- (void)startTimer
{
    CGFloat duration = _interval * self.editView.validRect.size.width / (kItemWidth);
    _timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(playPartVideo:) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    _indicatorLine.frame = CGRectMake(self.editView.validRect.origin.x, 0, 2, kItemHeight);
    [self.editView addSubview:_indicatorLine];
    [UIView animateWithDuration:duration delay:.0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        _indicatorLine.frame = CGRectMake(CGRectGetMaxX(self.editView.validRect)-2, 0, 2, kItemHeight);
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
    CGFloat s = MAX(0, _interval * rect.origin.x / (kItemWidth));
    return CMTimeMakeWithSeconds(s, self.playerLayer.player.currentTime.timescale);
}

- (CMTimeRange)getTimeRange
{
    CMTime start = [self getStartTime];
    CGFloat d = _interval * self.editView.validRect.size.width / (kItemWidth);
    CMTime duration = CMTimeMakeWithSeconds(d, self.playerLayer.player.currentTime.timescale);
    return CMTimeRangeMake(start, duration);
}

- (void)playPartVideo:(NSTimer *)timer
{
    [self.playerLayer.player play];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - edit view delegate
- (void)editViewValidRectChanged
{
    [self stopTimer];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)editViewValidRectEndChanged
{
    [self startTimer];
}

#pragma mark - scroll view delegate
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

#pragma mark - collection view data sources
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
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
