//
//  MediaCollectionViewController.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaCollectionViewController.h"
#import "MediaProgressHUD.h"
#import "MediaNavgationController.h"
#import "MediaEditImageViewController.h"
#import "MediaEditVideoViewController.h"
#import "MediaCollectionCell.h"
#import "MediaLargeImageCell.h"
#import "MediaToast.h"
#import "MediaExtension.h"
#import "MediaCamera.h"
#import "MediaLargeImageViewController.h"
#import "MediaCameraViewController.h"
#import "Media3DTouchViewController.h"

typedef enum {
    MediaSlideSelectTypeNone,
    MediaSlideSelectTypeSelect,
    MediaSlideSelectTypeCancel,
}MediaSlideSelectType;

@interface MediaCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerPreviewingDelegate>
{
    BOOL _isLayoutOK;
    
    //设备旋转前的第一个可视indexPath
    NSIndexPath *_visibleIndexPath;
    //是否切换横竖屏
    BOOL _switchOrientation;
    
    //开始滑动选择 或 取消
    BOOL _beginSelect;
    /**
     滑动选择 或 取消
     当初始滑动的cell处于未选择状态，则开始选择，反之，则开始取消选择
     */
    MediaSlideSelectType _selectType;
    /**开始滑动的indexPath*/
    NSIndexPath *_beginSlideIndexPath;
    /**最后滑动经过的index，开始的indexPath不计入，优化拖动手势计算，避免单个cell中冗余计算多次*/
    NSInteger _lastSlideIndex;
}

@property (nonatomic, strong) NSMutableArray<MediaModel *> *arrDataSources;
@property (nonatomic, assign) BOOL allowTakePhoto;
/**所有滑动经过的indexPath*/
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *arrSlideIndexPath;
/**所有滑动经过的indexPath的初始选择状态*/
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dicOriSelectStatus;
@end

@implementation MediaCollectionViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    NSLog(@"---- %s", __FUNCTION__);
}

- (NSMutableArray<MediaModel *> *)arrDataSources
{
    if (!_arrDataSources) {
        MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
        [hud show];
        
        if (!_albumListModel) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                __weak typeof(self) weakSelf = self;
                
                [[MediaFactory sharedFactory].photo fetchCameraRollAlbumList:[MediaFactory sharedFactory].tool.allowSelectVideo allowSelectImage:[MediaFactory sharedFactory].tool.allowSelectImage completion:^(MediaListModel *album) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                    strongSelf.albumListModel = album;
                    [[MediaFactory sharedFactory].photo markSelcectedModelInArrary:strongSelf.albumListModel.models selectedArray:[MediaFactory sharedFactory].tool.arrSelectedModels];
                    strongSelf.arrDataSources = [NSMutableArray arrayWithArray:strongSelf.albumListModel.models];
                    [hud hide];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([MediaFactory sharedFactory].tool.allowTakePhotoInLibrary && [MediaFactory sharedFactory].tool.allowSelectImage) {
                            strongSelf.allowTakePhoto = YES;
                        }
                        strongSelf.title = album.title;
                        [strongSelf.collectionView reloadData];
                        [strongSelf scrollToBottom];
                    });
                }];
            });
        } else {
            if ([MediaFactory sharedFactory].tool.allowTakePhotoInLibrary && [MediaFactory sharedFactory].tool.allowSelectImage && self.albumListModel.isCameraRoll) {
                self.allowTakePhoto = YES;
            }
            [[MediaFactory sharedFactory].photo markSelcectedModelInArrary:self.albumListModel.models selectedArray:[MediaFactory sharedFactory].tool.arrSelectedModels];
            _arrDataSources = [NSMutableArray arrayWithArray:self.albumListModel.models];
            [hud hide];
        }
    }
    return _arrDataSources;
}

- (NSMutableArray<NSIndexPath *> *)arrSlideIndexPath
{
    if (!_arrSlideIndexPath) {
        _arrSlideIndexPath = [NSMutableArray array];
    }
    return _arrSlideIndexPath;
}

