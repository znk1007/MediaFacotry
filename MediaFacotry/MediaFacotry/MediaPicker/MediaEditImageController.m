//
//  MediaEditImageController.m
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#define R_BACK_S_X (0)//按钮x
#define R_BACK_S_Y (20)//按钮y
#define R_BACK_S_W_AND_H (40) //扫描宽高
#define V_CAM_BTN_T_R (18)

#import "MediaEditImageController.h"
#import "MediaPhotoModel.h"
#import "MediaDefine.h"
#import "MediaPhotoManager.h"
#import "ToastUtils.h"
#import "MediaProgressHUD.h"
#import "MediaPhotoBrowser.h"


#pragma mark- UI components
@interface MediaClippingCircle : UIView

@property (nonatomic, strong) UIColor *bgColor;

@end

@implementation MediaClippingCircle

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    rct.origin.x = rct.size.width/2-rct.size.width/6;
    rct.origin.y = rct.size.height/2-rct.size.height/6;
    rct.size.width /= 3;
    rct.size.height /= 3;
    
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillEllipseInRect(context, rct);
}

@end

//!!!!: MediaRatio
@interface MediaRatio : NSObject
@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, readonly) CGFloat ratio;
@property (nonatomic, strong) NSString *titleFormat;

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2;

@end

@implementation MediaRatio
{
    CGFloat _longSide;
    CGFloat _shortSide;
}

- (id)initWithValue1:(CGFloat)value1 value2:(CGFloat)value2
{
    self = [super init];
    if(self){
        _longSide  = MAX(fabs(value1), fabs(value2));
        _shortSide = MIN(fabs(value1), fabs(value2));
    }
    return self;
}

- (NSString*)description
{
    NSString *format = (self.titleFormat) ? self.titleFormat : @"%g : %g";
    
    if(self.isLandscape){
        return [NSString stringWithFormat:format, _longSide, _shortSide];
    }
    return [NSString stringWithFormat:format, _shortSide, _longSide];
}

- (CGFloat)ratio
{
    if(_longSide==0 || _shortSide==0){
        return 0;
    }
    
    if(self.isLandscape){
        return _shortSide / (CGFloat)_longSide;
    }
    return _longSide / (CGFloat)_shortSide;
}

@end

//!!!!: MediaRatioMenuItem
@interface MediaRatioMenuItem : UIView
{
    UIImageView *_iconView;
    UILabel *_titleLabel;
}
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) MediaRatio *ratio;
- (void)changeOrientation;
@end

@implementation MediaRatioMenuItem

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
    self = [self initWithFrame:frame];
    if(self){
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
        [self addGestureRecognizer:gesture];
        
        CGFloat W = frame.size.width;
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, W-20, W-20)];
        _iconView.clipsToBounds = YES;
        _iconView.layer.cornerRadius = 5;
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_iconView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_iconView.frame) + 5, W, 15)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = kMediaRGB(18, 18, 18);
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setRatio:(MediaRatio *)ratio
{
    if(ratio != _ratio){
        _ratio = ratio;
    }
}

- (void)refreshViews
{
    _titleLabel.text = [_ratio description];
    
    CGPoint center = _iconView.center;
    CGFloat W, H;
    if(_ratio.ratio!=0){
        if(_ratio.isLandscape){
            W = 50;
            H = 50*_ratio.ratio;
        }
        else{
            W = 50/_ratio.ratio;
            H = 50;
        }
    }
    else{
        CGFloat maxW  = MAX(_iconView.image.size.width, _iconView.image.size.height);
        W = 50 * _iconView.image.size.width / maxW;
        H = 50 * _iconView.image.size.height / maxW;
    }
    _iconView.frame = CGRectMake(center.x-W/2, center.y-H/2, W, H);
}

- (void)changeOrientation
{
    self.ratio.isLandscape = !self.ratio.isLandscape;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self refreshViews];
    }];
}

@end

@interface MediaGridLayar : CALayer
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *gridColor;

@end

@implementation MediaGridLayar

