//
//  MediaShowBigImgViewController.m
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaShowBigImgViewController.h"
#import <Photos/Photos.h>
#import "MediaBigImageCell.h"
#import "MediaDefine.h"
#import "ToastUtils.h"
#import "MediaPhotoBrowser.h"
#import "MediaPhotoModel.h"
#import "MediaPhotoManager.h"
#import "MediaEditImageController.h"
#import "MediaEditVideoController.h"

@interface MediaShowBigImgViewController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    
    
    //自定义导航视图
    UIView *_navView;
    UIButton *_btnBack;
    UIButton *_navRightBtn;
    UILabel *_indexLabel;
    
    //底部view
    UIView   *_bottomView;
    UIButton *_btnOriginalPhoto;
    UIButton *_btnDone;
    //编辑按钮
    UIButton *_btnEdit;
    
    //双击的scrollView
    UIScrollView *_selectScrollView;
    NSInteger _currentPage;
    
    NSArray *_arrSelPhotosBackup;
    NSMutableArray *_arrSelAssets;
    NSArray *_arrSelAssetsBackup;
    
    BOOL _isFirstAppear;
    
    BOOL _hideNavBar;
    
    //设备旋转前的index
    NSInteger _indexBeforeRotation;
    UICollectionViewFlowLayout *_layout;
    
    NSString *_modelIdentifile;
}

@property (nonatomic, strong) UILabel *labPhotosBytes;

@end

@implementation MediaShowBigImgViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;

    _isFirstAppear = YES;
    _currentPage = self.selectIndex+1;
    _indexBeforeRotation = self.selectIndex;
    
    [self initCollectionView];
    [self initNavView];
    [self initBottomView];
    [self resetDontBtnState];
    [self resetEditBtnState];
    [self resetOriginalBtnState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (!_isFirstAppear) {
        return;
    }
    
    [_collectionView setContentOffset:CGPointMake((kMediaViewWidth+kMediaItemMargin)*_indexBeforeRotation, 0)];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_isFirstAppear) {
        return;
    }
    _isFirstAppear = NO;
    [self reloadCurrentCell];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    _layout.minimumLineSpacing = kMediaItemMargin;
    _layout.sectionInset = UIEdgeInsetsMake(0, kMediaItemMargin/2, 0, kMediaItemMargin/2);
    _layout.itemSize = CGSizeMake(kMediaViewWidth, kMediaViewHeight);
    [_collectionView setCollectionViewLayout:_layout];
    
    _collectionView.frame = CGRectMake(-kMediaItemMargin/2, 0, kMediaViewWidth+kMediaItemMargin, kMediaViewHeight);
    
    [_collectionView setContentOffset:CGPointMake((kMediaViewWidth+kMediaItemMargin)*_indexBeforeRotation, 0)];
    
    //nav view
    CGFloat navHeight = inset.top+44;
    CGRect navFrame = _hideNavBar?CGRectMake(0, -navHeight, kMediaViewWidth, navHeight):CGRectMake(0, 0, kMediaViewWidth, navHeight);
    _navView.frame = navFrame;
    
    _btnBack.frame = CGRectMake(inset.left, inset.top, 60, 44);
    _indexLabel.frame = CGRectMake(kMediaViewWidth/2-50, inset.top, 100, 44);
    _navRightBtn.frame = CGRectMake(kMediaViewWidth-40-inset.right, inset.top+(44-25)/2, 25, 25);
    
    //底部view
    CGRect frame = _hideNavBar?CGRectMake(0, kMediaViewHeight, kMediaViewWidth, 44+inset.bottom):CGRectMake(0, kMediaViewHeight-44-inset.bottom, kMediaViewWidth, 44+inset.bottom);
    _bottomView.frame = frame;
    
    CGFloat btnOriWidth = GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserOriginalText), 15, YES, 30);
    _btnOriginalPhoto.frame = CGRectMake(12+inset.left, 7, btnOriWidth+25, 30);
    self.labPhotosBytes.frame = CGRectMake(CGRectGetMaxX(_btnOriginalPhoto.frame)+5, 7, 80, 30);
    _btnEdit.frame = CGRectMake(frame.size.width/2-30, 7, 60, 30);
    _btnDone.frame = CGRectMake(frame.size.width-82-inset.right, 7, 70, 30);
}

