//
//  MediaPhotoActionSheet.m
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPhotoActionSheet.h"
#import "MediaCollectionCell.h"
#import "MediaPhotoManager.h"
#import "MediaPhotoBrowser.h"
#import "MediaShowBigImgViewController.h"
#import "MediaThumbnailViewController.h"
#import "MediaNoAuthorityViewController.h"
#import "ToastUtils.h"
#import "MediaEditImageController.h"
#import "MediaEditVideoController.h"
#import "MediaCustomCamera.h"
#import "MediaDefine.h"

#define kBaseViewHeight (self.configuration.maxPreviewCount ? 300 : 142)

double const ScalePhotoWidth = 1000;

@interface MediaPhotoActionSheet () <UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>
{
    CGPoint _panBeginPoint;
    MediaCollectionCell *_panCell;
    UIImageView *_panView;
    MediaPhotoModel *_panModel;
}

@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnAblum;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verColHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verBottomSpace;


@property (nonatomic, assign) BOOL animate;
@property (nonatomic, assign) BOOL preview;

@property (nonatomic, strong) NSMutableArray<MediaPhotoModel *> *arrDataSources;

@property (nonatomic, copy) NSMutableArray<MediaPhotoModel *> *arrSelectedModels;

@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
@property (nonatomic, assign) UIStatusBarStyle previousStatusBarStyle;
@property (nonatomic, assign) BOOL previousStatusBarIsHidden;
@property (nonatomic, assign) BOOL senderTabBarIsShow;
@property (nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation MediaPhotoActionSheet

- (void)dealloc
{
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (NSMutableArray<MediaPhotoModel *> *)arrDataSources
{
    if (!_arrDataSources) {
        _arrDataSources = [NSMutableArray array];
    }
    return _arrDataSources;
}

- (NSMutableArray<MediaPhotoModel *> *)arrSelectedModels
{
    if (!_arrSelectedModels) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}

- (UILabel *)placeholderLabel
{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kMediaViewWidth, 100)];
        _placeholderLabel.text = GetLocalLanguageTextValue(MediaPhotoBrowserNoPhotoText);
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderLabel.textColor = [UIColor darkGrayColor];
        _placeholderLabel.font = [UIFont systemFontOfSize:15];
        _placeholderLabel.center = self.collectionView.center;
        [self.collectionView addSubview:_placeholderLabel];
        _placeholderLabel.hidden = YES;
    }
    return _placeholderLabel;
}

- (MediaPhotoConfiguration *)configuration
{
    if (!_configuration) {
        _configuration = [MediaPhotoConfiguration defaultPhotoConfiguration];
    }
    return _configuration;
}

#pragma mark - setter
- (void)setArrSelectedAssets:(NSMutableArray<PHAsset *> *)arrSelectedAssets
{
    _arrSelectedAssets = arrSelectedAssets;
    [self.arrSelectedModels removeAllObjects];
    for (PHAsset *asset in arrSelectedAssets) {
        MediaPhotoModel *model = [MediaPhotoModel modelWithAsset:asset type:[MediaPhotoManager transformAssetType:asset] duration:nil];
        model.selected = YES;
        [self.arrSelectedModels addObject:model];
    }
}

- (instancetype)init
{
    self = [[kZLPhotoBrowserBundle loadNibNamed:@"MediaPhotoActionSheet" owner:self options:nil] lastObject];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        self.collectionView.collectionViewLayout = layout;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerClass:NSClassFromString(@"MediaCollectionCell") forCellWithReuseIdentifier:@"MediaCollectionCell"];
        if (![MediaPhotoManager havePhotoLibraryAuthority]) {
            //注册实施监听相册变化
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.btnCamera setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCameraText) forState:UIControlStateNormal];
    [self.btnAblum setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserAblumText) forState:UIControlStateNormal];
    [self.btnCancel setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCancelText) forState:UIControlStateNormal];
    [self resetSubViewState];
}

//相册变化回调
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.preview) {
            [self loadPhotoFromAlbum];
            [self show];
        } else {
            [self btnPhotoLibrary_Click:nil];
        }
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    });
}