+ (BOOL)needsDisplayForKey:(NSString*)key
{
    if ([key isEqualToString:@"clippingRect"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (id)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if(self && [layer isKindOfClass:[MediaGridLayar class]]){
        self.bgColor   = ((MediaGridLayar *)layer).bgColor;
        self.gridColor = ((MediaGridLayar *)layer).gridColor;
        self.clippingRect = ((MediaGridLayar *)layer).clippingRect;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rct = self.bounds;
    CGContextSetFillColorWithColor(context, self.bgColor.CGColor);
    CGContextFillRect(context, rct);
    
    CGContextClearRect(context, _clippingRect);
    
    CGContextSetStrokeColorWithColor(context, self.gridColor.CGColor);
    CGContextSetLineWidth(context, 1);
    
    rct = self.clippingRect;
    
    CGContextBeginPath(context);
    CGFloat dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x+dW, rct.origin.y);
        CGContextAddLineToPoint(context, rct.origin.x+dW, rct.origin.y+rct.size.height);
        dW += _clippingRect.size.width/3;
    }
    
    dW = 0;
    for(int i=0;i<4;++i){
        CGContextMoveToPoint(context, rct.origin.x, rct.origin.y+dW);
        CGContextAddLineToPoint(context, rct.origin.x+rct.size.width, rct.origin.y+dW);
        dW += rct.size.height/3;
    }
    CGContextStrokePath(context);
}

@end

//!!!!: edit vc
@interface MediaEditImageController ()<UIGestureRecognizerDelegate>

#pragma mark - default
{
    UIImageView *_imageView;
    UIActivityIndicatorView *_indicator;
    
    MediaGridLayar *_gridLayer;
    MediaClippingCircle *_ltView;
    MediaClippingCircle *_lbView;
    MediaClippingCircle *_rtView;
    MediaClippingCircle *_rbView;
    
    UIView *_bottomView;
    UIButton *_cancelBtn;
    UIButton *_saveBtn;
    UIButton *_doneBtn;
    
    //旋转比例按钮
    UIButton *_rotateBtn;
    //比例底滚动视图
    UIScrollView *_menuScroll;
}

@property (nonatomic, strong) MediaRatioMenuItem *selectedMenu;
@property (nonatomic, assign) CGRect clippingRect;
@property (nonatomic, strong) MediaRatio *clippingRatio;

#pragma mark - custom

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *confimButton;
@property (nonatomic, assign) CGRect circularFrame;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGRect currentFrame;
@property (nonatomic, strong) UIImageView *customImageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIView * overView;
@property (nonatomic, strong) UIView * imageViewScale;
@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, strong) UIView *navView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) PHAsset *phAsset;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, assign) CGSize squareSize;
@property (nonatomic, assign) CGFloat scaleRation;

@end

@implementation MediaEditImageController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    if (configuration.uploadImmediately) {
        [self setupCustomBase];
    } else {
        [self initUI];
    }
    
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

#pragma mark - default

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    if (configuration.uploadImmediately) {
        
    } else {
        UIEdgeInsets inset = UIEdgeInsetsZero;
        if (@available(iOS 11, *)) {
            inset = self.view.safeAreaInsets;
        }
        
        BOOL hideClipRatioView = [self shouldHideClipRatioView];
        //隐藏时 底部工具条高44，间距设置4即可，不隐藏时，比例view高度80，则为128
        CGFloat flag = hideClipRatioView ? 48 : 128;
        
        CGFloat w = kMediaViewWidth-20;
        CGFloat maxH = kMediaViewHeight-flag-inset.bottom-inset.top-50;
        CGFloat h = w * self.model.asset.pixelHeight / self.model.asset.pixelWidth;
        if (h > maxH) {
            h = maxH;
            w = h * self.model.asset.pixelWidth / self.model.asset.pixelHeight;
        }
        _imageView.frame = CGRectMake((kMediaViewWidth-w)/2, (kMediaViewHeight-flag-h)/2, w, h);
        _gridLayer.frame = _imageView.bounds;
        [self clippingRatioDidChange];
        
        CGFloat bottomViewH = 44;
        CGFloat bottomBtnH = 30;
        
        _bottomView.frame = CGRectMake(0, kMediaViewHeight-bottomViewH-inset.bottom, kMediaViewWidth, bottomViewH);
        _cancelBtn.frame = CGRectMake(10+inset.left, 7, GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserCancelText), 15, YES, bottomBtnH), bottomBtnH);
        _saveBtn.frame = CGRectMake(kMediaViewWidth/2-20, 7, 40, bottomBtnH);
        _doneBtn.frame = CGRectMake(kMediaViewWidth-70-inset.right, 7, 60, bottomBtnH);
        
        _indicator.center = _imageView.center;
        
        
        if (hideClipRatioView) {
            _rotateBtn.hidden = YES;
            _menuScroll.hidden = YES;
        } else {
            _rotateBtn.superview.frame = CGRectMake(kMediaViewWidth-70-inset.right, kMediaViewHeight-128-inset.bottom, 70, 80);
            _menuScroll.frame = CGRectMake(inset.left, kMediaViewHeight-128-inset.bottom, kMediaViewWidth-70-inset.left-inset.right, 80);
        }
    }
}

