 //
 //   MediaEditVideoViewController.m
 //   MediaFacotry
 //
 //   Created by HuangSam on 2017 / 11 / 30.
 //   Copyright © 2017年 HM. All rights reserved.
 //

#import "MediaEditVideoViewController.h"
#import "MediaProgressHUD.h"
#import "MediaToast.h"
#import "MediaExtension.h"
#import "MediaPhoto.h"
#import "MediaNavgationController.h"


 //  //  //  /  -  -  -  -  - cell
@interface MediaEditVideoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView  * imageView;

@end

@implementation MediaEditVideoCell

 -  (UIImageView  * )imageView
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

 -  (void)editViewValidRectChanged;

 -  (void)editViewValidRectEndChanged;

@end

///////  -  -  -  -  - 编辑框
@interface MediaEditFrameView : UIView
{
    UIImageView  * _leftView;
    UIImageView  * _rightView;
}

@property (nonatomic, assign) CGRect validRect;
@property (nonatomic, weak) id<MediaEditFrameViewDelegate> delegate;

@end

@implementation MediaEditFrameView

 -  (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

 -  (UIView  * )hitTest:(CGPoint)point withEvent:(UIEvent  * )event
{
    // 扩大下有效范围
    CGRect left = _leftView.frame;
    left.origin.x  -= kMediaEditItemWidth / 2;
    left.size.width += kMediaEditItemWidth / 2;
    CGRect right = _rightView.frame;
    right.size.width += kMediaEditItemWidth / 2;
    
    if (CGRectContainsPoint(left, point)) {
        return _leftView;
    }
    if (CGRectContainsPoint(right, point)) {
        return _rightView;
    }
    return nil;
}

 -  (void)setupUI
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
    self.layer.borderWidth = 2;
    self.layer.borderColor = [UIColor clearColor].CGColor;
    
    _leftView = [[UIImageView alloc] initWithImage:[MediaFactory sharedFactory].style.leftCutImage];
    _leftView.userInteractionEnabled = YES;
    _leftView.tag = 0;
    UIPanGestureRecognizer  * lg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_leftView addGestureRecognizer:lg];
    [self addSubview:_leftView];
    
    _rightView = [[UIImageView alloc] initWithImage:[MediaFactory sharedFactory].style.rightCutImage];
    _rightView.userInteractionEnabled = YES;
    _rightView.tag = 1;
    UIPanGestureRecognizer  * rg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [_rightView addGestureRecognizer:rg];
    [self addSubview:_rightView];
}

 -  (void)panAction:(UIGestureRecognizer  * )pan
{
    self.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.4].CGColor;
    CGPoint point = [pan locationInView:self];
    
    CGRect rct = self.validRect;
    
    const CGFloat W = self.width;
    CGFloat minX = 0;
    CGFloat maxX = W;
    
    switch (pan.view.tag) {
        case 0: {
             // left
            maxX = rct.origin.x + rct.size.width  -  kMediaEditItemWidth;
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width  -= (point.x  -  rct.origin.x);
            rct.origin.x = point.x;
        }
            break;
            
        case 1:
        {
             // right
            minX = rct.origin.x + kMediaEditItemWidth / 2;
            maxX = W  -  kMediaEditItemWidth / 2;
            
            point.x = MAX(minX, MIN(point.x, maxX));
            point.y = 0;
            
            rct.size.width = (point.x  -  rct.origin.x + kMediaEditItemWidth / 2);
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

 -  (void)setValidRect:(CGRect)validRect
{
    _validRect = validRect;
    _leftView.frame = CGRectMake(validRect.origin.x, 0, kMediaEditItemWidth / 2, kMediaEditItemHeight);
    _rightView.frame = CGRectMake(validRect.origin.x+validRect.size.width - kMediaEditItemWidth / 2, 0, kMediaEditItemWidth / 2, kMediaEditItemHeight);
    
    [self setNeedsDisplay];
}

 -  (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, self.validRect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 4.0);
    
    CGPoint topPoints[2];
    topPoints[0] = CGPointMake(self.validRect.origin.x, 0);
    topPoints[1] = CGPointMake(self.validRect.origin.x+self.validRect.size.width, 0);
    
    CGPoint bottomPoints[2];
    bottomPoints[0] = CGPointMake(self.validRect.origin.x, kMediaEditItemHeight);
    bottomPoints[1] = CGPointMake(self.validRect.origin.x+self.validRect.size.width, kMediaEditItemHeight);
    
    CGContextAddLines(context, topPoints, 2);
    CGContextAddLines(context, bottomPoints, 2);
    
    CGContextDrawPath(context, kCGPathStroke);
}

@end

@interface MediaEditVideoViewController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MediaEditFrameViewDelegate>
{
    UIView  * _bottomView;
    UIButton  * _cancelBtn;
    UIButton  * _doneBtn;
    
    NSTimer  * _timer;
    
    //下方collectionview偏移量
    CGFloat _offsetX;
    
    UIView  * _indicatorLine;
    
    AVAsset  * _avAsset;
    
    NSTimeInterval _interval;
}

@property (nonatomic, strong) NSMutableArray<UIImage  * >  * arrImages;
@property (nonatomic, strong) AVPlayerLayer  * playerLayer;
@property (nonatomic, strong) UICollectionView  * collectionView;
@property (nonatomic, strong) MediaEditFrameView  * editView;

@end

@implementation MediaEditVideoViewController

 -  (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@" -  -  -  -  %s", __FUNCTION__);
}

 -  (NSMutableArray<UIImage  * >  * )arrImages
{
    if (!_arrImages) {
        _arrImages = [NSMutableArray array];
    }
    return _arrImages;
}

 -  (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self analysisAssetImages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

 -  (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}

 -  (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

 -  (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11,  * )) {
        inset = self.view.safeAreaInsets;
    }
    
    self.playerLayer.frame = CGRectMake(15, inset.top>0?inset.top:30, kMediaScreenWidth - 30, kMediaScreenHeight - 160 - inset.bottom);
    
    self.editView.frame = CGRectMake((kMediaScreenWidth - kMediaEditItemWidth * 10)/2, kMediaScreenHeight - 100 - inset.bottom, kMediaEditItemWidth * 10, kMediaEditItemHeight);
    self.editView.validRect = self.editView.bounds;
    self.collectionView.frame = CGRectMake(inset.left, kMediaScreenHeight - 100 - inset.bottom, kMediaScreenWidth - inset.left - inset.right, kMediaEditItemHeight);
    
    CGFloat leftOffset = ((kMediaScreenWidth - kMediaEditItemWidth * 10)/2 - inset.left);
    CGFloat rightOffset = ((kMediaScreenWidth - kMediaEditItemWidth * 10)/2 - inset.right);
    [self.collectionView setContentInset:UIEdgeInsetsMake(0, leftOffset, 0, rightOffset)];
    [self.collectionView setContentOffset:CGPointMake(_offsetX - leftOffset, 0)];
    
    CGFloat bottomViewH = 44;
    CGFloat bottomBtnH = 30;
    _bottomView.frame = CGRectMake(0, kMediaScreenHeight - bottomViewH - inset.bottom, kMediaScreenWidth, kMediaEditItemHeight);
    _cancelBtn.frame = CGRectMake(10+inset.left, 7, 60, bottomBtnH);
    _doneBtn.frame = CGRectMake(kMediaScreenWidth - 70 - inset.right, 7, 60, bottomBtnH);
}