- (void)showPreviewAnimated:(BOOL)animate sender:(UIViewController *)sender
{
    self.sender = sender;
    [self showPreviewAnimated:animate];
}

- (void)showPreviewAnimated:(BOOL)animate
{
    [self showPreview:YES animate:animate];
}

- (void)showPhotoLibraryWithSender:(UIViewController *)sender
{
    self.sender = sender;
    [self showPhotoLibrary];
}

- (void)showPhotoLibrary
{
    [self showPreview:NO animate:NO];
}

- (void)showPreview:(BOOL)preview animate:(BOOL)animate
{
    NSAssert(self.sender != nil, @"sender 对象不能为空");
    
    if (!self.configuration.allowSelectImage && self.arrSelectedModels.count) {
        [self.arrSelectedAssets removeAllObjects];
        [self.arrSelectedModels removeAllObjects];
    }
    
    self.animate = animate;
    self.preview = preview;
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.previousStatusBarIsHidden = [UIApplication sharedApplication].isStatusBarHidden;
    
    [MediaPhotoManager setSortAscending:self.configuration.sortAscending];
    
    if (!self.configuration.maxPreviewCount) {
        self.verColHeight.constant = .0;
    } else if (self.configuration.allowDragSelect) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self.baseView addGestureRecognizer:pan];
    }
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        [self showNoAuthorityVC];
        return;
    } else if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
        }];
        
        [self.sender.view addSubview:self];
    }
    
    if (preview) {
        if (status == PHAuthorizationStatusAuthorized) {
            [self loadPhotoFromAlbum];
            [self show];
        }
    } else {
        if (status == PHAuthorizationStatusAuthorized) {
            [self.sender.view addSubview:self];
            [self btnPhotoLibrary_Click:nil];
        }
    }
}

- (void)previewSelectedPhotos:(NSArray<UIImage *> *)photos assets:(NSArray<PHAsset *> *)assets index:(NSInteger)index isOriginal:(BOOL)isOriginal
{
    self.isSelectOriginalPhoto = isOriginal;
    self.arrSelectedAssets = [NSMutableArray arrayWithArray:assets];
    MediaShowBigImgViewController *svc = [self pushBigImageToPreview:photos index:index];
    media_weak(self);
    __weak typeof(svc.navigationController) weakNav = svc.navigationController;
    svc.previewSelectedImageBlock = ^(NSArray<UIImage *> *arrP, NSArray<PHAsset *> *arrA, MediaPickProgressCompletion _Nullable progress) {
        media_strong(weakSelf);
        strongSelf.arrSelectedAssets = assets.mutableCopy;
        __strong typeof(weakNav) strongNav = weakNav;
        if (strongSelf.selectImageBlock) {
            strongSelf.selectImageBlock(arrP, arrA, NO, progress);
        }
        [strongSelf hide];
        [strongNav dismissViewControllerAnimated:YES completion:nil];
    };
    
    svc.cancelPreviewBlock = ^{
        media_strong(weakSelf);
        [strongSelf hide];
    };
}

- (void)previewPhotos:(NSArray *)photos index:(NSInteger)index hideToolBar:(BOOL)hideToolBar completion:(nonnull void (^)(NSArray * _Nonnull))completion
{
    [self.arrSelectedModels removeAllObjects];
    for (id obj in photos) {
        MediaPhotoModel *model = [[MediaPhotoModel alloc] init];
        if ([obj isKindOfClass:UIImage.class]) {
            model.image = obj;
        } else if ([obj isKindOfClass:NSURL.class]) {
            model.url = obj;
        }
        model.type = MediaAssetMediaTypeNetImage;
        model.selected = YES;
        [self.arrSelectedModels addObject:model];
    }
    MediaShowBigImgViewController *svc = [self pushBigImageToPreview:photos index:index];
    svc.hideToolBar = hideToolBar;
    
    media_weak(self);
    __weak typeof(svc.navigationController) weakNav = svc.navigationController;
    [svc setPreviewNetImageBlock:^(NSArray *photos, MediaPickProgressCompletion _Nullable progress) {
        media_strong(weakSelf);
        __strong typeof(weakNav) strongNav = weakNav;
        if (completion) {
            completion(photos);
        }
        [strongSelf hide];
        [strongNav dismissViewControllerAnimated:YES completion:nil];
    }];
    svc.cancelPreviewBlock = ^{
        media_strong(weakSelf);
        [strongSelf hide];
    };
}