#pragma mark - 设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
//    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    _indexBeforeRotation = _currentPage - 1;
}

- (void)setModels:(NSArray<MediaPhotoModel *> *)models
{
    _models = models;
    //如果预览网络图片则返回
    if (models.firstObject.type == MediaAssetMediaTypeNetImage) {
        return;
    }
    if (self.arrSelPhotos) {
        _arrSelAssets = [NSMutableArray array];
        for (MediaPhotoModel *m in models) {
            [_arrSelAssets addObject:m.asset];
        }
        _arrSelAssetsBackup = _arrSelAssets.copy;
    }
}

- (void)setArrSelPhotos:(NSMutableArray *)arrSelPhotos
{
    _arrSelPhotos = arrSelPhotos;
    _arrSelPhotosBackup = arrSelPhotos.copy;
}

- (void)initNavView
{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    _navView = [[UIView alloc] init];
    _navView.backgroundColor = [configuration.navBarColor colorWithAlphaComponent:.9];
    [self.view addSubview:_navView];
    
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnBack setImage:GetImageWithName(@"navBackBtn") forState:UIControlStateNormal];
    [_btnBack setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_btnBack addTarget:self action:@selector(btnBack_Click) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_btnBack];
    
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.font = [UIFont systemFontOfSize:18];
    _indexLabel.textColor = configuration.navTitleColor;
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", _currentPage, self.models.count];
    [_navView addSubview:_indexLabel];
    
    if (!configuration.showSelectBtn || self.hideToolBar) {
        return;
    }
    
    //right nav btn
    _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navRightBtn.frame = CGRectMake(0, 0, 25, 25);
    UIImage *normalImg = GetImageWithName(@"btn_circle");
    UIImage *selImg = GetImageWithName(@"btn_selected");
    [_navRightBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_navRightBtn setBackgroundImage:selImg forState:UIControlStateSelected];
    [_navRightBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navRightBtn];
    
    if (self.models.count == 1) {
        _navRightBtn.selected = self.models.firstObject.isSelected;
    }
    MediaPhotoModel *model = self.models[_currentPage-1];
    _navRightBtn.selected = model.isSelected;
}

#pragma mark - 初始化CollectionView
- (void)initCollectionView
{
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [_collectionView registerClass:[MediaBigImageCell class] forCellWithReuseIdentifier:@"MediaBigImageCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_collectionView];
}

- (void)initBottomView
{
    if (self.hideToolBar) return;
    
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMediaViewHeight - 44, kMediaViewWidth, 44)];
    _bottomView.backgroundColor = configuration.bottomViewBgColor;
    
    if (configuration.allowSelectOriginal) {
        _btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnOriginalPhoto setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserOriginalText) forState:UIControlStateNormal];
        _btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btnOriginalPhoto setTitleColor:configuration.bottomBtnsNormalTitleColor forState: UIControlStateNormal];
        UIImage *normalImg = GetImageWithName(@"btn_original_circle");
        UIImage *selImg = GetImageWithName(@"btn_selected");
        [_btnOriginalPhoto setImage:normalImg forState:UIControlStateNormal];
        [_btnOriginalPhoto setImage:selImg forState:UIControlStateSelected];
        [_btnOriginalPhoto setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
        [_btnOriginalPhoto addTarget:self action:@selector(btnOriginalImage_Click:) forControlEvents:UIControlEventTouchUpInside];
        _btnOriginalPhoto.selected = nav.isSelectOriginalPhoto;
        [self getPhotosBytes];
        [_bottomView addSubview:_btnOriginalPhoto];
        
        self.labPhotosBytes = [[UILabel alloc] init];
        self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
        self.labPhotosBytes.textColor = configuration.bottomBtnsNormalTitleColor;
        [_bottomView addSubview:self.labPhotosBytes];
    }
    
    //编辑
    _btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnEdit setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserEditText) forState:UIControlStateNormal];
    _btnEdit.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnEdit setTitleColor:configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
    _btnEdit.frame = CGRectMake(kMediaViewWidth/2-30, 7, 60, 30);
    [_btnEdit addTarget:self action:@selector(btnEdit_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_btnEdit];
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDone setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserDoneText) forState:UIControlStateNormal];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    _btnDone.layer.masksToBounds = YES;
    _btnDone.layer.cornerRadius = 3.0f;
    [_btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDone setBackgroundColor:configuration.bottomBtnsNormalTitleColor];
    _btnDone.frame = CGRectMake(kMediaViewWidth - 82, 7, 70, 30);
    [_btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_btnDone];
    
    [self.view addSubview:_bottomView];
    
    if (self.arrSelPhotos) {
        //预览用户已确定选择的照片，隐藏原图按钮
        _btnOriginalPhoto.hidden = YES;
    }
    if (!configuration.allowEditImage && !configuration.allowEditVideo) {
        _btnEdit.hidden = YES;
    }
}