//当裁剪比例只有 custom 或者 1:1 的时候隐藏比例视图
- (BOOL)shouldHideClipRatioView
{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    if (configuration.clipRatios.count <= 1) {
        NSInteger value1 = [configuration.clipRatios.firstObject[ClippingRatioValue1] integerValue];
        NSInteger value2 = [configuration.clipRatios.firstObject[ClippingRatioValue2] integerValue];
        if ((value1==0 && value2==0) || (value1==1 && value2==1)) {
            return YES;
        }
    }
    return NO;
}

- (void)initUI
{
    self.view.backgroundColor = [UIColor blackColor];
    //禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self creatBottomView];
    [self setCropMenu];
    [self loadImage];
    
    _gridLayer = [[MediaGridLayar alloc] init];
    _gridLayer.bgColor   = [[UIColor blackColor] colorWithAlphaComponent:.5];
    _gridLayer.gridColor = [UIColor whiteColor];
    [_imageView.layer addSublayer:_gridLayer];
    
    _ltView = [self clippingCircleWithTag:0];
    _lbView = [self clippingCircleWithTag:1];
    _rtView = [self clippingCircleWithTag:2];
    _rbView = [self clippingCircleWithTag:3];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGridView:)];
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:panGesture];
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
    
    _saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveBtn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserSaveText) forState:UIControlStateNormal];
    [_saveBtn addTarget:self action:@selector(saveBtn_click) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_saveBtn];
    
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

- (void)loadImage
{
    //imageview
    _imageView = [[UIImageView alloc] init];
    _imageView.image = self.oriImage;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    _indicator = [[UIActivityIndicatorView alloc] init];
    _indicator.center = _imageView.center;
    _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    _indicator.hidesWhenStopped = YES;
    [self.view addSubview:_indicator];
    
    CGFloat scale = 3;
    CGFloat width = MIN(kMediaViewWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width*scale, width*scale*self.model.asset.pixelHeight/self.model.asset.pixelWidth);
    
    [_indicator startAnimating];
    media_weak(self);
    [MediaPhotoManager requestImageForAsset:self.model.asset size:size completion:^(UIImage *image, NSDictionary *info) {
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            media_strong(weakSelf);
            [strongSelf->_indicator stopAnimating];
            strongSelf->_imageView.image = image;
            
            CGFloat W = 70;
            CGSize  imgSize = image.size;
            CGFloat maxW = MIN(imgSize.width, imgSize.height);
            UIImage *iconImage = [strongSelf scaleImage:image toSize:CGSizeMake(W * imgSize.width/maxW, W * imgSize.height/maxW)];
            for (UIView *v in strongSelf->_menuScroll.subviews) {
                if ([v isKindOfClass:[MediaRatioMenuItem class]]) {
                    ((MediaRatioMenuItem *)v).iconView.image = iconImage;
                    [((MediaRatioMenuItem *)v) refreshViews];
                }
            }
        }
    }];
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  newImage;
}

- (void)setCropMenu
{
    //这只是初始坐标，实际坐标在viewdidlayoutsubviews里面布局
    _menuScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kMediaViewWidth-70, 80)];
    _menuScroll.backgroundColor = [UIColor clearColor];
    _menuScroll.showsHorizontalScrollIndicator = NO;
    _menuScroll.clipsToBounds = NO;
    [self.view addSubview:_menuScroll];
    //旋转按钮
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.8];
    [self.view addSubview:view];
    _rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rotateBtn.frame = CGRectMake(15, 20, 40, 40);
    _rotateBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_rotateBtn setBackgroundImage:GetImageWithName(@"btn_rotate") forState:UIControlStateNormal];
    [_rotateBtn addTarget:self action:@selector(pushedRotateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_rotateBtn];
    
    CGFloat W = 70;
    CGFloat x = 0;
    
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    //如需要其他比例，请按照格式自行设置
    
    for(NSDictionary *info in configuration.clipRatios){
        CGFloat val1 = [info[@"value1"] floatValue];
        CGFloat val2 = [info[@"value2"] floatValue];
        
        MediaRatio *ratio = [[MediaRatio alloc] initWithValue1:val1 value2:val2];
        ratio.titleFormat = info[@"titleFormat"];
        
        ratio.isLandscape = NO;
        
        MediaRatioMenuItem *view = [[MediaRatioMenuItem alloc] initWithFrame:CGRectMake(x, 0, W, _menuScroll.frame.size.height) target:self action:@selector(tappedMenu:)];
        view.ratio = ratio;
        
        [_menuScroll addSubview:view];
        x += W;
        
        if(self.selectedMenu==nil){
            self.selectedMenu = view;
        }
    }
    _menuScroll.contentSize = CGSizeMake(MAX(x, _menuScroll.frame.size.width+1), 0);
}

- (void)tappedMenu:(UITapGestureRecognizer*)sender
{
    MediaRatioMenuItem *view = (MediaRatioMenuItem*)sender.view;
    
    view.alpha = 0.2;
    [UIView animateWithDuration:0.2 animations:^{
         view.alpha = 1;
    }];
    
    self.selectedMenu = view;
}