- (void)loadPhotoFromAlbum
{
    [self.arrDataSources removeAllObjects];
    
    [self.arrDataSources addObjectsFromArray:[MediaPhotoManager getAllAssetInPhotoAlbumWithAscending:NO limitCount:self.configuration.maxPreviewCount allowSelectVideo:self.configuration.allowSelectVideo allowSelectImage:self.configuration.allowSelectImage allowSelectGif:self.configuration.allowSelectGif allowSelectLivePhoto:self.configuration.allowSelectLivePhoto]];
    [MediaPhotoManager markSelcectModelInArr:self.arrDataSources selArr:self.arrSelectedModels];
    [self.collectionView reloadData];
}

#pragma mark - 显示隐藏视图及相关动画
- (void)resetSubViewState
{
    self.hidden = ![MediaPhotoManager havePhotoLibraryAuthority] || !self.preview;
    [self changeCancelBtnTitle];
//    [self.collectionView setContentOffset:CGPointZero];
}

- (void)show
{
    self.frame = self.sender.view.bounds;
    [self.collectionView setContentOffset:CGPointZero];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (!self.superview) {
        [self.sender.view addSubview:self];
    }
    
    if (self.sender.tabBarController.tabBar && self.sender.tabBarController.tabBar.hidden == NO) {
        self.senderTabBarIsShow = YES;
        self.sender.tabBarController.tabBar.hidden = YES;
    }
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        double flag = .0;
        if (self.senderTabBarIsShow) {
            flag = 49;
        }
        inset = self.sender.view.safeAreaInsets;
        inset.bottom -= flag;
        [self.verBottomSpace setConstant:inset.bottom];
    }
    if (self.animate) {
        __block CGRect frame = self.baseView.frame;
        frame.origin.y = kMediaViewHeight;
        self.baseView.frame = frame;
        [UIView animateWithDuration:0.2 animations:^{
            frame.origin.y -= kBaseViewHeight;
            self.baseView.frame = frame;
        } completion:nil];
    }
}

