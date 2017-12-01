//
//  MediaLargeImageViewController.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaLargeImageViewController.h"
#import "MediaEditImageViewController.h"
#import "MediaEditVideoViewController.h"
#import "MediaToast.h"
#import "MediaLargeImageCell.h"
#import "MediaProgressHUD.h"

@interface MediaLargeImageViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
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

@implementation MediaLargeImageViewController

 -  (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@" -  -  -  -  %s", __FUNCTION__);
}

 -  (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _isFirstAppear = YES;
    _currentPage = self.selectIndex + 1;
    _indexBeforeRotation = self.selectIndex;
    
    [self initCollectionView];
    [self initNavView];
    [self initBottomView];
    [self resetDontBtnState];
    [self resetEditBtnState];
    [self resetOriginalBtnState];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

 -  (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (!_isFirstAppear) {
        return;
    }
    
    [_collectionView setContentOffset:CGPointMake((kMediaScreenWidth + kItemMargin)*_indexBeforeRotation, 0)];
}

 -  (void)viewDidAppear:(BOOL)animated
{
    if (!_isFirstAppear) {
        return;
    }
    _isFirstAppear = NO;
    [self reloadCurrentCell];
}

 -  (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    _layout.minimumLineSpacing = kItemMargin;
    _layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    _layout.itemSize = CGSizeMake(kMediaScreenWidth, kMediaScreenHeight);
    [_collectionView setCollectionViewLayout:_layout];
    
    _collectionView.frame = CGRectMake( - kItemMargin/2, 0, kMediaScreenWidth + kItemMargin, kMediaScreenHeight);
    
    [_collectionView setContentOffset:CGPointMake((kMediaScreenWidth + kItemMargin)*_indexBeforeRotation, 0)];
    
    //nav view
    CGFloat navHeight = inset.top + 44;
    CGRect navFrame = _hideNavBar?CGRectMake(0,  - navHeight, kMediaScreenWidth, navHeight):CGRectMake(0, 0, kMediaScreenWidth, navHeight);
    _navView.frame = navFrame;
    
    _btnBack.frame = CGRectMake(inset.left, inset.top, 60, 44);
    _indexLabel.frame = CGRectMake(kMediaScreenWidth/2 - 50, inset.top, 100, 44);
    _navRightBtn.frame = CGRectMake(kMediaScreenWidth - 40 - inset.right, inset.top + (44 - 25)/2, 25, 25);
    
    //底部view
    CGRect frame = _hideNavBar?CGRectMake(0, kMediaScreenHeight, kMediaScreenWidth, 44 + inset.bottom):CGRectMake(0, kMediaScreenHeight - 44 - inset.bottom, kMediaScreenWidth, 44 + inset.bottom);
    _bottomView.frame = frame;
    
    CGFloat btnOriWidth = 25;
    _btnOriginalPhoto.frame = CGRectMake(12 + inset.left, 7, btnOriWidth + 25, 30);
    self.labPhotosBytes.frame = CGRectMake(CGRectGetMaxX(_btnOriginalPhoto.frame) + 5, 7, 80, 30);
    _btnEdit.frame = CGRectMake(frame.size.width/2 - 30, 7, 60, 30);
    _btnDone.frame = CGRectMake(frame.size.width - 82 - inset.right, 7, 70, 30);
}

#pragma mark  -  设备旋转
 -  (void)deviceOrientationChanged:(NSNotification *)notify
{
    //    NSLog(@"%s %@", __FUNCTION__, NSStringFromCGRect(self.view.bounds));
    _indexBeforeRotation = _currentPage  -  1;
}

 -  (void)setModels:(NSArray<MediaModel *> *)models
{
    _models = models;
    //如果预览网络图片则返回
    if (models.firstObject.assetType == MediaAssetTypeNetImage) {
        return;
    }
    if (self.arrSelPhotos) {
        _arrSelAssets = [NSMutableArray array];
        for (MediaModel *m in models) {
            [_arrSelAssets addObject:m.phAsset];
        }
        _arrSelAssetsBackup = _arrSelAssets.copy;
    }
}

 -  (void)setArrSelPhotos:(NSMutableArray *)arrSelPhotos
{
    _arrSelPhotos = arrSelPhotos;
    _arrSelPhotosBackup = arrSelPhotos.copy;
}

 -  (void)initNavView
{
    _navView = [[UIView alloc] init];
    _navView.backgroundColor = [[MediaFactory sharedFactory].style.navBarColor colorWithAlphaComponent:.9];
    [self.view addSubview:_navView];
    
    _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnBack setImage:[UIImage imageNamed:@"navBackBtn"] forState:UIControlStateNormal];
    [_btnBack setImageEdgeInsets:UIEdgeInsetsMake(0,  -10, 0, 0)];
    [_btnBack addTarget:self action:@selector(btnBack_Click) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_btnBack];
    
    _indexLabel = [[UILabel alloc] init];
    _indexLabel.font = [UIFont systemFontOfSize:18];
    _indexLabel.textColor = [MediaFactory sharedFactory].style.navTitleColor;
    _indexLabel.textAlignment = NSTextAlignmentCenter;
    _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_currentPage, (unsigned long)self.models.count];
    [_navView addSubview:_indexLabel];
    
    if (![MediaFactory sharedFactory].tool.showSelectBtn || self.hideToolBar) {
        return;
    }
    
    //right nav btn
    _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navRightBtn.frame = CGRectMake(0, 0, 25, 25);
    UIImage *normalImg = [UIImage imageNamed:@"btn_circle"];
    UIImage *selImg = [UIImage imageNamed:@"btn_selected"];
    [_navRightBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_navRightBtn setBackgroundImage:selImg forState:UIControlStateSelected];
    [_navRightBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:_navRightBtn];
    
    if (self.models.count == 1) {
        _navRightBtn.selected = self.models.firstObject.isSelected;
    }
    MediaModel *model = self.models[_currentPage - 1];
    _navRightBtn.selected = model.isSelected;
}