- (NSMutableDictionary<NSString *, NSNumber *> *)dicOriSelectStatus
{
    if (!_dicOriSelectStatus) {
        _dicOriSelectStatus = [NSMutableDictionary dictionary];
    }
    return _dicOriSelectStatus;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.albumListModel.title;
    
    [self initNavBtn];
    [self setupCollectionView];
    [self setupBottomView];
    
    
    if ([MediaFactory sharedFactory].tool.allowSlideSelect) {
        //添加滑动选择手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [self.view addGestureRecognizer:pan];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self resetBottomBtnsStatus:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isLayoutOK = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    
    BOOL showBottomView = YES;
    if ([MediaFactory sharedFactory].tool.editAfterSelectThumbnailImage && [MediaFactory sharedFactory].tool.maxSelectCount == 1 && ([MediaFactory sharedFactory].tool.allowEditImage || [MediaFactory sharedFactory].tool.allowEditVideo)) {
        //点击后直接编辑则不需要下方工具条
        showBottomView = NO;
        inset.bottom = 0;
    }
    
    CGFloat bottomViewH = showBottomView ? 44 : 0;
    CGFloat bottomBtnH = 30;
    
    CGFloat width = kMediaScreenWidth-inset.left-inset.right;
    self.collectionView.frame = CGRectMake(inset.left, 0, width, kMediaScreenHeight-inset.bottom-bottomViewH);
    
    if (!showBottomView) return;
    
    self.bottomView.frame = CGRectMake(inset.left, kMediaScreenHeight-bottomViewH-inset.bottom, width, bottomViewH+inset.bottom);
    self.bline.frame = CGRectMake(0, 0, width, 1/[UIScreen mainScreen].scale);
    
    CGFloat offsetX = 12;
    if ([MediaFactory sharedFactory].tool.allowEditImage || [MediaFactory sharedFactory].tool.allowEditVideo) {
        self.btnEdit.frame = CGRectMake(offsetX, 7, 40, bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnEdit.frame) + 10;
    }
    self.btnPreView.frame = CGRectMake(offsetX, 7, 40, bottomBtnH);
    offsetX = CGRectGetMaxX(self.btnPreView.frame) + 10;
    
    if ([MediaFactory sharedFactory].tool.allowSelectOriginal) {
        self.btnOriginalPhoto.frame = CGRectMake(offsetX, 7, 40 + self.btnOriginalPhoto.imageView.frame.size.width, bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnOriginalPhoto.frame) + 5;
        
        self.labPhotosBytes.frame = CGRectMake(offsetX, 7, 80, bottomBtnH);
    }
    
    CGFloat doneWidth = 40;
    doneWidth = MAX(70, doneWidth);
    self.btnDone.frame = CGRectMake(width-doneWidth-12, 7, doneWidth, bottomBtnH);
    
    if (!_isLayoutOK && self.albumListModel) {
        [self scrollToBottom];
    } else if (_switchOrientation) {
        _switchOrientation = NO;
        [self.collectionView scrollToItemAtIndexPath:_visibleIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

#pragma mark - 设备旋转
- (void)deviceOrientationChanged:(NSNotification *)notify
{
    CGPoint pInView = [self.view convertPoint:CGPointMake(0, 70) toView:self.collectionView];
    _visibleIndexPath = [self.collectionView indexPathForItemAtPoint:pInView];
    _switchOrientation = YES;
}

- (BOOL)forceTouchAvailable
{
    if (@available(iOS 9.0, *)) {
        return self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    } else {
        return NO;
    }
}

- (void)scrollToBottom
{
    if (![MediaFactory sharedFactory].tool.sortAscending) {
        return;
    }
    if (self.arrDataSources.count > 0) {
        NSInteger index = self.arrDataSources.count-1;
        if (self.allowTakePhoto) {
            index += 1;
        }
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)resetBottomBtnsStatus:(BOOL)getBytes
{
    
    if ([MediaFactory sharedFactory].tool.arrSelectedModels.count > 0) {
        self.btnOriginalPhoto.enabled = YES;
        self.btnPreView.enabled = YES;
        self.btnDone.enabled = YES;
        if ([MediaFactory sharedFactory].tool.isSelectOriginalPhoto) {
            if (getBytes) [self getOriginalImageBytes];
        } else {
            self.labPhotosBytes.text = nil;
        }
        self.btnOriginalPhoto.selected = [MediaFactory sharedFactory].tool.isSelectOriginalPhoto;
        [self.btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", @"完成", (long)[MediaFactory sharedFactory].tool.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:[MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:[MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        self.btnDone.backgroundColor = [MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor;
    } else {
        self.btnOriginalPhoto.selected = NO;
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        self.labPhotosBytes.text = nil;
        [self.btnDone setTitle:@"完成" forState:UIControlStateDisabled];
        [self.btnOriginalPhoto setTitleColor:[MediaFactory sharedFactory].style.bottomBtnsDisableBgColor forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:[MediaFactory sharedFactory].style.bottomBtnsDisableBgColor forState:UIControlStateDisabled];
        self.btnDone.backgroundColor = [MediaFactory sharedFactory].style.bottomBtnsDisableBgColor;
    }
    
    BOOL canEdit = NO;
    if ([MediaFactory sharedFactory].tool.arrSelectedModels.count == 1) {
        MediaModel *m = [MediaFactory sharedFactory].tool.arrSelectedModels.firstObject;
        canEdit = ([MediaFactory sharedFactory].tool.allowEditImage && ((m.assetType == MediaAssetTypeImage) ||
                                                    (m.assetType == MediaAssetTypeGif && ![MediaFactory sharedFactory].tool.allowSelectGif) ||
                                                    (m.assetType == MediaAssetTypeLivePhoto && ![MediaFactory sharedFactory].tool.allowSelectLivePhoto))) ||
        ([MediaFactory sharedFactory].tool.allowEditVideo && m.assetType == MediaAssetTypeVideo && round(m.phAsset.duration) >= [MediaFactory sharedFactory].tool.maxEditVideoTime);
    }
    [self.btnEdit setTitleColor:canEdit ? [MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor:[MediaFactory sharedFactory].style.bottomBtnsDisableBgColor forState:UIControlStateNormal];
    self.btnEdit.userInteractionEnabled = canEdit;
}

#pragma mark - ui
- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat width = MIN(kMediaScreenWidth, kMediaScreenHeight);
    
    NSInteger columnCount;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        columnCount = 6;
    } else {
        columnCount = 4;
    }
    
    layout.itemSize = CGSizeMake((width-1.5*columnCount)/columnCount, (width-1.5*columnCount)/columnCount);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    if (@available(iOS 11.0, *)) {
        [self.collectionView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
    }
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:NSClassFromString(@"MediaTakePhotoCell") forCellWithReuseIdentifier:@"MediaTakePhotoCell"];
    [self.collectionView registerClass:NSClassFromString(@"MediaCollectionCell") forCellWithReuseIdentifier:@"MediaCollectionCell"];
    //注册3d touch
    if (@available(iOS 9.0, *)) {
        if ([MediaFactory sharedFactory].tool.allowForceTouch && [self forceTouchAvailable]) {
            [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
        }
    }
    
}

- (void)setupBottomView
{
    
    if ([MediaFactory sharedFactory].tool.editAfterSelectThumbnailImage && [MediaFactory sharedFactory].tool.maxSelectCount == 1 && ([MediaFactory sharedFactory].tool.allowEditImage || [MediaFactory sharedFactory].tool.allowEditVideo)) {
        //点击后直接编辑则不需要下方工具条
        return;
    }
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [MediaFactory sharedFactory].style.bottomViewBgColor;
    [self.view addSubview:self.bottomView];
    
    self.bline = [[UIView alloc] init];
    self.bline.backgroundColor = MediaColor(232, 232, 232);
    [self.bottomView addSubview:self.bline];
    
    if ([MediaFactory sharedFactory].tool.allowEditImage || [MediaFactory sharedFactory].tool.allowEditVideo) {
        self.btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnEdit.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
        [self.btnEdit addTarget:self action:@selector(btnEdit_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.btnEdit];
    }
    
    self.btnPreView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnPreView.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnPreView setTitle:@"预览" forState:UIControlStateNormal];
    [self.btnPreView addTarget:self action:@selector(btnPreview_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnPreView];
    
    if ([MediaFactory sharedFactory].tool.allowSelectOriginal) {
        self.btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnOriginalPhoto setImage:[UIImage imageNamed:@"btn_original_circle"] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateSelected];
        [self.btnOriginalPhoto setTitle:@"原图" forState:UIControlStateNormal];
        [self.btnOriginalPhoto addTarget:self action:@selector(btnOriginalPhoto_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.btnOriginalPhoto];
        
        self.labPhotosBytes = [[UILabel alloc] init];
        self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
        self.labPhotosBytes.textColor = [MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor;
        [self.bottomView addSubview:self.labPhotosBytes];
    }
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.btnDone setTitle:@"完成" forState:UIControlStateNormal];
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    [self.btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnDone];
}

- (void)initNavBtn
{
    MediaNavgationController *nav = (MediaNavgationController *)self.navigationController;
    nav.viewControllers.firstObject.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = 40;
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[MediaFactory sharedFactory].style.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

#pragma mark - UIButton Action
- (void)btnEdit_Click:(id)sender {
    MediaModel *m = [MediaFactory sharedFactory].tool.arrSelectedModels.firstObject;
    if (m.assetType == MediaAssetTypeVideo) {
        MediaEditVideoViewController *vc = [[MediaEditVideoViewController alloc] init];
        vc.model = m;
        [self.navigationController pushViewController:vc animated:NO];
    } else if (m.assetType == MediaAssetTypeImage ||
               m.assetType == MediaAssetTypeGif ||
               m.assetType == MediaAssetTypeLivePhoto) {
        MediaEditImageViewController *vc = [[MediaEditImageViewController alloc] init];
        vc.model = m;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)btnPreview_Click:(id)sender
{
    UIViewController *vc = [self getBigImageVCWithData:[MediaFactory sharedFactory].tool.arrSelectedModels index:[MediaFactory sharedFactory].tool.arrSelectedModels.count - 1];
    [self.navigationController showViewController:vc sender:nil];
}

- (UIViewController *)getBigImageVCWithData:(NSArray<MediaModel *> *)data index:(NSInteger)index
{
    MediaLargeImageViewController *vc = [[MediaLargeImageViewController alloc] init];
    vc.models = data.copy;
    vc.selectIndex = index;
    __weak typeof(self) weakSelf = self;
    [vc setBtnBackBlock:^(NSArray<MediaModel *> *selectedModels, BOOL isOriginal) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [[MediaFactory sharedFactory].photo markSelcectedModelInArrary:strongSelf.arrDataSources selectedArray:selectedModels];
        [strongSelf.collectionView reloadData];
    }];
    return vc;
}

- (void)btnOriginalPhoto_Click:(id)sender
{
    self.btnOriginalPhoto.selected = !self.btnOriginalPhoto.selected;
    [MediaFactory sharedFactory].tool.isSelectOriginalPhoto = self.btnOriginalPhoto.selected;
    if ([MediaFactory sharedFactory].tool.isSelectOriginalPhoto) {
        [self getOriginalImageBytes];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)btnDone_Click:(id)sender
{
    if ([MediaFactory sharedFactory].tool.callSelectImageBlock) {
        [MediaFactory sharedFactory].tool.callSelectImageBlock();
    }
}

- (void)navLeftBtn_Click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    MediaNavgationController *nav = (MediaNavgationController *)self.navigationController;
    if ([MediaFactory sharedFactory].tool.cancelBlock) {
        [MediaFactory sharedFactory].tool.cancelBlock();
    }
    [nav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - pan action
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    BOOL asc = !self.allowTakePhoto || [MediaFactory sharedFactory].tool.sortAscending;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _beginSelect = !indexPath ? NO : ![cell isKindOfClass:MediaTakePhotoCell.class];
        
        if (_beginSelect) {
            NSInteger index = asc ? indexPath.row : indexPath.row-1;
            
            MediaModel *m = self.arrDataSources[index];
            _selectType = m.isSelected ? MediaSlideSelectTypeCancel : MediaSlideSelectTypeSelect;
            _beginSlideIndexPath = indexPath;
            
            if (!m.isSelected && [self canAddModel:m]) {
                if ([MediaFactory sharedFactory].tool.editAfterSelectThumbnailImage &&
                    [MediaFactory sharedFactory].tool.maxSelectCount == 1 &&
                    ([MediaFactory sharedFactory].tool.allowEditImage || [MediaFactory sharedFactory].tool.allowEditVideo)) {
                    [self shouldDirectEdit:m];
                    _selectType = MediaSlideSelectTypeNone;
                    return;
                } else {
                    m.selected = YES;
                    [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:m];
                }
            } else if (m.isSelected) {
                m.selected = NO;
                for (MediaModel *sm in [MediaFactory sharedFactory].tool.arrSelectedModels) {
                    if ([sm.phAsset.localIdentifier isEqualToString:m.phAsset.localIdentifier]) {
                        [[MediaFactory sharedFactory].tool.arrSelectedModels removeObject:sm];
                        break;
                    }
                }
            }
            MediaCollectionCell *c = (MediaCollectionCell *)cell;
            c.btnSelect.selected = m.isSelected;
            c.topView.hidden = [MediaFactory sharedFactory].tool.showSelectedMask ? !m.isSelected : YES;
            [self resetBottomBtnsStatus:NO];
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (!_beginSelect ||
            !indexPath ||
            indexPath.row == _lastSlideIndex ||
            [cell isKindOfClass:MediaTakePhotoCell.class] ||
            _selectType == MediaSlideSelectTypeNone) {
                return;
            
        }
        
        _lastSlideIndex = indexPath.row;
        
        NSInteger minIndex = MIN(indexPath.row, _beginSlideIndexPath.row);
        NSInteger maxIndex = MAX(indexPath.row, _beginSlideIndexPath.row);
        
        BOOL minIsBegin = minIndex == _beginSlideIndexPath.row;
        
        for (NSInteger i = _beginSlideIndexPath.row;
             minIsBegin ? i<=maxIndex: i>= minIndex;
             minIsBegin ? i++ : i--) {
            if (i == _beginSlideIndexPath.row) {
                continue;
            }
            NSIndexPath *p = [NSIndexPath indexPathForRow:i inSection:0];
            if (![self.arrSlideIndexPath containsObject:p]) {
                [self.arrSlideIndexPath addObject:p];
                NSInteger index = asc ? i : i-1;
                MediaModel *m = self.arrDataSources[index];
                [self.dicOriSelectStatus setValue:@(m.isSelected) forKey:@(p.row).stringValue];
            }
        }
        
        for (NSIndexPath *path in self.arrSlideIndexPath) {
            NSInteger index = asc ? path.row : path.row-1;
            
            //是否在最初和现在的间隔区间内
            BOOL inSection = path.row >= minIndex && path.row <= maxIndex;
            
            MediaModel *m = self.arrDataSources[index];
            switch (_selectType) {
                case MediaSlideSelectTypeSelect: {
                    if (inSection &&
                        !m.isSelected &&
                        [self canAddModel:m]) {
                        m.selected = YES;
                    }
                }
                    break;
                case MediaSlideSelectTypeCancel: {
                    if (inSection) {
                        m.selected = NO;
                    }
                }
                    break;
                default:
                    break;
            }
            
            if (!inSection) {
                //未在区间内的model还原为初始选择状态
                m.selected = [self.dicOriSelectStatus[@(path.row).stringValue] boolValue];
            }
            
            //判断当前model是否已存在于已选择数组中
            BOOL flag = NO;
            NSMutableArray *arrDel = [NSMutableArray array];
            for (MediaModel *sm in [MediaFactory sharedFactory].tool.arrSelectedModels) {
                if ([sm.phAsset.localIdentifier isEqualToString:m.phAsset.localIdentifier]) {
                    if (!m.isSelected) {
                        [arrDel addObject:sm];
                    }
                    flag = YES;
                    break;
                }
            }
            
            [[MediaFactory sharedFactory].tool.arrSelectedModels removeObjectsInArray:arrDel];
            
            if (!flag && m.isSelected) {
                [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:m];
            }
            
            MediaCollectionCell *c = (MediaCollectionCell *)[self.collectionView cellForItemAtIndexPath:path];
            c.btnSelect.selected = m.isSelected;
            c.topView.hidden = [MediaFactory sharedFactory].tool.showSelectedMask ? !m.isSelected : YES;
            
            [self resetBottomBtnsStatus:NO];
        }
    } else if (pan.state == UIGestureRecognizerStateEnded ||
               pan.state == UIGestureRecognizerStateCancelled) {
        //清空临时属性及数组
        _selectType = MediaSlideSelectTypeNone;
        [self.arrSlideIndexPath removeAllObjects];
        [self.dicOriSelectStatus removeAllObjects];
        [self resetBottomBtnsStatus:YES];
    }
}

- (BOOL)canAddModel:(MediaModel *)model
{
    
    if ([MediaFactory sharedFactory].tool.arrSelectedModels.count >= [MediaFactory sharedFactory].tool.maxSelectCount) {
        ShowToastLong(@"最多只能选择%ld张图片", (long)[MediaFactory sharedFactory].tool.maxSelectCount);
        return NO;
    }
    if ([MediaFactory sharedFactory].tool.arrSelectedModels.count > 0) {
        MediaModel *sm = [MediaFactory sharedFactory].tool.arrSelectedModels.firstObject;
        if (![MediaFactory sharedFactory].tool.allowMixSelect &&
            ((model.assetType < MediaAssetTypeVideo && sm.assetType == MediaAssetTypeVideo) || (model.assetType == MediaAssetTypeVideo && sm.assetType < MediaAssetTypeVideo))) {
            ShowToastLong(@"%@", @"不能同时选择照片和视频");
            return NO;
        }
    }
    if (![[MediaFactory sharedFactory].photo judgeAssetisInLocalAblum:model.phAsset]) {
        ShowToastLong(@"%@", @"请在系统相册中下载到本地后重新尝试");
        return NO;
    }
    if (model.assetType == MediaAssetTypeVideo && [[MediaFactory sharedFactory].tool getDuration:model.duration] > [MediaFactory sharedFactory].tool.maxVideoDuration) {
        ShowToastLong(@"不能选择超过%ld秒的视频", (long)[MediaFactory sharedFactory].tool.maxVideoDuration);
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.allowTakePhoto) {
        return self.arrDataSources.count + 1;
    }
    return self.arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.allowTakePhoto && (([MediaFactory sharedFactory].tool.sortAscending && indexPath.row >= self.arrDataSources.count) || (![MediaFactory sharedFactory].tool.sortAscending && indexPath.row == 0))) {
        MediaTakePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaTakePhotoCell" forIndexPath:indexPath];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = [MediaFactory sharedFactory].style.cellCornerRadio;
        if ([MediaFactory sharedFactory].tool.showCaptureImageOnTakePhotoBtn) {
            [cell startCapture];
        }
        return cell;
    }
    
    MediaCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCollectionCell" forIndexPath:indexPath];
    
    MediaModel *model;
    if (!self.allowTakePhoto || [MediaFactory sharedFactory].tool.sortAscending) {
        model = self.arrDataSources[indexPath.row];
    } else {
        model = self.arrDataSources[indexPath.row-1];
    }
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    
    cell.selectedBlock = ^(BOOL selected) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __strong typeof(weakCell) strongCell = weakCell;
        
        if (!selected) {
            //选中
            if ([strongSelf canAddModel:model]) {
                if (![strongSelf shouldDirectEdit:model]) {
                    model.selected = YES;
                    [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:model];
                    strongCell.btnSelect.selected = YES;
                    [strongSelf shouldDirectEdit:model];
                }
            }
        } else {
            strongCell.btnSelect.selected = NO;
            model.selected = NO;
            for (MediaModel *m in [MediaFactory sharedFactory].tool.arrSelectedModels) {
                if ([m.phAsset.localIdentifier isEqualToString:model.phAsset.localIdentifier]) {
                    [[MediaFactory sharedFactory].tool.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
        if ([MediaFactory sharedFactory].tool.showSelectedMask) {
            strongCell.topView.hidden = !model.isSelected;
        }
        [strongSelf resetBottomBtnsStatus:YES];
    };
    
    cell.allSelectGif = [MediaFactory sharedFactory].tool.allowSelectGif;
    cell.allSelectLivePhoto = [MediaFactory sharedFactory].tool.allowSelectLivePhoto;
    cell.showSelectBtn = [MediaFactory sharedFactory].tool.showSelectBtn;
    cell.cornerRadio = [MediaFactory sharedFactory].style.cellCornerRadio;
    cell.showMask = [MediaFactory sharedFactory].tool.showSelectedMask;
    cell.maskColor = [MediaFactory sharedFactory].style.selectedMaskColor;
    cell.model = model;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.allowTakePhoto && (([MediaFactory sharedFactory].tool.sortAscending && indexPath.row >= self.arrDataSources.count) || (![MediaFactory sharedFactory].tool.sortAscending && indexPath.row == 0))) {
        //拍照
        [self takePhoto];
        return;
    }
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && ![MediaFactory sharedFactory].tool.sortAscending) {
        index = indexPath.row - 1;
    }
    MediaModel *model = self.arrDataSources[index];
    
    if ([self shouldDirectEdit:model]) return;
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:nil];
    }
}

- (BOOL)shouldDirectEdit:(MediaModel *)model
{
    //当前点击图片可编辑
    BOOL editImage = [MediaFactory sharedFactory].tool.editAfterSelectThumbnailImage && [MediaFactory sharedFactory].tool.allowEditImage && [MediaFactory sharedFactory].tool.maxSelectCount == 1 && (model.assetType == MediaAssetTypeImage || model.assetType == MediaAssetTypeGif || model.assetType == MediaAssetTypeLivePhoto);
    //当前点击视频可编辑
    BOOL editVideo = [MediaFactory sharedFactory].tool.editAfterSelectThumbnailImage && [MediaFactory sharedFactory].tool.allowEditVideo && model.assetType == MediaAssetTypeVideo && [MediaFactory sharedFactory].tool.maxSelectCount == 1 && round(model.phAsset.duration) >= [MediaFactory sharedFactory].tool.maxEditVideoTime;
    //当前未选择图片 或 已经选择了一张并且点击的是已选择的图片
    BOOL flag = [MediaFactory sharedFactory].tool.arrSelectedModels.count == 0 || ([MediaFactory sharedFactory].tool.arrSelectedModels.count == 1 && [[MediaFactory sharedFactory].tool.arrSelectedModels.firstObject.phAsset.localIdentifier isEqualToString:model.phAsset.localIdentifier]);
    
    if (editImage && flag) {
        [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    } else if (editVideo && flag) {
        [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    }
    
    return [MediaFactory sharedFactory].tool.editAfterSelectThumbnailImage && [MediaFactory sharedFactory].tool.maxSelectCount == 1 && ([MediaFactory sharedFactory].tool.allowEditImage || [MediaFactory sharedFactory].tool.allowEditVideo);
}

/**
 获取对应的vc
 */
- (UIViewController *)getMatchVCWithModel:(MediaModel *)model
{
    
    if ([MediaFactory sharedFactory].tool.arrSelectedModels.count > 0) {
        MediaModel *sm = [MediaFactory sharedFactory].tool.arrSelectedModels.firstObject;
        if (![MediaFactory sharedFactory].tool.allowMixSelect &&
            ((model.assetType < MediaAssetTypeVideo && sm.assetType == MediaAssetTypeVideo) || (model.assetType == MediaAssetTypeVideo && sm.assetType < MediaAssetTypeVideo))) {
            ShowToastLong(@"%@", @"不能同时选择照片和视频");
            return nil;
        }
    }
    
    BOOL allowSelImage = !(model.assetType == MediaAssetTypeVideo) ? YES : [MediaFactory sharedFactory].tool.allowMixSelect;
    BOOL allowSelVideo = model.assetType == MediaAssetTypeVideo  ? YES : [MediaFactory sharedFactory].tool.allowMixSelect;
    
    NSArray *arr = [[MediaFactory sharedFactory].photo fetchPhotoWithFetchResult:self.albumListModel.result allowSelectVideo:allowSelVideo allowSelectImage:allowSelImage allowSelectGif:[MediaFactory sharedFactory].tool.allowSelectGif allowSelectLivePhoto:[MediaFactory sharedFactory].tool.allowSelectLivePhoto];
    
    NSMutableArray *selIdentifiers = [NSMutableArray array];
    for (MediaModel *m in [MediaFactory sharedFactory].tool.arrSelectedModels) {
        [selIdentifiers addObject:m.phAsset.localIdentifier];
    }
    
    int i = 0;
    BOOL isFind = NO;
    for (MediaModel *m in arr) {
        if ([m.phAsset.localIdentifier isEqualToString:model.phAsset.localIdentifier]) {
            isFind = YES;
        }
        if ([selIdentifiers containsObject:m.phAsset.localIdentifier]) {
            m.selected = YES;
        }
        if (!isFind) {
            i++;
        }
    }
    
    return [self getBigImageVCWithData:arr index:i];
}

- (void)takePhoto
{
    
    if (![[MediaFactory sharedFactory].photo haveCameraAuthority]) {
        NSString *message = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"选项中，允许%@访问你的相机", kMediaAPPName];
        [self showAlert:message];
        return;
    }
    if (![MediaFactory sharedFactory].tool.useCustomCamera) {
        //系统相机拍照
        if ([UIImagePickerController isSourceTypeAvailable:
             UIImagePickerControllerSourceTypeCamera]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.videoQuality = UIImagePickerControllerQualityTypeLow;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self showDetailViewController:picker sender:nil];
        }
    } else {
        if (![[MediaFactory sharedFactory].photo haveMicrophoneAuthority]) {
            NSString *message = [NSString stringWithFormat:@"请在iPhone的\"设置-隐私-相机\"选项中，允许%@访问你的麦克风", kMediaAPPName];
            [self showAlert:message];
            return;
        }
        MediaCameraViewController *camera = [[MediaCameraViewController alloc] init];
        camera.allowRecordVideo = [MediaFactory sharedFactory].tool.allowRecordVideo;
        camera.sessionPreset = [MediaFactory sharedFactory].tool.sessionPreset;
        camera.videoType = [MediaFactory sharedFactory].tool.exportType;
        camera.circleProgressColor = [MediaFactory sharedFactory].style.bottomBtnsNormalTitleColor;
        camera.maxRecordDuration = [MediaFactory sharedFactory].tool.maxRecordDuration;
        __weak typeof(self) weakSelf = self;
        camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf saveImage:image videoUrl:videoUrl];
        };
        [self showDetailViewController:camera sender:nil];
    }
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
    __weak typeof(self) weakSelf = self;
    if (image) {
        [[MediaFactory sharedFactory].photo saveToAlbumWithImage:image completion:^(BOOL success, PHAsset * _Nullable asset) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    MediaModel *model = [MediaModel initModelWithPHAsset:asset mediaType:MediaAssetTypeImage mediaDuration:nil];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", @"图片保存失败");
                }
                [hud hide];
            });
        }];
    } else if (videoUrl) {
        [[MediaFactory sharedFactory].photo saveToAlbumWithVideoURL:videoUrl completion:^(BOOL success, PHAsset * _Nullable asset) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    MediaModel *model = [MediaModel initModelWithPHAsset:asset mediaType:MediaAssetTypeImage mediaDuration:nil];
                    model.duration = [[MediaFactory sharedFactory].photo getDuration:asset];
                    [strongSelf handleDataArray:model];
                } else {
                    ShowToastLong(@"%@", @"视频保存失败");
                }
                [hud hide];
            });
        }];
    }
}