- (void)hide
{
    if (self.animate) {
        UIEdgeInsets inset = UIEdgeInsetsZero;
        if (@available(iOS 11, *)) {
            inset = self.sender.view.safeAreaInsets;
        }
        __block CGRect frame = self.baseView.frame;
        frame.origin.y += (kBaseViewHeight+inset.bottom);
        [UIView animateWithDuration:0.2 animations:^{
            self.baseView.frame = frame;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            [UIApplication sharedApplication].statusBarHidden = self.previousStatusBarIsHidden;
            [self removeFromSuperview];
        }];
    } else {
        self.hidden = YES;
        [UIApplication sharedApplication].statusBarHidden = self.previousStatusBarIsHidden;
        [self removeFromSuperview];
    }
    if (self.senderTabBarIsShow) {
        self.sender.tabBarController.tabBar.hidden = NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self hide];
}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.baseView];
    if (pan.state == UIGestureRecognizerStateBegan) {
        if (!CGRectContainsPoint(self.collectionView.frame, point)) {
            _panBeginPoint = CGPointZero;
            return;
        }
        _panBeginPoint = [pan locationInView:self.collectionView];
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (CGPointEqualToPoint(_panBeginPoint, CGPointZero)) {
            return;
        }
        
        CGPoint cp = [pan locationInView:self.collectionView];
        
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:_panBeginPoint];
        
        if (!indexPath) return;
        
        if (!_panView) {
            if (cp.y > _panBeginPoint.y) {
                _panBeginPoint = CGPointZero;
                return;
            }
            
            _panModel = self.arrDataSources[indexPath.row];
            
            MediaCollectionCell *cell = (MediaCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            _panCell = cell;
            _panView = [[UIImageView alloc] initWithFrame:cell.bounds];
            _panView.image = cell.imageView.image;
            
            cell.imageView.image = nil;
            
            [self addSubview:_panView];
        }
        
        _panView.center = [self convertPoint:point fromView:self.baseView];
    } else if (pan.state == UIGestureRecognizerStateCancelled ||
               pan.state == UIGestureRecognizerStateEnded) {
        if (!_panView) return;
        
        CGRect panViewRect = [self.baseView convertRect:_panView.frame fromView:self];
        BOOL callBack = NO;
        if (CGRectGetMidY(panViewRect) < -10) {
            //如果往上拖动距离中心点与collectionview间距大于10，则回调
            [self requestSelPhotos:nil data:@[_panModel] hideAfterCallBack:NO];
            callBack = YES;
        }
        
        _panModel = nil;
        if (!callBack) {
            CGRect toRect = [self convertRect:_panCell.frame fromView:self.collectionView];
            [UIView animateWithDuration:0.25 animations:^{
                _panView.frame = toRect;
            } completion:^(BOOL finished) {
                _panCell.imageView.image = _panView.image;
                _panCell = nil;
                [_panView removeFromSuperview];
                _panView = nil;
            }];
        } else {
            _panCell.imageView.image = _panView.image;
            _panCell.imageView.frame = CGRectZero;
            _panCell.imageView.center = _panCell.contentView.center;
            [_panView removeFromSuperview];
            _panView = nil;
            [UIView animateWithDuration:0.25 animations:^{
                _panCell.imageView.frame = _panCell.contentView.frame;
            } completion:^(BOOL finished) {
                _panCell = nil;
            }];
        }
    }
}

#pragma mark - UIButton Action
- (IBAction)btnCamera_Click:(id)sender
{
    if (![MediaPhotoManager haveCameraAuthority]) {
        NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(MediaPhotoBrowserNoCameraAuthorityText), kAPPName];
        ShowAlert(message, self.sender);
        [self hide];
        return;
    }
    if (self.configuration.useSystemCamera) {
        //系统相机拍照
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.videoQuality = UIImagePickerControllerQualityTypeLow;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.sender showDetailViewController:picker sender:nil];
        }
    } else {
        if (![MediaPhotoManager haveMicrophoneAuthority]) {
            NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(MediaPhotoBrowserNoMicrophoneAuthorityText), kAPPName];
            ShowAlert(message, self.sender);
            [self hide];
            return;
        }
        MediaCustomCamera *camera = [[MediaCustomCamera alloc] init];
        camera.allowRecordVideo = self.configuration.allowRecordVideo;
        camera.sessionPreset = self.configuration.sessionPreset;
        camera.videoType = self.configuration.exportVideoType;
        camera.circleProgressColor = self.configuration.bottomBtnsNormalTitleColor;
        camera.maxRecordDuration = self.configuration.maxRecordDuration;
        media_weak(self);
        camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
            media_strong(weakSelf);
            [strongSelf saveImage:image videoUrl:videoUrl];
        };
        [self.sender showDetailViewController:camera sender:nil];
    }
}

- (IBAction)btnPhotoLibrary_Click:(id)sender
{
    if (![MediaPhotoManager havePhotoLibraryAuthority]) {
        [self showNoAuthorityVC];
    } else {
        self.animate = NO;
        [self pushThumbnailViewController];
    }
}

- (IBAction)btnCancel_Click:(id)sender
{
    if (self.arrSelectedModels.count) {
        [self requestSelPhotos:nil data:self.arrSelectedModels hideAfterCallBack:YES];
        return;
    }
    [self hide];
}