#pragma mark  -  初始化CollectionView
 -  (void)initCollectionView
{
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [_collectionView registerClass:[MediaLargeImageCell class] forCellWithReuseIdentifier:@"MediaLargeImageCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_collectionView];
}

 -  (void)initBottomView
{
    if (self.hideToolBar) return;
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kMediaScreenHeight  -  44, kMediaScreenWidth, 44)];
    _bottomView.backgroundColor = [MediaFactory sharedFactory].style.bottomViewBgColor;
    
    if ([MediaFactory sharedFactory].tool.allowSelectOriginal) {
        _btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnOriginalPhoto setTitle:@"原图" forState:UIControlStateNormal];
        _btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
        [_btnOriginalPhoto setTitleColor:[MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor forState: UIControlStateNormal];
        UIImage *normalImg = [UIImage imageNamed:@"btn_original_circle"];
        UIImage *selImg = [UIImage imageNamed:@"btn_selected"];
        [_btnOriginalPhoto setImage:normalImg forState:UIControlStateNormal];
        [_btnOriginalPhoto setImage:selImg forState:UIControlStateSelected];
        [_btnOriginalPhoto setImageEdgeInsets:UIEdgeInsetsMake(0,  - 5, 0, 5)];
        [_btnOriginalPhoto addTarget:self action:@selector(btnOriginalImage_Click:) forControlEvents:UIControlEventTouchUpInside];
        _btnOriginalPhoto.selected = [MediaFactory sharedFactory].tool.isSelectOriginalPhoto;
        [self getPhotosBytes];
        [_bottomView addSubview:_btnOriginalPhoto];
        
        self.labPhotosBytes = [[UILabel alloc] init];
        self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
        self.labPhotosBytes.textColor = [MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor;
        [_bottomView addSubview:self.labPhotosBytes];
    }
    
    //编辑
    _btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
    _btnEdit.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnEdit setTitleColor:[MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
    _btnEdit.frame = CGRectMake(kMediaScreenWidth/2 - 30, 7, 60, 30);
    [_btnEdit addTarget:self action:@selector(btnEdit_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_btnEdit];
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnDone setTitle:@"完成" forState:UIControlStateNormal];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    _btnDone.layer.masksToBounds = YES;
    _btnDone.layer.cornerRadius = 3.0f;
    [_btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDone setBackgroundColor:[MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor];
    _btnDone.frame = CGRectMake(kMediaScreenWidth  -  82, 7, 70, 30);
    [_btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_btnDone];
    
    [self.view addSubview:_bottomView];
    
    if (self.arrSelPhotos) {
        //预览用户已确定选择的照片，隐藏原图按钮
        _btnOriginalPhoto.hidden = YES;
    }
    if (![MediaFactory sharedFactory].tool.allowEditImage && ![MediaFactory sharedFactory].tool.allowEditVideo) {
        _btnEdit.hidden = YES;
    }
}

#pragma mark  -  UIButton Actions
 -  (void)btnOriginalImage_Click:(UIButton *)btn
{
    
    [MediaFactory sharedFactory].tool.isSelectOriginalPhoto = btn.selected = !btn.selected;
    if (btn.selected) {
        [self getPhotosBytes];
        if (!_navRightBtn.isSelected) {
            if ([MediaFactory sharedFactory].tool.showSelectBtn &&
                [MediaFactory sharedFactory].tool.arrSelectedModels.count < [MediaFactory sharedFactory].tool.maxSelectCount) {
                [self navRightBtn_Click:_navRightBtn];
            }
        }
    } else {
        self.labPhotosBytes.text = nil;
    }
}

 -  (void)btnEdit_Click:(UIButton *)btn
{
    
    BOOL flag = !_navRightBtn.isSelected && [MediaFactory sharedFactory].tool.showSelectBtn &&
    [MediaFactory sharedFactory].tool.arrSelectedModels.count < [MediaFactory sharedFactory].tool.maxSelectCount;
    
    MediaModel *model = self.models[_currentPage - 1];
    if (flag) {
        [self navRightBtn_Click:_navRightBtn];
        if (![[MediaFactory sharedFactory].photo judgeAssetisInLocalAblum:model.phAsset]) {
            return;
        }
    }
    
    if (model.assetType == MediaAssetTypeVideo) {
        MediaEditVideoViewController *vc = [[MediaEditVideoViewController alloc] init];
        vc.model = model;
        [self.navigationController pushViewController:vc animated:NO];
    } else if (model.assetType == MediaAssetTypeImage ||
               (model.assetType == MediaAssetTypeGif && ![MediaFactory sharedFactory].tool.allowSelectGif) ||
               (model.assetType == MediaAssetTypeLivePhoto && ![MediaFactory sharedFactory].tool.allowSelectLivePhoto)) {
        MediaEditImageViewController *vc = [[MediaEditImageViewController alloc] init];
        vc.model = model;
        MediaLargeImageCell *cell = (MediaLargeImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage - 1 inSection:0]];
        vc.originalImage = cell.previewView.image;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

 -  (void)btnDone_Click:(UIButton *)btn
{
    
    if (!self.arrSelPhotos && [MediaFactory sharedFactory].tool.arrSelectedModels.count == 0) {
        MediaModel *model = self.models[_currentPage - 1];
        if (![[MediaFactory sharedFactory].photo judgeAssetisInLocalAblum:model.phAsset]) {
            ShowToastLong(@"%@", @"加载中...");
            return;
        }
        if (model.assetType == MediaAssetTypeVideo && [[MediaFactory sharedFactory].tool getDuration:model.duration] > [MediaFactory sharedFactory].tool.maxVideoDuration) {
            ShowToastLong(@"不能选择超过%ld秒的视频", (long)[MediaFactory sharedFactory].tool.maxVideoDuration);
            return;
        }
        
        [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:model];
    }
    if (self.arrSelPhotos && self.previewSelectedImageBlock) {
        self.previewSelectedImageBlock(self.arrSelPhotos, _arrSelAssets);
    } else if (self.arrSelPhotos && self.previewNetImageBlock) {
        self.previewNetImageBlock(self.arrSelPhotos);
    } else if ([MediaFactory sharedFactory].tool.callSelectImageBlock) {
        [MediaFactory sharedFactory].tool.callSelectImageBlock();
    }
}

 -  (void)btnBack_Click
{
    if (self.btnBackBlock) {
        self.btnBackBlock([MediaFactory sharedFactory].tool.arrSelectedModels, [MediaFactory sharedFactory].tool.isSelectOriginalPhoto);
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

 -  (void)navRightBtn_Click:(UIButton *)btn
{
    
    MediaModel *model = self.models[_currentPage - 1];
    if (!btn.selected) {
        //选中
        [btn.layer addAnimation:[[MediaFactory sharedFactory].tool viewStatusChangedAnimation] forKey:nil];
        if ([MediaFactory sharedFactory].tool.arrSelectedModels.count >= [MediaFactory sharedFactory].tool.maxSelectCount) {
            ShowToastLong(@"最多只能选择%ld张图片", (long)[MediaFactory sharedFactory].tool.maxSelectCount);
            return;
        }
        if (model.phAsset && ![[MediaFactory sharedFactory].photo judgeAssetisInLocalAblum:model.phAsset]) {
            ShowToastLong(@"%@", @"加载中，请稍后");
            return;
        }
        if (model.assetType == MediaAssetTypeVideo && [[MediaFactory sharedFactory].tool getDuration:model.duration] > [MediaFactory sharedFactory].tool.maxVideoDuration) {
            ShowToastLong(@"不能选择超过%ld秒的视频", (long)[MediaFactory sharedFactory].tool.maxVideoDuration);
            return;
        }
        
        model.selected = YES;
        [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:model];
        if (self.arrSelPhotos) {
            [self.arrSelPhotos addObject:_arrSelPhotosBackup[_currentPage - 1]];
            [_arrSelAssets addObject:_arrSelAssetsBackup[_currentPage - 1]];
        }
    } else {
        //移除
        model.selected = NO;
        for (MediaModel *m in [MediaFactory sharedFactory].tool.arrSelectedModels) {
            if ([m.phAsset.localIdentifier isEqualToString:model.phAsset.localIdentifier] ||
                [m.image isEqual:model.image] ||
                [m.imageUrl.absoluteString isEqualToString:model.imageUrl.absoluteString]) {
                [[MediaFactory sharedFactory].tool.arrSelectedModels removeObject:m];
                break;
            }
        }
        if (self.arrSelPhotos) {
            for (PHAsset *asset in _arrSelAssets) {
                if ([asset isEqual:_arrSelAssetsBackup[_currentPage - 1]]) {
                    [_arrSelAssets removeObject:asset];
                    break;
                }
            }
            [self.arrSelPhotos removeObject:_arrSelPhotosBackup[_currentPage - 1]];
        }
    }
    
    btn.selected = !btn.selected;
    [self getPhotosBytes];
    [self resetDontBtnState];
    [self resetEditBtnState];
}

 -  (void)showDownloadAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
        [hud show];
        
        MediaLargeImageCell *cell = (MediaLargeImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage - 1 inSection:0]];
        [[MediaFactory sharedFactory].photo saveToAlbumWithImage:cell.previewView.image completion:^(BOOL success, PHAsset * _Nullable asset) {
            [hud hide];
            if (!success) {
                ShowToastLong(@"%@", @"图片保存失败");
            }
        }];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:save];
    [alert addAction:cancel];
    [self showDetailViewController:alert sender:nil];
}

#pragma mark  -  更新按钮、导航条等显示状态
 -  (void)resetDontBtnState
{
    if ([MediaFactory sharedFactory].tool.arrSelectedModels.count > 0) {
        [_btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", @"确定", (long)[MediaFactory sharedFactory].tool.arrSelectedModels.count] forState:UIControlStateNormal];
    } else {
        [_btnDone setTitle:@"确定" forState:UIControlStateNormal];
    }
}

 -  (void)resetEditBtnState
{
    if (![MediaFactory sharedFactory].tool.allowEditImage && ![MediaFactory sharedFactory].tool.allowEditVideo) {
        return;
    }
    
    MediaModel *m = self.models[_currentPage - 1];
    BOOL flag = [m.phAsset.localIdentifier isEqualToString:[MediaFactory sharedFactory].tool.arrSelectedModels.firstObject.phAsset.localIdentifier];
    
    if (([MediaFactory sharedFactory].tool.arrSelectedModels.count == 0 ||
         ([MediaFactory sharedFactory].tool.arrSelectedModels.count <= 1 && flag)) &&
        
        (([MediaFactory sharedFactory].tool.allowEditImage &&
          (m.assetType == MediaAssetTypeImage ||
           (m.assetType == MediaAssetTypeGif && ![MediaFactory sharedFactory].tool.allowSelectGif) ||
           (m.assetType == MediaAssetTypeLivePhoto && ![MediaFactory sharedFactory].tool.allowSelectLivePhoto))) ||
         
         ([MediaFactory sharedFactory].tool.allowEditVideo && m.assetType == MediaAssetTypeVideo && round(m.phAsset.duration) >= [MediaFactory sharedFactory].tool.maxEditVideoTime))) {
            _btnEdit.hidden = NO;
        } else {
            _btnEdit.hidden = YES;
        }
}

 -  (void)resetOriginalBtnState
{
    
    MediaModel *m = self.models[_currentPage - 1];
    if ((m.assetType == MediaAssetTypeImage) ||
        (m.assetType == MediaAssetTypeGif && ![MediaFactory sharedFactory].tool.allowSelectGif) ||
        (m.assetType == MediaAssetTypeLivePhoto && ![MediaFactory sharedFactory].tool.allowSelectLivePhoto)) {
        _btnOriginalPhoto.hidden = NO;
        self.labPhotosBytes.hidden = NO;
    } else {
        _btnOriginalPhoto.hidden = YES;
        self.labPhotosBytes.hidden = YES;
    }
}

 -  (void)getPhotosBytes
{
    if (![MediaFactory sharedFactory].tool.isSelectOriginalPhoto) {
        return;
    }
    
    
    NSArray *arr = [MediaFactory sharedFactory].tool.showSelectBtn ? [MediaFactory sharedFactory].tool.arrSelectedModels : @[self.models[_currentPage - 1]];
    
    if (arr.count) {
        __weak typeof(self) weakSelf = self;
        [[MediaFactory sharedFactory].photo fetchPhotosBytesWithArray:arr completion:^(NSString * _Nullable photosBytes) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
        }];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

 -  (void)handlerSingleTap
{
    _hideNavBar = !_hideNavBar;
    
    _navView.hidden = _hideNavBar;
    _bottomView.hidden = _hideNavBar;
}

#pragma mark  -  UICollectionDataSource
 -  (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

 -  (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.models.count;
}

 -  (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((MediaLargeImageCell *)cell).previewView resetScale];
    ((MediaLargeImageCell *)cell).willDisplaying = YES;
}

 -  (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    [((MediaLargeImageCell *)cell).previewView handlerEndDisplaying];
}

 -  (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaLargeImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaLargeImageCell" forIndexPath:indexPath];
    MediaModel *model = self.models[indexPath.row];
    
    
    cell.showGif = [MediaFactory sharedFactory].tool.allowSelectGif;
    cell.showLivePhoto = [MediaFactory sharedFactory].tool.allowSelectLivePhoto;
    cell.model = model;
    __weak typeof(self) weakSelf = self;
    cell.singleTapCallBack = ^() {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf handlerSingleTap];
    };
    cell.longPressCallBack = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf showDownloadAlert];
    };
    
    return cell;
}

#pragma mark  -  UIScrollViewDelegate
 -  (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == (UIScrollView *)_collectionView) {
        MediaModel *m = [self getCurrentPageModel];
        if (!m) return;
        
        if (m.assetType == MediaAssetTypeGif ||
            m.assetType == MediaAssetTypeLivePhoto ||
            m.assetType == MediaAssetTypeVideo) {
            MediaLargeImageCell *cell = (MediaLargeImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage - 1 inSection:0]];
            [cell pausePlay];
        }
        
        if ([_modelIdentifile isEqualToString:m.phAsset.localIdentifier]) return;
        
        _modelIdentifile = m.phAsset.localIdentifier;
        //改变导航标题
        _indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)_currentPage, (long)self.models.count];
        
        _navRightBtn.selected = m.isSelected;
        
        [self resetOriginalBtnState];
        [self resetEditBtnState];
    }
}

 -  (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //单选模式下获取当前图片大小
    if (![MediaFactory sharedFactory].tool.showSelectBtn) {
        [self getPhotosBytes];
    }
    
    [self reloadCurrentCell];
}

 -  (void)reloadCurrentCell
{
    MediaModel *m = [self getCurrentPageModel];
    if (m.assetType == MediaAssetTypeGif ||
        m.assetType == MediaAssetTypeLivePhoto) {
        MediaLargeImageCell *cell = (MediaLargeImageCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentPage - 1 inSection:0]];
        [cell reloadGifLivePhoto];
    }
}

 -  (MediaModel *)getCurrentPageModel
{
    CGPoint offset = _collectionView.contentOffset;
    
    CGFloat page = offset.x/(kMediaScreenWidth + kItemMargin);
    if (ceilf(page) >= self.models.count) {
        return nil;
    }
    NSString *str = [NSString stringWithFormat:@"%.0f", page];
    _currentPage = str.integerValue  +  1;
    MediaModel *model = self.models[_currentPage - 1];
    return model;
}

/*
#pragma mark  -  Navigation

// In a storyboard - based application, you will often want to do a little preparation before navigation
 -  (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