- (void)setSelectedMenu:(MediaRatioMenuItem *)selectedMenu
{
    if(selectedMenu != _selectedMenu){
        _selectedMenu.backgroundColor = [UIColor clearColor];
        _selectedMenu = selectedMenu;
        _selectedMenu.backgroundColor = kMediaRGB(30, 30, 30);
        
        if(selectedMenu.ratio.ratio==0){
            self.clippingRatio = nil;
        } else {
            self.clippingRatio = selectedMenu.ratio;
        }
    }
}

- (void)setClippingRatio:(MediaRatio *)clippingRatio
{
    if(clippingRatio != _clippingRatio){
        _clippingRatio = clippingRatio;
        [self clippingRatioDidChange];
    }
}

- (void)clippingRatioDidChange
{
    CGRect rect = _imageView.bounds;
    if (self.clippingRatio) {
        CGFloat H = rect.size.width * self.clippingRatio.ratio;
        if (H<=rect.size.height) {
            rect.size.height = H;
        } else {
            rect.size.width *= rect.size.height / H;
        }
        
        rect.origin.x = (_imageView.bounds.size.width - rect.size.width) / 2;
        rect.origin.y = (_imageView.bounds.size.height - rect.size.height) / 2;
    }
    [self setClippingRect:rect animated:YES];
}

- (void)setClippingRect:(CGRect)clippingRect animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
                             _ltView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y) fromView:_imageView];
                             _lbView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x, clippingRect.origin.y+clippingRect.size.height) fromView:_imageView];
                             _rtView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y) fromView:_imageView];
                             _rbView.center = [self.view convertPoint:CGPointMake(clippingRect.origin.x+clippingRect.size.width, clippingRect.origin.y+clippingRect.size.height) fromView:_imageView];
                         }
         ];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"clippingRect"];
        animation.duration = 0.2;
        animation.fromValue = [NSValue valueWithCGRect:_clippingRect];
        animation.toValue = [NSValue valueWithCGRect:clippingRect];
        [_gridLayer addAnimation:animation forKey:nil];
        
        _gridLayer.clippingRect = clippingRect;
        _clippingRect = clippingRect;
        [_gridLayer setNeedsDisplay];
    } else {
        self.clippingRect = clippingRect;
    }
}

- (void)pushedRotateBtn:(UIButton*)sender
{
    for(MediaRatioMenuItem *item in _menuScroll.subviews){
        if([item isKindOfClass:[MediaRatioMenuItem class]]){
            [item changeOrientation];
        }
    }
    
    if (self.clippingRatio.ratio!=0 &&
        self.clippingRatio.ratio!=1){
        [self clippingRatioDidChange];
    }
}

- (MediaClippingCircle*)clippingCircleWithTag:(NSInteger)tag
{
    MediaClippingCircle *view = [[MediaClippingCircle alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    view.backgroundColor = [UIColor clearColor];
    view.bgColor = [UIColor whiteColor];
    view.tag = tag;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCircleView:)];
    [view addGestureRecognizer:panGesture];
    
    [self.view addSubview:view];
    
    return view;
}

- (void)setClippingRect:(CGRect)clippingRect
{
    _clippingRect = clippingRect;
    
    _ltView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y) fromView:_imageView];
    _lbView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x, _clippingRect.origin.y+_clippingRect.size.height) fromView:_imageView];
    _rtView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y) fromView:_imageView];
    _rbView.center = [self.view convertPoint:CGPointMake(_clippingRect.origin.x+_clippingRect.size.width, _clippingRect.origin.y+_clippingRect.size.height) fromView:_imageView];
    
    _gridLayer.clippingRect = clippingRect;
    [_gridLayer setNeedsDisplay];
}

