//
//  MediaThumbnailViewController.m
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaThumbnailViewController.h"
#import <Photos/Photos.h>
#import "MediaDefine.h"
#import "MediaCollectionCell.h"
#import "MediaPhotoManager.h"
#import "MediaPhotoModel.h"
#import "MediaShowBigImgViewController.h"
#import "MediaPhotoBrowser.h"
#import "ToastUtils.h"
#import "MediaProgressHUD.h"
#import "MediaForceTouchPreviewController.h"
#import "MediaEditImageController.h"
#import "MediaEditVideoController.h"
#import "MediaCustomCamera.h"

typedef NS_ENUM(NSUInteger, SlideSelectType) {
    SlideSelectTypeNone,
    SlideSelectTypeSelect,
    SlideSelectTypeCancel,
};

@interface MediaThumbnailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIViewControllerPreviewingDelegate>
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
    SlideSelectType _selectType;
    /**开始滑动的indexPath*/
    NSIndexPath *_beginSlideIndexPath;
    /**最后滑动经过的index，开始的indexPath不计入，优化拖动手势计算，避免单个cell中冗余计算多次*/
    NSInteger _lastSlideIndex;
}

@property (nonatomic, strong) NSMutableArray<MediaPhotoModel *> *arrDataSources;
@property (nonatomic, assign) BOOL allowTakePhoto;
/**所有滑动经过的indexPath*/
@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *arrSlideIndexPath;
/**所有滑动经过的indexPath的初始选择状态*/
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dicOriSelectStatus;
@end

@implementation MediaThumbnailViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    NSLog(@"---- %s", __FUNCTION__);
    [_arrDataSources removeAllObjects];
    _arrDataSources = nil;
}