#pragma mark - UIButton Actions
- (void)btnOriginalImage_Click:(UIButton *)btn
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    nav.isSelectOriginalPhoto = btn.selected = !btn.selected;
    if (btn.selected) {
        [self getPhotosBytes];
        if (!_navRightBtn.isSelected) {
            if (configuration.showSelectBtn &&
                nav.arrSelectedModels.count < configuration.maxSelectCount) {
                [self navRightBtn_Click:_navRightBtn];
            }
        }
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)btnEdit_Click:(UIButton *)btn
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    BOOL flag = !_navRightBtn.isSelected && configuration.showSelectBtn &&
    nav.arrSelectedModels.count < configuration.maxSelectCount;
    
    MediaPhotoModel *model = self.models[_currentPage-1];
    if (flag) {
        [self navRightBtn_Click:_navRightBtn];
        if (![MediaPhotoManager judgeAssetisInLocalAblum:model.asset]) {
            return;
        }
    }
    
    if (model.type == MediaAssetMediaTypeVideo) {
        MediaEditVideoController *vc = [[MediaEditVideoController alloc] init];
        vc.model = model;
        [self.navigationController pushViewController:vc animated:NO];
    } else if (model.type == MediaAssetMediaTypeImage ||
               (model.type == MediaAssetMediaTypeGif && !configuration.allowSelectGif) ||
               (model.type == MediaAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto)) {
        MediaEditImageController *vc = [[MediaEditImageController alloc] init];
        vc.model = model;
        MediaBigImageCell *cell = (MediaBigImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
        vc.oriImage = cell.previewView.image;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)btnDone_Click:(UIButton *)btn
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    if (!self.arrSelPhotos && nav.arrSelectedModels.count == 0) {
        MediaPhotoModel *model = self.models[_currentPage-1];
        if (![MediaPhotoManager judgeAssetisInLocalAblum:model.asset]) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserLoadingText));
            return;
        }
        if (model.type == MediaAssetMediaTypeVideo && GetDuration(model.duration) > configuration.maxVideoDuration) {
            ShowToastLong(GetLocalLanguageTextValue(MediaPhotoBrowserMaxVideoDurationText), configuration.maxVideoDuration);
            return;
        }
        
        [nav.arrSelectedModels addObject:model];
    }
    if (self.arrSelPhotos && self.previewSelectedImageBlock) {
        self.previewSelectedImageBlock(self.arrSelPhotos, _arrSelAssets, nil);
    } else if (self.arrSelPhotos && self.previewNetImageBlock) {
        self.previewNetImageBlock(self.arrSelPhotos, nil);
    } else if (nav.callSelectImageBlock) {
        nav.callSelectImageBlock(nil);
    }
}