#pragma mark - 拖动
- (void)panCircleView:(UIPanGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:_imageView];
    CGPoint dp = [sender translationInView:_imageView];
    
    CGRect rct = self.clippingRect;
    
    const CGFloat W = _imageView.frame.size.width;
    const CGFloat H = _imageView.frame.size.height;
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = W;
    CGFloat maxY = H;
    
    CGFloat ratio = (sender.view.tag == 1 || sender.view.tag==2) ? -self.clippingRatio.ratio : self.clippingRatio.ratio;
    
    switch (sender.view.tag) {
        case 0: // upper left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = rct.origin.y - ratio * rct.origin.x;
                CGFloat x0 = -y0 / ratio;
                minX = MAX(x0, 0);
                minY = MAX(y0, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
        
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.x = point.x;
            rct.origin.y = point.y;
            break;
        }
        case 1: // lower left
        {
            maxX = MAX((rct.origin.x + rct.size.width)  - 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio* rct.origin.x ;
                CGFloat xh = (H - y0) / ratio;
                minX = MAX(xh, 0);
                maxY = MIN(y0, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = rct.size.width  - (point.x - rct.origin.x);
            rct.size.height = point.y - rct.origin.y;
            rct.origin.x = point.x;
            break;
        }
        case 2: // upper right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            maxY = MAX((rct.origin.y + rct.size.height) - 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = rct.origin.y - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat x0 = -y0 / ratio;
                maxX = MIN(x0, W);
                minY = MAX(yw, 0);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y > 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = rct.size.height - (point.y - rct.origin.y);
            rct.origin.y = point.y;
            break;
        }
        case 3: // lower right
        {
            minX = MAX(rct.origin.x + 0.1 * W, 0.1 * W);
            minY = MAX(rct.origin.y + 0.1 * H, 0.1 * H);
            
            if (ratio!=0) {
                CGFloat y0 = (rct.origin.y + rct.size.height) - ratio * (rct.origin.x + rct.size.width);
                CGFloat yw = ratio * W + y0;
                CGFloat xh = (H - y0) / ratio;
                maxX = MIN(xh, W);
                maxY = MIN(yw, H);
                
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
                
                if(-dp.x*ratio + dp.y < 0){ point.x = (point.y - y0) / ratio; }
                else{ point.y = point.x * ratio + y0; }
            } else {
                point.x = MAX(minX, MIN(point.x, maxX));
                point.y = MAX(minY, MIN(point.y, maxY));
            }
            
            rct.size.width  = point.x - rct.origin.x;
            rct.size.height = point.y - rct.origin.y;
            break;
        }
        default:
            break;
    }
    self.clippingRect = rct;
}

- (void)panGridView:(UIPanGestureRecognizer*)sender
{
    static BOOL dragging = NO;
    static CGRect initialRect;
    
    if (sender.state==UIGestureRecognizerStateBegan) {
        CGPoint point = [sender locationInView:_imageView];
        dragging = CGRectContainsPoint(_clippingRect, point);
        initialRect = self.clippingRect;
    } else if(dragging) {
        CGPoint point = [sender translationInView:_imageView];
        CGFloat left  = MIN(MAX(initialRect.origin.x + point.x, 0), _imageView.frame.size.width-initialRect.size.width);
        CGFloat top   = MIN(MAX(initialRect.origin.y + point.y, 0), _imageView.frame.size.height-initialRect.size.height);
        
        CGRect rct = self.clippingRect;
        rct.origin.x = left;
        rct.origin.y = top;
        self.clippingRect = rct;
    }
}

#pragma mark - action
- (void)cancelBtn_click
{
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

- (void)saveBtn_click
{
    //保存到相册
    MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
    [hud show];
    [MediaPhotoManager saveImageToAblum:[self clipImage] completion:^(BOOL suc, PHAsset *asset) {
        [hud hide];
        if (!suc) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserSaveImageErrorText));
        }
    }];
}

- (void)btnDone_click
{
    //确定裁剪，返回
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    if (nav.callSelectClipImageBlock) {
        nav.callSelectClipImageBlock([self clipImage], self.model.asset, nil);
    }
}

- (UIImage *)clipImage
{
    CGFloat zoomScale = _imageView.bounds.size.width / _imageView.image.size.width;
    CGRect rct = self.clippingRect;
    rct.size.width  /= zoomScale;
    rct.size.height /= zoomScale;
    rct.origin.x    /= zoomScale;
    rct.origin.y    /= zoomScale;
    
    CGPoint origin = CGPointMake(-rct.origin.x, -rct.origin.y);
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(rct.size, NO, _imageView.image.scale);
    [_imageView.image drawAtPoint:origin];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - custom

- (void)setupCustomBase{
    CGFloat clipW = 375 * ([UIScreen mainScreen].bounds.size.width / 375);
    CGFloat clipH = clipW * (4 / 3.0);
    self.squareSize = CGSizeMake(clipW, clipH);
    _scaleRation =  10;
    _lastScale = 1.0;
    [self setupBaseClip];
    [self setupClipSubviews];
}

- (void)setupBaseClip{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    CGFloat width = configuration.clipImageSize.width < CGRectGetWidth(self.view.frame) ? configuration.clipImageSize.width :  CGRectGetWidth(self.view.frame);
    CGFloat height = configuration.clipImageSize.height < CGRectGetHeight(self.view.frame) ? configuration.clipImageSize.height : CGRectGetHeight(self.view.frame);
    self.squareSize = CGSizeMake(width, height);
}

- (void)setupClipSubviews{
    self.view.backgroundColor = [UIColor blackColor];
    if (_oriImage) {
        
    } else {
        if (_model) {
            MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
            [hud show];
            media_weak(self);
            [MediaPhotoManager requestOriginalImageDataForAsset:_model.asset completion:^(NSData *data, NSDictionary *info) {
                [hud hide];
                media_strong(weakSelf);
                strongSelf.image = [UIImage imageWithData:data];
                [strongSelf.view addSubview:self.customImageView];
                [self.view addSubview:self.progressView];
                [self.view addSubview:self.overView];
                [self.view addSubview:self.navView];
                [self.view addSubview:self.backButton];
                [self.view addSubview:self.titleLabel];
                [self.view addSubview:self.confimButton];
                [strongSelf handleClip];
                [strongSelf addAllGesture];
            }];
        }else{
            [self.view addSubview:self.navView];
            [self.view addSubview:self.backButton];
            [self.view addSubview:self.titleLabel];
            [self.view addSubview:self.confimButton];
        }
    }
    
}

- (void)handleClip{
    _imageViewScale = self.customImageView;
    [self drawClipPath];
    [self makeImageViewFrameAdaptClipFrame];
}


#pragma mark - getter
- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(R_BACK_S_X, R_BACK_S_Y, R_BACK_S_W_AND_H, R_BACK_S_W_AND_H);
        [_backButton setImage:GetImageWithName(@"navBackBtn") forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(cancelBtn_click) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame) - R_BACK_S_W_AND_H) / 2, R_BACK_S_Y, R_BACK_S_W_AND_H, R_BACK_S_W_AND_H)];
        _titleLabel.text = @"裁剪";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _titleLabel;
}