- (NSMutableArray<MediaPhotoModel *> *)arrDataSources
{
    if (!_arrDataSources) {
        MediaProgressHUD *hud = [[MediaProgressHUD alloc] init];
        [hud show];
        
        MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
        MediaPhotoConfiguration *configuration = nav.configuration;
        
        if (!_albumListModel) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                media_weak(self);
                [MediaPhotoManager getCameraRollAlbumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage completion:^(MediaAlbumListModel *album) {
                    media_strong(weakSelf);
                    MediaImageNavigationController *weakNav = (MediaImageNavigationController *)strongSelf.navigationController;
                    
                    strongSelf.albumListModel = album;
                    [MediaPhotoManager markSelcectModelInArr:strongSelf.albumListModel.models selArr:weakNav.arrSelectedModels];
                    strongSelf.arrDataSources = [NSMutableArray arrayWithArray:strongSelf.albumListModel.models];
                    [hud hide];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (configuration.allowTakePhotoInLibrary && configuration.allowSelectImage) {
                            strongSelf.allowTakePhoto = YES;
                        }
                        strongSelf.title = album.title;
                        [strongSelf.collectionView reloadData];
                        [strongSelf scrollToBottom];
                    });
                }];
            });
        } else {
            if (configuration.allowTakePhotoInLibrary && configuration.allowSelectImage && self.albumListModel.isCameraRoll) {
                self.allowTakePhoto = YES;
            }
            [MediaPhotoManager markSelcectModelInArr:self.albumListModel.models selArr:nav.arrSelectedModels];
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
    
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    if (configuration.allowSlideSelect) {
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
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    if (configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo)) {
        //点击后直接编辑则不需要下方工具条
        showBottomView = NO;
        inset.bottom = 0;
    }
    //不显示底部视图
    if (configuration.hideBottom) {
        showBottomView = NO;
        inset.bottom = 0;
    }
    
    CGFloat bottomViewH = showBottomView ? 44 : 0;
    CGFloat bottomBtnH = 30;
    
    CGFloat width = kMediaViewWidth-inset.left-inset.right;
    self.collectionView.frame = CGRectMake(inset.left, 0, width, kMediaViewHeight-inset.bottom-bottomViewH);
    
    if (!showBottomView) {
        return;
    }
    
    self.bottomView.frame = CGRectMake(inset.left, kMediaViewHeight-bottomViewH-inset.bottom, width, bottomViewH+inset.bottom);
    self.bline.frame = CGRectMake(0, 0, width, 1/[UIScreen mainScreen].scale);
    
    CGFloat offsetX = 12;
    if (configuration.allowEditImage || configuration.allowEditVideo) {
        self.btnEdit.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserEditText), 15, YES, bottomBtnH), bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnEdit.frame) + 10;
    }
    self.btnPreView.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserPreviewText), 15, YES, bottomBtnH), bottomBtnH);
    offsetX = CGRectGetMaxX(self.btnPreView.frame) + 10;
    
    if (configuration.allowSelectOriginal) {
        self.btnOriginalPhoto.frame = CGRectMake(offsetX, 7, GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserOriginalText), 15, YES, bottomBtnH)+self.btnOriginalPhoto.imageView.frame.size.width, bottomBtnH);
        offsetX = CGRectGetMaxX(self.btnOriginalPhoto.frame) + 5;
        
        self.labPhotosBytes.frame = CGRectMake(offsetX, 7, 80, bottomBtnH);
    }
    
    CGFloat doneWidth = GetMatchValue(self.btnDone.currentTitle, 15, YES, bottomBtnH);
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
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    if (!configuration.sortAscending) {
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
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    if (nav.arrSelectedModels.count > 0) {
        self.btnOriginalPhoto.enabled = YES;
        self.btnPreView.enabled = YES;
        self.btnDone.enabled = YES;
        if (nav.isSelectOriginalPhoto) {
            if (getBytes) [self getOriginalImageBytes];
        } else {
            self.labPhotosBytes.text = nil;
        }
        self.btnOriginalPhoto.selected = nav.isSelectOriginalPhoto;
        [self.btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(MediaPhotoBrowserDoneText), nav.arrSelectedModels.count] forState:UIControlStateNormal];
        [self.btnOriginalPhoto setTitleColor:configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        [self.btnPreView setTitleColor:configuration.bottomBtnsNormalTitleColor forState:UIControlStateNormal];
        self.btnDone.backgroundColor = configuration.bottomBtnsNormalTitleColor;
    } else {
        self.btnOriginalPhoto.selected = NO;
        self.btnOriginalPhoto.enabled = NO;
        self.btnPreView.enabled = NO;
        self.btnDone.enabled = NO;
        self.labPhotosBytes.text = nil;
        [self.btnDone setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserDoneText) forState:UIControlStateDisabled];
        [self.btnOriginalPhoto setTitleColor:configuration.bottomBtnsDisableBgColor forState:UIControlStateDisabled];
        [self.btnPreView setTitleColor:configuration.bottomBtnsDisableBgColor forState:UIControlStateDisabled];
        self.btnDone.backgroundColor = configuration.bottomBtnsDisableBgColor;
    }
    
    BOOL canEdit = NO;
    if (nav.arrSelectedModels.count == 1) {
        MediaPhotoModel *m = nav.arrSelectedModels.firstObject;
        canEdit = (configuration.allowEditImage && ((m.type == MediaAssetMediaTypeImage) ||
        (m.type == MediaAssetMediaTypeGif && !configuration.allowSelectGif) ||
        (m.type == MediaAssetMediaTypeLivePhoto && !configuration.allowSelectLivePhoto))) ||
        (configuration.allowEditVideo && m.type == MediaAssetMediaTypeVideo && floor(m.asset.duration) >= configuration.maxEditVideoTime);
    }
    [self.btnEdit setTitleColor:canEdit?configuration.bottomBtnsNormalTitleColor:configuration.bottomBtnsDisableBgColor forState:UIControlStateNormal];
    self.btnEdit.userInteractionEnabled = canEdit;
}

#pragma mark - ui
- (void)setupCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    CGFloat width = MIN(kMediaViewWidth, kMediaViewHeight);
    
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
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    if (configuration.allowForceTouch && [self forceTouchAvailable]) {
        if (@available(iOS 9.0, *)) {
            [self registerForPreviewingWithDelegate:self sourceView:self.collectionView];
        } else {
            // Fallback on earlier versions
        }
    }
}