- (void)changeCancelBtnTitle
{
    if (self.arrSelectedModels.count > 0) {
        [self.btnCancel setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(MediaPhotoBrowserDoneText), self.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:self.configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
    } else {
        [self.btnCancel setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCancelText) forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 请求所选择图片、回调
- (void)requestSelPhotos:(UIViewController *)vc data:(NSArray<MediaPhotoModel *> *)data hideAfterCallBack:(BOOL)hide
{
    if (data.count == 0) {
        [vc dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
    [hud show];
    
    if (!self.configuration.shouldAnialysisAsset) {
        NSMutableArray *assets = [NSMutableArray arrayWithCapacity:data.count];
        for (MediaPhotoModel *m in data) {
            [assets addObject:m.asset];
        }
        [hud hide];
        if (self.selectImageBlock) {
            self.selectImageBlock(nil, assets, self.isSelectOriginalPhoto, nil);
            [self.arrSelectedModels removeAllObjects];
        }
        if (hide) {
            [self hide];
            [vc dismissViewControllerAnimated:YES completion:nil];
        }
        return;
    }
    
    __block NSMutableArray *photos = [NSMutableArray arrayWithCapacity:data.count];
    __block NSMutableArray *assets = [NSMutableArray arrayWithCapacity:data.count];
    for (int i = 0; i < data.count; i++) {
        [photos addObject:@""];
        [assets addObject:@""];
    }
    
    media_weak(self);
    for (int i = 0; i < data.count; i++) {
        MediaPhotoModel *model = data[i];
        [MediaPhotoManager requestSelectedImageForAsset:model isOriginal:self.isSelectOriginalPhoto allowSelectGif:self.configuration.allowSelectGif completion:^(UIImage *image, NSDictionary *info) {
            if ([[info objectForKey:PHImageResultIsDegradedKey] boolValue]) return;
            
            media_strong(weakSelf);
            if (image) {
                [photos replaceObjectAtIndex:i withObject:[MediaPhotoManager scaleImage:image original:strongSelf->_isSelectOriginalPhoto]];
                [assets replaceObjectAtIndex:i withObject:model.asset];
            }
            
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) {
                    return;
                }
            }
            
            [hud hide];
            if (strongSelf.selectImageBlock) {
                strongSelf.selectImageBlock(photos, assets, strongSelf.isSelectOriginalPhoto,nil);
                [strongSelf.arrSelectedModels removeAllObjects];
            }
            if (hide) {
                [strongSelf.arrDataSources removeAllObjects];
                [strongSelf hide];
                [vc dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.arrDataSources.count == 0) {
        self.placeholderLabel.hidden = NO;
    } else {
        self.placeholderLabel.hidden = YES;
    }
    return self.arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCollectionCell" forIndexPath:indexPath];
    
    MediaPhotoModel *model = self.arrDataSources[indexPath.row];
    
    media_weak(self);
    __weak typeof(cell) weakCell = cell;
    cell.selectedBlock = ^(BOOL selected) {
        media_strong(weakSelf);
        __strong typeof(weakCell) strongCell = weakCell;
        if (!selected) {
            //选中
            if (strongSelf.arrSelectedModels.count >= strongSelf.configuration.maxSelectCount) {
                ShowToastLong(GetLocalLanguageTextValue(MediaPhotoBrowserMaxSelectCountText), strongSelf.configuration.maxSelectCount);
                return;
            }
            if (strongSelf.arrSelectedModels.count > 0) {
                MediaPhotoModel *sm = strongSelf.arrSelectedModels.firstObject;
                if (!strongSelf.configuration.allowMixSelect &&
                    ((model.type < MediaAssetMediaTypeVideo && sm.type == MediaAssetMediaTypeVideo) || (model.type == MediaAssetMediaTypeVideo && sm.type < MediaAssetMediaTypeVideo))) {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserCannotSelectVideo));
                    return;
                }
            }
            if (![MediaPhotoManager judgeAssetisInLocalAblum:model.asset]) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowseriCloudPhotoText));
                return;
            }
            if (model.type == MediaAssetMediaTypeVideo && GetDuration(model.duration) > strongSelf.configuration.maxVideoDuration) {
                ShowToastLong(GetLocalLanguageTextValue(MediaPhotoBrowserMaxVideoDurationText), strongSelf.configuration.maxVideoDuration);
                return;
            }
            
            if (![strongSelf shouldDirectEdit:model]) {
                model.selected = YES;
                [strongSelf.arrSelectedModels addObject:model];
                strongCell.btnSelect.selected = YES;
            }
        } else {
            strongCell.btnSelect.selected = NO;
            model.selected = NO;
            for (MediaPhotoModel *m in strongSelf.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [strongSelf.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
        
        if (strongSelf.configuration.showSelectedMask) {
            strongCell.topView.hidden = !model.isSelected;
        }
        [strongSelf changeCancelBtnTitle];
    };
    
    cell.allSelectGif = self.configuration.allowSelectGif;
    cell.allSelectLivePhoto = self.configuration.allowSelectLivePhoto;
    cell.showSelectBtn = self.configuration.showSelectBtn;
    cell.cornerRadio = self.configuration.cellCornerRadio;
    cell.showMask = self.configuration.showSelectedMask;
    cell.maskColor = self.configuration.selectedMaskColor;
    cell.model = model;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaPhotoModel *model = self.arrDataSources[indexPath.row];
    return [self getSizeWithAsset:model.asset];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaPhotoModel *model = self.arrDataSources[indexPath.row];
    
    if ([self shouldDirectEdit:model]) return;
    
    if (self.arrSelectedModels.count > 0) {
        MediaPhotoModel *sm = self.arrSelectedModels.firstObject;
        if (!self.configuration.allowMixSelect &&
            ((model.type < MediaAssetMediaTypeVideo && sm.type == MediaAssetMediaTypeVideo) || (model.type == MediaAssetMediaTypeVideo && sm.type < MediaAssetMediaTypeVideo))) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserCannotSelectVideo));
            return;
        }
    }
    
    BOOL allowSelImage = !(model.type==MediaAssetMediaTypeVideo)?YES:self.configuration.allowMixSelect;
    BOOL allowSelVideo = model.type==MediaAssetMediaTypeVideo?YES:self.configuration.allowMixSelect;
    
    NSArray *arr = [MediaPhotoManager getAllAssetInPhotoAlbumWithAscending:self.configuration.sortAscending limitCount:NSIntegerMax allowSelectVideo:allowSelVideo allowSelectImage:allowSelImage allowSelectGif:self.configuration.allowSelectGif allowSelectLivePhoto:self.configuration.allowSelectLivePhoto];
    
    NSMutableArray *selIdentifiers = [NSMutableArray array];
    for (MediaPhotoModel *m in self.arrSelectedModels) {
        [selIdentifiers addObject:m.asset.localIdentifier];
    }
    
    int i = 0;
    BOOL isFind = NO;
    for (MediaPhotoModel *m in arr) {
        if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
            isFind = YES;
        }
        if ([selIdentifiers containsObject:m.asset.localIdentifier]) {
            m.selected = YES;
        }
        if (!isFind) {
            i++;
        }
    }
    
    [self pushBigImageViewControllerWithModels:arr index:i];
}

- (BOOL)shouldDirectEdit:(MediaPhotoModel *)model
{
    //当前点击图片可编辑
    BOOL editImage = self.configuration.editAfterSelectThumbnailImage && self.configuration.allowEditImage && self.configuration.maxSelectCount == 1 && model.type < MediaAssetMediaTypeVideo;
    //当前点击视频可编辑
    BOOL editVideo = self.configuration.editAfterSelectThumbnailImage && self.configuration.allowEditVideo && model.type == MediaAssetMediaTypeVideo && self.configuration.maxSelectCount == 1 && round(model.asset.duration) >= self.configuration.maxEditVideoTime;
    //当前未选择图片 或已经选择了一张并且点击的是已选择的图片
    BOOL flag = self.arrSelectedModels.count == 0 || (self.arrSelectedModels.count == 1 && [self.arrSelectedModels.firstObject.asset.localIdentifier isEqualToString:model.asset.localIdentifier]);
    
    if (editImage && flag) {
        [self pushEditVCWithModel:model];
    } else if (editVideo && flag) {
        [self pushEditVideoVCWithModel:model];
    }
    
    return self.configuration.editAfterSelectThumbnailImage && self.configuration.maxSelectCount == 1 && (self.configuration.allowEditImage || self.configuration.allowEditVideo);
}

#pragma mark - 显示无权限视图
- (void)showNoAuthorityVC
{
    //无相册访问权限
    MediaNoAuthorityViewController *nvc = [[MediaNoAuthorityViewController alloc] init];
    [self.sender showDetailViewController:[self getImageNavWithRootVC:nvc] sender:nil];
}

- (MediaImageNavigationController *)getImageNavWithRootVC:(UIViewController *)rootVC
{
    MediaImageNavigationController *nav = [[MediaImageNavigationController alloc] initWithRootViewController:rootVC];
    media_weak(self);
    __weak typeof(MediaImageNavigationController *) weakNav = nav;
    [nav setCallSelectImageBlock:^(MediaPickProgressCompletion  _Nullable progress) {
        media_strong(weakSelf);
        strongSelf.isSelectOriginalPhoto = weakNav.isSelectOriginalPhoto;
        [strongSelf.arrSelectedModels removeAllObjects];
        [strongSelf.arrSelectedModels addObjectsFromArray:weakNav.arrSelectedModels];
        [strongSelf requestSelPhotos:weakNav data:strongSelf.arrSelectedModels hideAfterCallBack:YES];
    }];
    [nav setCallSelectClipImageBlock:^(UIImage * _Nullable image, PHAsset * _Nullable phAsset, MediaPickProgressCompletion  _Nullable progressCompletion) {
        media_strong(weakSelf);
        if (strongSelf.selectImageBlock) {
//            strongSelf.selectImageBlock(@[image], @[phAsset], NO, progress);
            strongSelf.selectImageBlock(@[image], @[phAsset], NO, ^(BOOL finished, BOOL hideAfter, float progress, NSString * _Nullable errorDesc) {
                if (progressCompletion) {
                    progressCompletion(finished, hideAfter, progress, errorDesc);
                }
                if (hideAfter) {
                    [weakNav dismissViewControllerAnimated:YES completion:nil];
                    [strongSelf hide];
                }
            });
        }else{
            [weakNav dismissViewControllerAnimated:YES completion:nil];
            [strongSelf hide];
        }
        
    }];
    
    [nav setCancelBlock:^{
        media_strong(weakSelf);
        [strongSelf hide];
    }];

    nav.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    nav.previousStatusBarStyle = self.previousStatusBarStyle;
    nav.configuration = self.configuration;
    [nav.arrSelectedModels removeAllObjects];
    [nav.arrSelectedModels addObjectsFromArray:self.arrSelectedModels];
    
    return nav;
}

//预览界面
- (void)pushThumbnailViewController
{
    MediaPhotoBrowser *photoBrowser = [[MediaPhotoBrowser alloc] initWithStyle:UITableViewStylePlain];
    MediaImageNavigationController *nav = [self getImageNavWithRootVC:photoBrowser];
    MediaThumbnailViewController *tvc = [[MediaThumbnailViewController alloc] init];
    [nav pushViewController:tvc animated:YES];
    [self.sender showDetailViewController:nav sender:nil];
}

//查看大图界面
- (void)pushBigImageViewControllerWithModels:(NSArray<MediaPhotoModel *> *)models index:(NSInteger)index
{
    MediaShowBigImgViewController *svc = [[MediaShowBigImgViewController alloc] init];
    MediaImageNavigationController *nav = [self getImageNavWithRootVC:svc];
    
    svc.models = models;
    svc.selectIndex = index;
    media_weak(self);
    [svc setBtnBackBlock:^(NSArray<MediaPhotoModel *> *selectedModels, BOOL isOriginal) {
        media_strong(weakSelf);
        [MediaPhotoManager markSelcectModelInArr:strongSelf.arrDataSources selArr:selectedModels];
        strongSelf.isSelectOriginalPhoto = isOriginal;
        [strongSelf.arrSelectedModels removeAllObjects];
        [strongSelf.arrSelectedModels addObjectsFromArray:selectedModels];
        [strongSelf.collectionView reloadData];
        [strongSelf changeCancelBtnTitle];
    }];
    
    [self.sender showDetailViewController:nav sender:nil];
}

- (MediaShowBigImgViewController *)pushBigImageToPreview:(NSArray *)photos index:(NSInteger)index
{
    MediaShowBigImgViewController *svc = [[MediaShowBigImgViewController alloc] init];
    MediaImageNavigationController *nav = [self getImageNavWithRootVC:svc];
    nav.configuration.showSelectBtn = YES;
    svc.selectIndex = index;
    svc.arrSelPhotos = [NSMutableArray arrayWithArray:photos];
    svc.models = self.arrSelectedModels;
    
    self.preview = NO;
    [self.sender.view addSubview:self];
    [self.sender showDetailViewController:nav sender:nil];
    
    return svc;
}

- (void)pushEditVCWithModel:(MediaPhotoModel *)model
{
    MediaEditImageController *vc = [[MediaEditImageController alloc] init];
    MediaImageNavigationController *nav = [self getImageNavWithRootVC:vc];
    [nav.arrSelectedModels addObject:model];
    vc.model = model;
    [self.sender showDetailViewController:nav sender:nil];
}

- (void)pushEditVideoVCWithModel:(MediaPhotoModel *)model
{
    MediaEditVideoController *vc = [[MediaEditVideoController alloc] init];
    MediaImageNavigationController *nav = [self getImageNavWithRootVC:vc];
    [nav.arrSelectedModels addObject:model];
    vc.model = model;
    [self.sender showDetailViewController:nav sender:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self saveImage:image videoUrl:nil];
    }];
}