- (void)handleDataArray:(MediaModel *)model
{
    
    if ([MediaFactory sharedFactory].tool.sortAscending) {
        [self.arrDataSources addObject:model];
    } else {
        [self.arrDataSources insertObject:model atIndex:0];
    }
    if ([MediaFactory sharedFactory].tool.maxSelectCount > 1 && [MediaFactory sharedFactory].tool.arrSelectedModels.count < [MediaFactory sharedFactory].tool.maxSelectCount) {
        model.selected = YES;
        [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:model];
        self.albumListModel = [[MediaFactory sharedFactory].photo fetchCameraRollAlbumList:[MediaFactory sharedFactory].tool.allowSelectVideo allowSelectImage:[MediaFactory sharedFactory].tool.allowSelectImage];
    } else if ([MediaFactory sharedFactory].tool.maxSelectCount == 1 && ![MediaFactory sharedFactory].tool.arrSelectedModels.count) {
        if (![self shouldDirectEdit:model]) {
            model.selected = YES;
            [[MediaFactory sharedFactory].tool.arrSelectedModels addObject:model];
            [self btnDone_Click:nil];
            return;
        }
    }
    [self.collectionView reloadData];
    [self scrollToBottom];
    [self resetBottomBtnsStatus:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)getOriginalImageBytes
{
    __weak typeof(self) weakSelf = self;
    [[MediaFactory sharedFactory].photo fetchPhotosBytesWithArray:[MediaFactory sharedFactory].tool.arrSelectedModels completion:^(NSString * _Nullable photosBytes) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
    }];
}