- (void)setupBottomView
{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    if (configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo)) {
        //点击后直接编辑则不需要下方工具条
        return;
    }
    
    if (configuration.hideBottom) {
        //设置了隐藏
        return;
    }
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = configuration.bottomViewBgColor;
    [self.view addSubview:self.bottomView];
    
    self.bline = [[UIView alloc] init];
    self.bline.backgroundColor = kMediaRGB(232, 232, 232);
    [self.bottomView addSubview:self.bline];
    
    if (configuration.allowEditImage || configuration.allowEditVideo) {
        self.btnEdit = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnEdit.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnEdit setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserEditText) forState:UIControlStateNormal];
        [self.btnEdit addTarget:self action:@selector(btnEdit_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.btnEdit];
    }
    
    self.btnPreView = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnPreView.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnPreView setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserPreviewText) forState:UIControlStateNormal];
    [self.btnPreView addTarget:self action:@selector(btnPreview_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnPreView];
    
    if (configuration.allowSelectOriginal) {
        self.btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
        [self.btnOriginalPhoto setImage:GetImageWithName(@"btn_original_circle") forState:UIControlStateNormal];
        [self.btnOriginalPhoto setImage:GetImageWithName(@"btn_selected") forState:UIControlStateSelected];
        [self.btnOriginalPhoto setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserOriginalText) forState:UIControlStateNormal];
        [self.btnOriginalPhoto addTarget:self action:@selector(btnOriginalPhoto_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView addSubview:self.btnOriginalPhoto];
        
        self.labPhotosBytes = [[UILabel alloc] init];
        self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
        self.labPhotosBytes.textColor = configuration.bottomBtnsNormalTitleColor;
        [self.bottomView addSubview:self.labPhotosBytes];
    }
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.btnDone setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserDoneText) forState:UIControlStateNormal];
    self.btnDone.layer.masksToBounds = YES;
    self.btnDone.layer.cornerRadius = 3.0f;
    [self.btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnDone];
}

- (void)initNavBtn
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    nav.viewControllers.firstObject.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:GetLocalLanguageTextValue(MediaPhotoBrowserBackText) style:UIBarButtonItemStylePlain target:nil action:nil];
    
    if (configuration.showConfirmText) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserDoneText), 16, YES, 44);
        btn.frame = CGRectMake(0, 0, width, 44);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        if (@available(iOS 10.0,*)) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
        }
        [btn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserDoneText) forState:UIControlStateNormal];
        [btn setTitleColor:configuration.navTitleColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    } else {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserCancelText), 16, YES, 44);
        btn.frame = CGRectMake(0, 0, width, 44);
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        if (@available(iOS 10.0,*)) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
        }
        [btn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCancelText) forState:UIControlStateNormal];
        [btn setTitleColor:configuration.navTitleColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    
}

#pragma mark - UIButton Action
- (void)btnEdit_Click:(id)sender {
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoModel *m = nav.arrSelectedModels.firstObject;
    
    if (m.type == MediaAssetMediaTypeVideo) {
        MediaEditVideoController *vc = [[MediaEditVideoController alloc] init];
        vc.model = m;
        [self.navigationController pushViewController:vc animated:NO];
    } else if (m.type == MediaAssetMediaTypeImage ||
               m.type == MediaAssetMediaTypeGif ||
               m.type == MediaAssetMediaTypeLivePhoto) {
        MediaEditImageController *vc = [[MediaEditImageController alloc] init];
        vc.model = m;
        [self.navigationController pushViewController:vc animated:NO];
    }
}

- (void)btnPreview_Click:(id)sender
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    UIViewController *vc = [self getBigImageVCWithData:nav.arrSelectedModels index:nav.arrSelectedModels.count-1];
    [self.navigationController showViewController:vc sender:nil];
}

- (UIViewController *)getBigImageVCWithData:(NSArray<MediaPhotoModel *> *)data index:(NSInteger)index
{
    MediaShowBigImgViewController *vc = [[MediaShowBigImgViewController alloc] init];
    vc.models = data.copy;
    vc.selectIndex = index;
    media_weak(self);
    [vc setBtnBackBlock:^(NSArray<MediaPhotoModel *> *selectedModels, BOOL isOriginal) {
        media_strong(weakSelf);
        [MediaPhotoManager markSelcectModelInArr:strongSelf.arrDataSources selArr:selectedModels];
        [strongSelf.collectionView reloadData];
    }];
    return vc;
}