- (UIButton *)confimButton{
    if (!_confimButton) {
        _confimButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confimButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - V_CAM_BTN_T_R - R_BACK_S_W_AND_H, R_BACK_S_Y, R_BACK_S_W_AND_H, R_BACK_S_W_AND_H);
        [_confimButton setTitle:@"完成" forState:UIControlStateNormal];
        [_confimButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confimButton addTarget:self action:@selector(confirmClip:) forControlEvents:UIControlEventTouchUpInside];
        _confimButton.titleLabel.font = [UIFont systemFontOfSize:16];
    }
    return _confimButton;
}

- (UIImageView *)customImageView{
    if (!_customImageView) {
        CGFloat width  = self.view.frame.size.width;
        CGFloat height = _image ? (_image.size.height / _image.size.width) * self.view.frame.size.width : self.view.frame.size.height;
        _customImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        if (_image) {
            _customImageView.image = _image;
        }
//        _customImageView.contentMode = UIViewContentModeScaleAspectFit;
        _customImageView.contentScaleFactor = [UIScreen mainScreen].scale;
        _customImageView.center = self.view.center;
        self.originalFrame = _customImageView.bounds;
    }
    return _customImageView;
}

- (UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64)];
        _navView.backgroundColor = [UIColor blackColor];
    }
    return _navView;
}

//覆盖层
- (UIView *)overView{
    if (!_overView) {
        _overView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height )];
        _overView.backgroundColor = [UIColor clearColor];
        _overView.opaque = NO;
    }
    return _overView;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 2.f, CGRectGetWidth(self.view.frame), 1.f)];
        _progressView.progressTintColor = kMediaRGB(255, 96, 94);
        _progressView.hidden = YES;
    }
    return _progressView;
}

//绘制裁剪框
-(void)drawClipPath
{
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
    [self.overView.layer addSublayer:layer];
}

//让图片自己适应裁剪框的大小
-(void)makeImageViewFrameAdaptClipFrame
{
    CGFloat width = self.customImageView.frame.size.width ;
    CGFloat height = self.customImageView.frame.size.height;
    if(height < self.circularFrame.size.height)
    {
        width = (width / height) * self.circularFrame.size.height;
        height = self.circularFrame.size.height;
        CGRect frame = CGRectMake(0, 0, width, height);
        [self.customImageView setFrame:frame];
        [self.customImageView setCenter:self.view.center];
    }
}
-(void)addAllGesture
{
    //捏合手势
    UIPinchGestureRecognizer * pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinGesture:)];
    [self.view addGestureRecognizer:pinGesture];
    //拖动手势
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];
}