- (void)btnBack_Click
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    if (self.btnBackBlock) {
        self.btnBackBlock(nav.arrSelectedModels, nav.isSelectOriginalPhoto);
    }
    
    if (self.cancelPreviewBlock) {
        self.cancelPreviewBlock();
    }
    
    UIViewController *vc = [self.navigationController popViewControllerAnimated:YES];
    //由于collectionView的frame的width是大于该界面的width，所以设置这个颜色是为了pop时候隐藏collectionView的黑色背景
    _collectionView.backgroundColor = [UIColor clearColor];
    if (!vc) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)navRightBtn_Click:(UIButton *)btn
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    MediaPhotoModel *model = self.models[_currentPage-1];
    if (!btn.selected) {
        //选中
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        if (nav.arrSelectedModels.count >= configuration.maxSelectCount) {
            ShowToastLong(GetLocalLanguageTextValue(MediaPhotoBrowserMaxSelectCountText), configuration.maxSelectCount);
            return;
        }
        if (model.asset && ![MediaPhotoManager judgeAssetisInLocalAblum:model.asset]) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserLoadingText));
            return;
        }
        if (model.type == MediaAssetMediaTypeVideo && GetDuration(model.duration) > configuration.maxVideoDuration) {
            ShowToastLong(GetLocalLanguageTextValue(MediaPhotoBrowserMaxVideoDurationText), configuration.maxVideoDuration);
            return;
        }
        
        model.selected = YES;
        [nav.arrSelectedModels addObject:model];
        if (self.arrSelPhotos) {
            [self.arrSelPhotos addObject:_arrSelPhotosBackup[_currentPage-1]];
            [_arrSelAssets addObject:_arrSelAssetsBackup[_currentPage-1]];
        }
    } else {
        //移除
        model.selected = NO;
        for (MediaPhotoModel *m in nav.arrSelectedModels) {
            if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier] ||
                [m.image isEqual:model.image] ||
                [m.url.absoluteString isEqualToString:model.url.absoluteString]) {
                [nav.arrSelectedModels removeObject:m];
                break;
            }
        }
        if (self.arrSelPhotos) {
            for (PHAsset *asset in _arrSelAssets) {
                if ([asset isEqual:_arrSelAssetsBackup[_currentPage-1]]) {
                    [_arrSelAssets removeObject:asset];
                    break;
                }
            }
            [self.arrSelPhotos removeObject:_arrSelPhotosBackup[_currentPage-1]];
        }
    }
    
    btn.selected = !btn.selected;
    [self getPhotosBytes];
    [self resetDontBtnState];
    [self resetEditBtnState];
}

- (void)showDownloadAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(MediaPhotoBrowserSaveText) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
        [hud show];
        
        MediaBigImageCell *cell = (MediaBigImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
        
        [MediaPhotoManager saveImageToAblum:cell.previewView.image completion:^(BOOL suc, PHAsset *asset) {
            [hud hide];
            if (!suc) {
                ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserSaveImageErrorText));
            }
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCancelText) style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:save];
    [alert addAction:cancel];
    [self showDetailViewController:alert sender:nil];
}

#pragma mark - 更新按钮、导航条等显示状态
- (void)resetDontBtnState
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    if (nav.arrSelectedModels.count > 0) {
        [_btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(MediaPhotoBrowserDoneText), nav.arrSelectedModels.count] forState:UIControlStateNormal];
    } else {
        [_btnDone setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserDoneText) forState:UIControlStateNormal];
    }
}

- (void)resetEditBtnState
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    if (!configuration.allowEditImage && !configuration.allowEditVideo) return;

    MediaPhotoModel *m = self.models[_currentPage-1];
    BOOL flag = [m.asset.localIdentifier isEqualToString:nav.arrSelectedModels.firstObject.asset.localIdentifier];
    
    if ((nav.arrSelectedModels.count == 0 ||
         (nav.arrSelectedModels.count <= 1 && flag)) &&
        
        ((configuration.allowEditImage &&
         (m.type == MediaAssetMediaTypeImage ||
         (m.type == MediaAssetMediaTypeGif && !configuration.allowSelectGif) ||
         (m.type == MediaAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto))) ||
        
        (configuration.allowEditVideo && m.type == MediaAssetMediaTypeVideo && round(m.asset.duration) >= configuration.maxEditVideoTime))) {
        _btnEdit.hidden = NO;
    } else {
        _btnEdit.hidden = YES;
    }
}