- (void)btnOriginalPhoto_Click:(id)sender
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    self.btnOriginalPhoto.selected = !self.btnOriginalPhoto.selected;
    nav.isSelectOriginalPhoto = self.btnOriginalPhoto.selected;
    if (nav.isSelectOriginalPhoto) {
        [self getOriginalImageBytes];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)btnDone_Click:(id)sender
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    if (nav.callSelectImageBlock) {
        MediaPhotoConfiguration *configuration = nav.configuration;
        if (configuration.uploadImmediately) {
            nav.callSelectImageBlock(^(BOOL finished, BOOL hideAfter, float progress, NSString * _Nullable errorDesc) {
                
            });
        } else {
            nav.callSelectImageBlock(nil);
        }
    }
}

- (void)navLeftBtn_Click
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    if (nav.cancelBlock) {
        nav.cancelBlock();
    }
    [nav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - pan action
- (void)panAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    BOOL asc = !self.allowTakePhoto || configuration.sortAscending;
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _beginSelect = !indexPath ? NO : ![cell isKindOfClass:MediaTakePhotoCell.class];
        
        if (_beginSelect) {
            NSInteger index = asc ? indexPath.row : indexPath.row-1;
            
            MediaPhotoModel *m = self.arrDataSources[index];
            _selectType = m.isSelected ? SlideSelectTypeCancel : SlideSelectTypeSelect;
            _beginSlideIndexPath = indexPath;
            
            if (!m.isSelected && [self canAddModel:m]) {
                if (configuration.editAfterSelectThumbnailImage &&
                    configuration.maxSelectCount == 1 &&
                    (configuration.allowEditImage || configuration.allowEditVideo)) {
                    [self shouldDirectEdit:m];
                    _selectType = SlideSelectTypeNone;
                    return;
                } else {
                    m.selected = YES;
                    [nav.arrSelectedModels addObject:m];
                }
            } else if (m.isSelected) {
                m.selected = NO;
                for (MediaPhotoModel *sm in nav.arrSelectedModels) {
                    if ([sm.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                        [nav.arrSelectedModels removeObject:sm];
                        break;
                    }
                }
            }
            MediaCollectionCell *c = (MediaCollectionCell *)cell;
            c.btnSelect.selected = m.isSelected;
            c.topView.hidden = configuration.showSelectedMask ? !m.isSelected : YES;
            [self resetBottomBtnsStatus:NO];
        }
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        if (!_beginSelect ||
            !indexPath ||
            indexPath.row == _lastSlideIndex ||
            [cell isKindOfClass:MediaTakePhotoCell.class] ||
            _selectType == SlideSelectTypeNone) return;
        
        _lastSlideIndex = indexPath.row;
        
        NSInteger minIndex = MIN(indexPath.row, _beginSlideIndexPath.row);
        NSInteger maxIndex = MAX(indexPath.row, _beginSlideIndexPath.row);
        
        BOOL minIsBegin = minIndex == _beginSlideIndexPath.row;
        
        for (NSInteger i = _beginSlideIndexPath.row;
             minIsBegin ? i<=maxIndex: i>= minIndex;
             minIsBegin ? i++ : i--) {
            if (i == _beginSlideIndexPath.row) continue;
            NSIndexPath *p = [NSIndexPath indexPathForRow:i inSection:0];
            if (![self.arrSlideIndexPath containsObject:p]) {
                [self.arrSlideIndexPath addObject:p];
                NSInteger index = asc ? i : i-1;
                MediaPhotoModel *m = self.arrDataSources[index];
                [self.dicOriSelectStatus setValue:@(m.isSelected) forKey:@(p.row).stringValue];
            }
        }
        
        for (NSIndexPath *path in self.arrSlideIndexPath) {
            NSInteger index = asc ? path.row : path.row-1;
            
            //是否在最初和现在的间隔区间内
            BOOL inSection = path.row >= minIndex && path.row <= maxIndex;
            
            MediaPhotoModel *m = self.arrDataSources[index];
            switch (_selectType) {
                case SlideSelectTypeSelect: {
                    if (inSection &&
                        !m.isSelected &&
                        [self canAddModel:m]) m.selected = YES;
                }
                    break;
                case SlideSelectTypeCancel: {
                    if (inSection) m.selected = NO;
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
            for (MediaPhotoModel *sm in nav.arrSelectedModels) {
                if ([sm.asset.localIdentifier isEqualToString:m.asset.localIdentifier]) {
                    if (!m.isSelected) {
                        [arrDel addObject:sm];
                    }
                    flag = YES;
                    break;
                }
            }
            
            [nav.arrSelectedModels removeObjectsInArray:arrDel];
            
            if (!flag && m.isSelected) {
                [nav.arrSelectedModels addObject:m];
            }
            
            MediaCollectionCell *c = (MediaCollectionCell *)[self.collectionView cellForItemAtIndexPath:path];
            c.btnSelect.selected = m.isSelected;
            c.topView.hidden = configuration.showSelectedMask ? !m.isSelected : YES;
            
            [self resetBottomBtnsStatus:NO];
        }
    } else if (pan.state == UIGestureRecognizerStateEnded ||
               pan.state == UIGestureRecognizerStateCancelled) {
        //清空临时属性及数组
        _selectType = SlideSelectTypeNone;
        [self.arrSlideIndexPath removeAllObjects];
        [self.dicOriSelectStatus removeAllObjects];
        [self resetBottomBtnsStatus:YES];
    }
}

- (BOOL)canAddModel:(MediaPhotoModel *)model
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration =nav.configuration;
    
    if (nav.arrSelectedModels.count >= configuration.maxSelectCount) {
        ShowToastLong(GetLocalLanguageTextValue(MediaPhotoBrowserMaxSelectCountText), configuration.maxSelectCount);
        return NO;
    }
    if (nav.arrSelectedModels.count > 0) {
        MediaPhotoModel *sm = nav.arrSelectedModels.firstObject;
        if (!configuration.allowMixSelect &&
            ((model.type < MediaAssetMediaTypeVideo && sm.type == MediaAssetMediaTypeVideo) || (model.type == MediaAssetMediaTypeVideo && sm.type < MediaAssetMediaTypeVideo))) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserCannotSelectVideo));
            return NO;
        }
    }
    if (![MediaPhotoManager judgeAssetisInLocalAblum:model.asset]) {
        ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowseriCloudPhotoText));
        return NO;
    }
    if (model.type == MediaAssetMediaTypeVideo && GetDuration(model.duration) > configuration.maxVideoDuration) {
        ShowToastLong(GetLocalLanguageTextValue(MediaPhotoBrowserMaxVideoDurationText), configuration.maxVideoDuration);
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
    if (self.arrDataSources.count) {
        if (self.allowTakePhoto) {
            return self.arrDataSources.count + 1;
        }
        return self.arrDataSources.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    if (self.allowTakePhoto && ((configuration.sortAscending && indexPath.row >= self.arrDataSources.count) || (!configuration.sortAscending && indexPath.row == 0))) {
        MediaTakePhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaTakePhotoCell" forIndexPath:indexPath];
        cell.layer.masksToBounds = YES;
        cell.layer.cornerRadius = configuration.cellCornerRadio;
        if (configuration.showCaptureImageOnTakePhotoBtn) {
            [cell startCapture];
        }
        return cell;
    }
    
    MediaCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MediaCollectionCell" forIndexPath:indexPath];
    
    MediaPhotoModel *model;
    if (!self.allowTakePhoto || configuration.sortAscending) {
        model = self.arrDataSources[indexPath.row];
    } else {
        model = self.arrDataSources[indexPath.row-1];
    }

    media_weak(self);
    __weak typeof(cell) weakCell = cell;
    
    cell.selectedBlock = ^(BOOL selected) {
        media_strong(weakSelf);
        __strong typeof(weakCell) strongCell = weakCell;
        
        MediaImageNavigationController *weakNav = (MediaImageNavigationController *)strongSelf.navigationController;
        MediaPhotoConfiguration *configuration = weakNav.configuration;
        if (configuration.pickOnly) {
            
        }
        if (!selected) {
            //选中
            if ([strongSelf canAddModel:model]) {
                if (![strongSelf shouldDirectEdit:model]) {
                    model.selected = YES;
                    [weakNav.arrSelectedModels addObject:model];
                    strongCell.btnSelect.selected = YES;
                    [strongSelf shouldDirectEdit:model];
                }
            }
        } else {
            strongCell.btnSelect.selected = NO;
            model.selected = NO;
            for (MediaPhotoModel *m in weakNav.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [weakNav.arrSelectedModels removeObject:m];
                    break;
                }
            }
        }
        if (configuration.showSelectedMask) {
            strongCell.topView.hidden = !model.isSelected;
        }
        [strongSelf resetBottomBtnsStatus:YES];
    };
    
    cell.allSelectGif = configuration.allowSelectGif;
    cell.allSelectLivePhoto = configuration.allowSelectLivePhoto;
    cell.showSelectBtn = configuration.showSelectBtn;
    cell.cornerRadio = configuration.cellCornerRadio;
    cell.showMask = configuration.showSelectedMask;
    cell.maskColor = configuration.selectedMaskColor;
    cell.model = model;

    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = [nav configuration];
    
    if (self.allowTakePhoto && ((configuration.sortAscending && indexPath.row >= self.arrDataSources.count) || (!configuration.sortAscending && indexPath.row == 0))) {
        //拍照
        if (!TARGET_IPHONE_SIMULATOR) {
            [self takePhoto];
        }
        return;
    }
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !configuration.sortAscending) {
        index = indexPath.row - 1;
    }
    MediaPhotoModel *model = self.arrDataSources[index];
    
    if ([self shouldDirectEdit:model]) {
        return;
    }
    if (configuration.pickOnly) {
        if (nav.callSelectClipImageBlock) {
            [MediaPhotoManager requestOriginalImageDataForAsset:model.asset completion:^(NSData * _Nullable data, NSDictionary * _Nullable info) {
                nav.callSelectClipImageBlock([UIImage imageWithData:data], model.asset, nil);
                MediaPhotoConfiguration *configuration = nav.configuration;
                if (configuration.uploadImmediately) {
                    nav.callSelectImageBlock(^(BOOL finished, BOOL hideAfter, float progress, NSString * _Nullable errorDesc) {
                        
                    });
                    nav.callSelectClipImageBlock([UIImage imageWithData:data], model.asset, ^(BOOL finished, BOOL hideAfter, float progress, NSString * _Nullable errorDesc) {
                        
                    });
                } else {
                    nav.callSelectClipImageBlock([UIImage imageWithData:data], model.asset, nil);
                }
            }];
        }
        return;
    }
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:nil];
    }
}