#pragma mark  -  notifies
//设备旋转
 -  (void)deviceOrientationChanged:(NSNotification  * )notify
{
    _offsetX = self.collectionView.contentOffset.x + self.collectionView.contentInset.left;
}

 -  (void)enterBackground
{
    [self stopTimer];
}

 -  (void)enterForeground
{
    [self startTimer];
}

 -  (void)setupUI
{
    //禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.playerLayer = [[AVPlayerLayer alloc] init];
    [self.view.layer addSublayer:self.playerLayer];
    
    UICollectionViewFlowLayout  * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(kMediaEditItemWidth, kMediaEditItemHeight);
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
    
    _indicatorLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, kMediaEditItemHeight)];
    _indicatorLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
}

 -  (void)creatBottomView
{
    //下方视图
    _bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.7];
    [self.view addSubview:_bottomView];
    
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelBtn_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_cancelBtn];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [_doneBtn setBackgroundColor:[MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor];
    [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _doneBtn.layer.masksToBounds = YES;
    _doneBtn.layer.cornerRadius = 3.0f;
    [_doneBtn addTarget:self action:@selector(btnDone_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_doneBtn];
}

#pragma mark  -  解析视频每一帧图片
 -  (void)analysisAssetImages
{
    MediaProgressHUD  * hud = [[MediaProgressHUD alloc] init];
    [hud show];
    
    __weak typeof(self) weakSelf = self;
    [[MediaFactory sharedFactory].photo requestVideoForAsset:self.model.phAsset completion:^(AVPlayerItem  * item, NSDictionary  * info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!item) return;
            AVPlayer  * player = [AVPlayer playerWithPlayerItem:item];
            strongSelf.playerLayer.player = player;
        });
    }];
    
    _interval = [MediaFactory sharedFactory].tool.maxEditVideoTime / 10.0;
    
    [[MediaFactory sharedFactory].photo fetchFrameImageForAsset:self.model.phAsset interval:_interval size:CGSizeMake(kMediaEditItemWidth  *  5, kMediaEditItemHeight  *  5) completion:^(AVAsset  * avAsset, NSArray<UIImage  * >  * images) {
        [hud hide];
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf -> _avAsset = avAsset;
        [strongSelf.arrImages addObjectsFromArray:images];
        [strongSelf.collectionView reloadData];
        [strongSelf startTimer];
    }];
}