-(void)handlePinGesture:(UIPinchGestureRecognizer *)pinGesture
{
    UIView * view = self.customImageView;
    if(pinGesture.state == UIGestureRecognizerStateBegan || pinGesture.state == UIGestureRecognizerStateChanged)
    {
        view.transform = CGAffineTransformScale(_imageViewScale.transform, pinGesture.scale,pinGesture.scale);
        pinGesture.scale = 1.0;
    }
    else if(pinGesture.state == UIGestureRecognizerStateEnded)
    {
        _lastScale = 1.0;
        CGFloat ration =  view.frame.size.width / self.originalFrame.size.width;
        
        if(ration > _scaleRation) // 缩放倍数 > 自定义的最大倍数
        {
            CGRect newFrame =CGRectMake(0, 0, self.originalFrame.size.width * _scaleRation, self.originalFrame.size.height * _scaleRation);
            view.frame = newFrame;
        }else if (view.frame.size.width < self.circularFrame.size.width && self.originalFrame.size.width <= self.originalFrame.size.height)
        {
            view.frame = [self handelWidthLessHeight:view];
            view.frame = [self handleScale:view];
        }
        else if(view.frame.size.height< self.circularFrame.size.height && self.originalFrame.size.height <= self.originalFrame.size.width)
        {
            view.frame =[self handleHeightLessWidth:view];
            view.frame = [self handleScale:view];
        }
        else
        {
            view.frame = [self handleScale:view];
        }
        self.currentFrame = view.frame;
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    UIView * view = self.customImageView;
    
    if(panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGesture translationInView:view.superview];
        [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
        
        [panGesture setTranslation:CGPointZero inView:view.superview];
    }
    else if ( panGesture.state == UIGestureRecognizerStateEnded)
    {
        CGRect currentFrame = view.frame;
        //向右滑动 并且超出裁剪范围后
        if(currentFrame.origin.x >= self.circularFrame.origin.x)
        {
            currentFrame.origin.x =self.circularFrame.origin.x;
            
        }
        //向下滑动 并且超出裁剪范围后
        if(currentFrame.origin.y >= self.circularFrame.origin.y)
        {
            currentFrame.origin.y = self.circularFrame.origin.y;
        }
        //向左滑动 并且超出裁剪范围后
        if(currentFrame.size.width + currentFrame.origin.x < self.circularFrame.origin.x + self.circularFrame.size.width)
        {
            CGFloat movedLeftX =fabs(currentFrame.size.width + currentFrame.origin.x -(self.circularFrame.origin.x + self.circularFrame.size.width));
            currentFrame.origin.x += movedLeftX;
        }
        //向上滑动 并且超出裁剪范围后
        if(currentFrame.size.height+currentFrame.origin.y < self.circularFrame.origin.y + self.circularFrame.size.height)
        {
            CGFloat moveUpY =fabs(currentFrame.size.height + currentFrame.origin.y -(self.circularFrame.origin.y + self.circularFrame.size.height));
            currentFrame.origin.y += moveUpY;
        }
        [UIView animateWithDuration:0.05 animations:^{
            [view setFrame:currentFrame];
        }];
    }
}

//缩放结束后 确保图片在裁剪框内
-(CGRect )handleScale:(UIView *)view
{
    // 图片.right < 裁剪框.right
    if(view.frame.origin.x + view.frame.size.width< self.circularFrame.origin.x+self.circularFrame.size.width)
    {
        CGFloat right =view.frame.origin.x + view.frame.size.width;
        CGRect viewFrame = view.frame;
        CGFloat space = self.circularFrame.origin.x+self.circularFrame.size.width - right;
        viewFrame.origin.x+=space;
        view.frame = viewFrame;
    }
    // 图片.top < 裁剪框.top
    if(view.frame.origin.y > self.circularFrame.origin.y)
    {
        CGRect viewFrame = view.frame;
        viewFrame.origin.y=self.circularFrame.origin.y;
        view.frame = viewFrame;
    }
    // 图片.left < 裁剪框.left
    if(view.frame.origin.x > self.circularFrame.origin.x)
    {
        CGRect viewFrame = view.frame;
        viewFrame.origin.x=self.circularFrame.origin.x;
        view.frame = viewFrame;
    }
    // 图片.bottom < 裁剪框.bottom
    if((view.frame.size.height +view.frame.origin.y) < (self.circularFrame.origin.y + self.circularFrame.size.height))
    {
        CGRect viewFrame = view.frame;
        CGFloat space = self.circularFrame.origin.y + self.circularFrame.size.height - (view.frame.size.height +view.frame.origin.y);
        viewFrame.origin.y +=space;
        view.frame = viewFrame;
    }
    
    return view.frame;
}

// 图片的高<宽 并且缩放后的图片高小于裁剪框的高
-(CGRect )handleHeightLessWidth:(UIView *)view
{
    CGRect tempFrame = view.frame;
    CGFloat rat = self.originalFrame.size.width / self.originalFrame.size.height;
    CGFloat width = self.circularFrame.size.width * rat;
    CGFloat height = self.circularFrame.size.height ;
    CGFloat  x  = view.frame.origin.x ;
    CGFloat y = self.circularFrame.origin.y;
    
    if(view.frame.origin.x > self.circularFrame.origin.x)
    {
        x = self.circularFrame.origin.x;
    }
    else if ((view.frame.origin.x+view.frame.size.width) < self.circularFrame.origin.x + self.circularFrame.size.width)
    {
        x = self.circularFrame.origin.x + self.circularFrame.size.width - width ;
    }
    
    CGRect newFrame =CGRectMake(x, y, width,height);
    view.frame = newFrame;
    
    if((tempFrame.origin.x > self.circularFrame.origin.x &&(tempFrame.origin.x+tempFrame.size.width) < self.circularFrame.origin.x + self.circularFrame.size.width))
    {
        [view setCenter:self.view.center];
    }
    
    if((tempFrame.origin.y > self.circularFrame.origin.y &&(tempFrame.origin.y+tempFrame.size.height) < self.circularFrame.origin.y + self.circularFrame.size.height))
    {
        [view setCenter:CGPointMake(tempFrame.size.width/2 + tempFrame.origin.x, view.frame.size.height /2)];
    }
    return  view.frame;
}

//图片的宽<高 并且缩放后的图片宽小于裁剪框的宽
-(CGRect)handelWidthLessHeight:(UIView *)view
{
    CGFloat rat = self.originalFrame.size.height / self.originalFrame.size.width;
    CGRect tempFrame = view.frame;
    
    CGFloat width = self.circularFrame.size.width;
    CGFloat height = self.circularFrame.size.height * rat ;
    
    CGFloat  x  = self.circularFrame.origin.x ;
    CGFloat y = view.frame.origin.y;
    
    if(view.frame.origin.y > self.circularFrame.origin.y)
    {
        y = self.circularFrame.origin.y;
    }
    else if ((view.frame.origin.y+view.frame.size.height) < self.circularFrame.origin.y + self.circularFrame.size.height)
    {
        y = self.circularFrame.origin.y + self.circularFrame.size.height - height ;
    }
    CGRect newFrame =CGRectMake(x, y, width,height);
    view.frame = newFrame;
    
    if((tempFrame.origin.y > self.circularFrame.origin.y &&(tempFrame.origin.y+tempFrame.size.height) < self.circularFrame.origin.y + self.circularFrame.size.height))
    {
        [view setCenter:self.view.center];
        
    }
    if((tempFrame.origin.x > self.circularFrame.origin.x &&(tempFrame.origin.x+tempFrame.size.width) < self.circularFrame.origin.x + self.circularFrame.size.width))
    {
        [view setCenter:CGPointMake(view.frame.size.width/2, tempFrame.size.height /2 + tempFrame.origin.y)];
    }
    return  view.frame;
}

//修复图片显示方向问题
-(UIImage *)fixOrientation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
        }
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        {
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
        }
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
        }
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        {
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        {
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
        }
            break;
            
        default:
        {
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
        }
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//方形裁剪
-(UIImage *)getSmallImage
{
    CGFloat width= self.customImageView.frame.size.width;
    CGFloat rationScale = (width /_image.size.width);
    
    CGFloat origX = (self.circularFrame.origin.x - self.customImageView.frame.origin.x) / rationScale;
    CGFloat origY = (self.circularFrame.origin.y - self.customImageView.frame.origin.y) / rationScale;
    CGFloat oriWidth = self.circularFrame.size.width / rationScale;
    CGFloat oriHeight = self.circularFrame.size.height / rationScale;
    
    CGRect myRect = CGRectMake(origX, origY, oriWidth, oriHeight);
    CGImageRef  imageRef = CGImageCreateWithImageInRect(_image.CGImage, myRect);
    UIGraphicsBeginImageContext(myRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myRect, imageRef);
    UIImage * clipImage = [UIImage imageWithCGImage:imageRef];
    UIGraphicsEndImageContext();
    return clipImage;
}

//圆形图片
-(UIImage *)circularClipImage:(UIImage *)image
{
    CGFloat arcCenterX = image.size.width/ 2;
    CGFloat arcCenterY = image.size.height / 2;
    
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextAddArc(context, arcCenterX , arcCenterY, image.size.width/ 2 , 0.0, 2*M_PI, NO);
    CGContextClip(context);
    CGRect myRect = CGRectMake(0 , 0, image.size.width ,  image.size.height);
    [image drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  newImage;
}

- (void)confirmClip:(UIButton *)btn{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    if (nav.callSelectClipImageBlock) {
        media_weak(self);
        nav.callSelectClipImageBlock([self getSmallImage], _model.asset, ^(BOOL finished, BOOL hideAfter, float progress, NSString * _Nullable errorDesc) {
            media_strong(weakSelf);
            strongSelf.progressView.progress = progress;
            if (progress >= 1.0) {
                [strongSelf.progressView removeFromSuperview];
                strongSelf.progressView = nil;
            }
        });
    }
}

@end