- (BOOL)shouldDirectEdit:(MediaPhotoModel *)model
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    //当前点击图片可编辑
    BOOL editImage = configuration.editAfterSelectThumbnailImage && configuration.allowEditImage && configuration.maxSelectCount == 1 && (model.type == MediaAssetMediaTypeImage || model.type == MediaAssetMediaTypeGif || model.type == MediaAssetMediaTypeLivePhoto);
    //当前点击视频可编辑
    BOOL editVideo = configuration.editAfterSelectThumbnailImage && configuration.allowEditVideo && model.type == MediaAssetMediaTypeVideo && configuration.maxSelectCount == 1 && floor(model.asset.duration) >= configuration.maxEditVideoTime;
    //当前未选择图片 或 已经选择了一张并且点击的是已选择的图片
    BOOL flag = nav.arrSelectedModels.count == 0 || (nav.arrSelectedModels.count == 1 && [nav.arrSelectedModels.firstObject.asset.localIdentifier isEqualToString:model.asset.localIdentifier]);
    
    if (editImage && flag) {
        [nav.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    } else if (editVideo && flag) {
        [nav.arrSelectedModels addObject:model];
        [self btnEdit_Click:nil];
    }
    
    return configuration.editAfterSelectThumbnailImage && configuration.maxSelectCount == 1 && (configuration.allowEditImage || configuration.allowEditVideo);
}