- (void)resetOriginalBtnState
{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    MediaPhotoModel *m = self.models[_currentPage-1];
    if ((m.type == MediaAssetMediaTypeImage) ||
         (m.type == MediaAssetMediaTypeGif && !configuration.allowSelectGif) ||
         (m.type == MediaAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto)) {
            _btnOriginalPhoto.hidden = NO;
            self.labPhotosBytes.hidden = NO;
    } else {
        _btnOriginalPhoto.hidden = YES;
        self.labPhotosBytes.hidden = YES;
    }
}

- (void)getPhotosBytes
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    if (!nav.isSelectOriginalPhoto) return;
    
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    NSArray *arr = configuration.showSelectBtn?nav.arrSelectedModels:@[self.models[_currentPage-1]];
    
    if (arr.count) {
        media_weak(self);
        [MediaPhotoManager getPhotosBytesWithArray:arr completion:^(NSString *photosBytes) {
            media_strong(weakSelf);
            strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
        }];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)handlerSingleTap
{
    _hideNavBar = !_hideNavBar;
    
    _navView.hidden = _hideNavBar;
    _bottomView.hidden = _hideNavBar;
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.models.count;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((MediaBigImageCell *)cell).previewView resetScale];
    ((MediaBigImageCell *)cell).willDisplaying = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((MediaBigImageCell *)cell).previewView handlerEndDisplaying];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaBigImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaBigImageCell" forIndexPath:indexPath];
    MediaPhotoModel *model = self.models[indexPath.row];
    
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    cell.showGif = configuration.allowSelectGif;
    cell.showLivePhoto = configuration.allowSelectLivePhoto;
    cell.model = model;
    media_weak(self);
    cell.singleTapCallBack = ^() {
        media_strong(weakSelf);
        [strongSelf handlerSingleTap];
    };
    cell.longPressCallBack = ^{
        media_strong(weakSelf);
        [strongSelf showDownloadAlert];
    };
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == (UIScrollView *)_collectionView) {
        MediaPhotoModel *m = [self getCurrentPageModel];
        if (!m) return;
        
        if (m.type == MediaAssetMediaTypeGif ||
            m.type == MediaAssetMediaTypeLivePhoto ||
            m.type == MediaAssetMediaTypeVideo) {
            MediaBigImageCell *cell = (MediaBigImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
            [cell pausePlay];
        }
        
        if ([_modelIdentifile isEqualToString:m.asset.localIdentifier]) return;
        
        _modelIdentifile = m.asset.localIdentifier;
        //改变导航标题
        _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", _currentPage, self.models.count];
        
        _navRightBtn.selected = m.isSelected;
        
        [self resetOriginalBtnState];
        [self resetEditBtnState];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //单选模式下获取当前图片大小
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    if (!configuration.showSelectBtn){
         [self getPhotosBytes];
    }
    
    [self reloadCurrentCell];
}

- (void)reloadCurrentCell
{
    MediaPhotoModel *m = [self getCurrentPageModel];
    if (m.type == MediaAssetMediaTypeGif ||
        m.type == MediaAssetMediaTypeLivePhoto) {
        MediaBigImageCell *cell = (MediaBigImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage-1 inSection:0]];
        [cell reloadGifLivePhoto];
    }
}

- (MediaPhotoModel *)getCurrentPageModel
{
    CGPoint offset = _collectionView.contentOffset;

    CGFloat page = offset.x/(kMediaViewWidth+kMediaItemMargin);
    if (ceilf(page) >= self.models.count) {
        return nil;
    }
    NSString *str = [NSString stringWithFormat:@"%.0f", page];
    _currentPage = str.integerValue + 1;
    MediaPhotoModel *model = self.models[_currentPage-1];
    return model;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    return configuration.statusBarStyle;
}

@end