- (void)saveImage:(UIImage *)image videoUrl:(NSURL *)videoUrl
{
    MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
    [hud show];
    media_weak(self);
    if (image) {
        [MediaPhotoManager saveImageToAblum:image completion:^(BOOL suc, PHAsset *asset) {
            media_strong(weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (suc) {
                    MediaPhotoModel *model = [MediaPhotoModel modelWithAsset:asset type:MediaAssetMediaTypeImage duration:nil];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserSaveImageErrorText));
                }
                [hud hide];
            });
        }];
    } else if (videoUrl) {
        [MediaPhotoManager saveVideoToAblum:videoUrl completion:^(BOOL suc, PHAsset *asset) {
            media_strong(weakSelf);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (suc) {
                    MediaPhotoModel *model = [MediaPhotoModel modelWithAsset:asset type:MediaAssetMediaTypeVideo duration:nil];
                    model.duration = [MediaPhotoManager getDuration:asset];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserSaveVideoFailed));
                }
                [hud hide];
            });
        }];
    }
}

- (void)handleDataArray:(MediaPhotoModel *)model
{
    [self.arrDataSources insertObject:model atIndex:0];
    [self.arrDataSources removeLastObject];
    if (self.configuration.maxSelectCount > 1 && self.arrSelectedModels.count < self.configuration.maxSelectCount) {
        model.selected = YES;
        [self.arrSelectedModels addObject:model];
    } else if (self.configuration.maxSelectCount == 1 && !self.arrSelectedModels.count) {
        if (![self shouldDirectEdit:model]) {
            model.selected = YES;
            [self.arrSelectedModels addObject:model];
            [self requestSelPhotos:nil data:self.arrSelectedModels hideAfterCallBack:YES];
            return;
        }
    }
    [self.collectionView reloadData];
    [self changeCancelBtnTitle];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 获取图片及图片尺寸的相关方法
- (CGSize)getSizeWithAsset:(PHAsset *)asset
{
    CGFloat width  = (CGFloat)asset.pixelWidth;
    CGFloat height = (CGFloat)asset.pixelHeight;
    CGFloat scale = MAX(0.5, width/height);
    
    return CGSizeMake(self.collectionView.frame.size.height*scale, self.collectionView.frame.size.height);
}

@end