/**
 获取对应的vc
 */
- (UIViewController *)getMatchVCWithModel:(MediaPhotoModel *)model
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    if (nav.arrSelectedModels.count > 0) {
        MediaPhotoModel *sm = nav.arrSelectedModels.firstObject;
        if (!configuration.allowMixSelect &&
            ((model.type < MediaAssetMediaTypeVideo && sm.type == MediaAssetMediaTypeVideo) || (model.type == MediaAssetMediaTypeVideo && sm.type < MediaAssetMediaTypeVideo))) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(MediaPhotoBrowserCannotSelectVideo));
            return nil;
        }
    }
    
    BOOL allowSelImage = !(model.type==MediaAssetMediaTypeVideo) ? YES : configuration.allowMixSelect;
    BOOL allowSelVideo = model.type==MediaAssetMediaTypeVideo ? YES : configuration.allowMixSelect;
    
    NSArray *arr = [MediaPhotoManager getPhotoInResult:self.albumListModel.result allowSelectVideo:allowSelVideo allowSelectImage:allowSelImage allowSelectGif:configuration.allowSelectGif allowSelectLivePhoto:configuration.allowSelectLivePhoto];
    
    NSMutableArray *selIdentifiers = [NSMutableArray array];
    for (MediaPhotoModel *m in nav.arrSelectedModels) {
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
    
    return [self getBigImageVCWithData:arr index:i];
}