#pragma mark - UIViewControllerPreviewingDelegate
//!!!!: 3D Touch
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if (!indexPath) {
        return nil;
    }
    
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[MediaTakePhotoCell class]]) {
        return nil;
    }
    
    //设置突出区域
    if (@available(iOS 9.0, *)) {
        previewingContext.sourceRect = [self.collectionView cellForItemAtIndexPath:indexPath].frame;
    } else {
        // Fallback on earlier versions
    }
    
    Media3DTouchViewController *vc = [[Media3DTouchViewController alloc] init];
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && ![MediaFactory sharedFactory].tool.sortAscending) {
        index = indexPath.row - 1;
    }
    MediaModel *model = self.arrDataSources[index];
    vc.model = model;
    vc.allowSelectGif = [MediaFactory sharedFactory].tool.allowSelectGif;
    vc.allowSelectLivePhoto = [MediaFactory sharedFactory].tool.allowSelectLivePhoto;
    
    vc.preferredContentSize = [self getSize:model];
    
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    MediaModel *model = [(Media3DTouchViewController *)viewControllerToCommit model];
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:self];
    }
}

- (CGSize)getSize:(MediaModel *)model
{
    CGFloat w = MIN(model.phAsset.pixelWidth, kMediaScreenWidth);
    CGFloat h = w * model.phAsset.pixelHeight / model.phAsset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kMediaScreenHeight || isnan(h)) {
        h = kMediaScreenHeight;
        w = h * model.phAsset.pixelWidth / model.phAsset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
}

- (NSInteger)getDuration:(NSString *)duration{
    NSArray *arr = [duration componentsSeparatedByString:@":"];
    NSInteger d = 0;
    for (int i = 0; i < arr.count; i++) {
        d += [arr[i] integerValue] * pow(60, (arr.count-1-i));
    }
    return d;
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