#pragma mark  -  action
 -  (void)cancelBtn_click
{
    [self stopTimer];
    
    
    if ([MediaFactory sharedFactory].tool.editAfterSelectThumbnailImage &&
        [MediaFactory sharedFactory].tool.maxSelectCount == 1) {
        [[MediaFactory sharedFactory].tool.arrSelectedModels removeAllObjects];
    }
    
    UIViewController  * vc = [self.navigationController popViewControllerAnimated:NO];
    if (!vc) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

 -  (void)btnDone_click
{
    [self stopTimer];
    
    MediaProgressHUD  * hud = [[MediaProgressHUD alloc] init];
    [hud show];

    __weak typeof(self) weakSelf = self;
    [[MediaFactory sharedFactory].photo exportEditedVideoForAsset:_avAsset range:[self getTimeRange] type:[MediaFactory sharedFactory].tool.exportType completion:^(BOOL isSuc, PHAsset  * asset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide];
            if (isSuc) {
                MediaModel  * model = [MediaModel initModelWithPHAsset:asset mediaType:MediaAssetTypeVideo mediaDuration:nil];
                [[MediaFactory sharedFactory].tool.arrSelectedModels removeAllObjects];
                [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:model];
                if ([MediaFactory sharedFactory].tool.callSelectImageBlock) {
                    [MediaFactory sharedFactory].tool.callSelectImageBlock();
                }
            } else {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf startTimer];
                ShowToastLong(@"%@", @"视频保存失败");
            }
        });
    }];
}

#pragma mark  -  timer
 -  (void)startTimer
{
    CGFloat duration = _interval  *  self.editView.validRect.size.width / (kMediaEditItemWidth);
    _timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(playPartVideo:) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    _indicatorLine.frame = CGRectMake(self.editView.validRect.origin.x, 0, 2, kMediaEditItemHeight);
    [self.editView addSubview:_indicatorLine];
    [UIView animateWithDuration:duration delay:.0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        _indicatorLine.frame = CGRectMake(CGRectGetMaxX(self.editView.validRect) - 2, 0, 2, kMediaEditItemHeight);
    } completion:nil];
}

 -  (void)stopTimer
{
    [_timer invalidate];
    [_indicatorLine removeFromSuperview];
    [self.playerLayer.player pause];
}

 -  (CMTime)getStartTime
{
    CGRect rect = [self.collectionView convertRect:self.editView.validRect fromView:self.editView];
    CGFloat s = MAX(0, _interval  *  rect.origin.x / (kMediaEditItemWidth));
    return CMTimeMakeWithSeconds(s, self.playerLayer.player.currentTime.timescale);
}

 -  (CMTimeRange)getTimeRange
{
    CMTime start = [self getStartTime];
    CGFloat d = _interval  *  self.editView.validRect.size.width / (kMediaEditItemWidth);
    CMTime duration = CMTimeMakeWithSeconds(d, self.playerLayer.player.currentTime.timescale);
    return CMTimeRangeMake(start, duration);
}

 -  (void)playPartVideo:(NSTimer  * )timer
{
    [self.playerLayer.player play];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark  -  edit view delegate
 -  (void)editViewValidRectChanged
{
    [self stopTimer];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

 -  (void)editViewValidRectEndChanged
{
    [self startTimer];
}

#pragma mark  -  scroll view delegate
 -  (void)scrollViewDidScroll:(UIScrollView  * )scrollView
{
    if (!self.playerLayer.player) {
        return;
    }
    [self stopTimer];
    [self.playerLayer.player seekToTime:[self getStartTime] toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

 -  (void)scrollViewDidEndDragging:(UIScrollView  * )scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self startTimer];
    }
}

 -  (void)scrollViewDidEndDecelerating:(UIScrollView  * )scrollView
{
    [self startTimer];
}

#pragma mark  -  collection view data sources
 -  (NSInteger)collectionView:(UICollectionView  * )collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrImages.count;
}

 -  (UICollectionViewCell  * )collectionView:(UICollectionView  * )collectionView cellForItemAtIndexPath:(NSIndexPath  * )indexPath
{
    MediaEditVideoCell  * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaEditVideoCell" forIndexPath:indexPath];
    
    cell.imageView.image = self.arrImages[indexPath.row];
    
    return cell;
}

 -  (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark  -  Navigation

 //  In a storyboard - based application, you will often want to do a little preparation before navigation
 -  (void)prepareForSegue:(UIStoryboardSegue  * )segue sender:(id)sender {
     //  Get the new view controller using [segue destinationViewController].
     //  Pass the selected object to the new view controller.
}
*/

@end