- (void)takePhoto
{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    if (![MediaPhotoManager haveCameraAuthority]) {
        NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(MediaPhotoBrowserNoCameraAuthorityText), kAPPName];
        ShowAlert(message, self);
        return;
    }
    if (configuration.useSystemCamera) {
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
        if (![MediaPhotoManager haveMicrophoneAuthority]) {
            NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(MediaPhotoBrowserNoMicrophoneAuthorityText), kAPPName];
            ShowAlert(message, self);
            return;
        }
        MediaCustomCamera *camera = [[MediaCustomCamera alloc] init];
        camera.allowRecordVideo = configuration.allowRecordVideo;
        camera.sessionPreset = configuration.sessionPreset;
        camera.videoType = configuration.exportVideoType;
        camera.circleProgressColor = configuration.bottomBtnsNormalTitleColor;
        camera.maxRecordDuration = configuration.maxRecordDuration;
        media_weak(self);
        camera.doneBlock = ^(UIImage *image, NSURL *videoUrl) {
            media_strong(weakSelf);
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
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    MediaPhotoConfiguration *configuration = nav.configuration;
    
    if (configuration.sortAscending) {
        [self.arrDataSources addObject:model];
    } else {
        [self.arrDataSources insertObject:model atIndex:0];
    }
    if (configuration.maxSelectCount > 1 && nav.arrSelectedModels.count < configuration.maxSelectCount) {
        model.selected = YES;
        [nav.arrSelectedModels addObject:model];
        self.albumListModel = [MediaPhotoManager getCameraRollAlbumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage];
    } else if (configuration.maxSelectCount == 1 && !nav.arrSelectedModels.count) {
        if (![self shouldDirectEdit:model]) {
            model.selected = YES;
            [nav.arrSelectedModels addObject:model];
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
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    media_weak(self);
    [MediaPhotoManager getPhotosBytesWithArray:nav.arrSelectedModels completion:^(NSString *photosBytes) {
        media_strong(weakSelf);
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
    
    MediaForceTouchPreviewController *vc = [[MediaForceTouchPreviewController alloc] init];
    
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    NSInteger index = indexPath.row;
    if (self.allowTakePhoto && !configuration.sortAscending) {
        index = indexPath.row - 1;
    }
    MediaPhotoModel *model = self.arrDataSources[index];
    vc.model = model;
    vc.allowSelectGif = configuration.allowSelectGif;
    vc.allowSelectLivePhoto = configuration.allowSelectLivePhoto;
    
    vc.preferredContentSize = [self getSize:model];
    
    return vc;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    MediaPhotoModel *model = [(MediaForceTouchPreviewController *)viewControllerToCommit model];
    
    UIViewController *vc = [self getMatchVCWithModel:model];
    if (vc) {
        [self showViewController:vc sender:self];
    }
}

- (CGSize)getSize:(MediaPhotoModel *)model
{
    CGFloat w = MIN(model.asset.pixelWidth, kMediaViewWidth);
    CGFloat h = w * model.asset.pixelHeight / model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kMediaViewHeight || isnan(h)) {
        h = kMediaViewHeight;
        w = h * model.asset.pixelWidth / model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
}

@end
