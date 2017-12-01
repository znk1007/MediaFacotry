//
//  MediaFetch.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/12/1.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaFetch.h"
#import "MediaFactory.h"
#import "MediaCollectionCell.h"
#import "MediaShiningLabel.h"

#define MediaTableRowHeight (40)
#define MediaTableSesionHeight (10)
#define MediaCollectionViewHeight (200)

@interface MediaFetch()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

/**
 点击手势消失视图
 */
@property (nonatomic, strong) UIView *tapView;
/**
 表格数据源
 */
@property (nonatomic, strong) NSArray<NSArray <NSString *>*> *mediaFetchData;
/**
 预览视图
 */
@property (nonatomic, strong) UICollectionView *previewCollectionView;

/**
 无数据提示
 */
@property (nonatomic, strong) MediaShiningLabel *shiningLabel;

/**
 图片数据源
 */
@property (nonatomic, strong) NSMutableArray <MediaModel *> *photoSource;

/**
 已选图片数据源
 */
@property (nonatomic, strong) NSMutableArray <MediaModel *> *selectedPhotoSource;

/**
 相机，相册，取消table
 */
@property (nonatomic, strong) UITableView *fetchTable;

/**
 显示预览图
 */
@property (nonatomic, assign) BOOL showPreview;

/**
 是否预览
 */
@property (nonatomic, assign) BOOL preview;

@end

@implementation MediaFetch

- (void)dealloc
{
    [_shiningLabel stopShimmer];
    [_shiningLabel removeFromSuperview];
    _shiningLabel = nil;
}

- (instancetype)init
{
    if (![MediaFactory sharedFactory].tool.targetController) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor orangeColor];
        self.frame = [MediaFactory sharedFactory].tool.targetController.view.bounds;
        [self setupBaseLogic];
        [self setupBaseSubviews];
    }
    return self;
}

- (void)setupBaseSubviews{
    [self addSubview:self.fetchTable];
    [self addSubview:self.tapView];
    if (self.showPreview) {
        [self addSubview:self.previewCollectionView];
    }
}

- (void)setupBaseLogic{
    __weak typeof(self) weakSelf = self;
    [[MediaFactory sharedFactory].tool watchAlbumAuthorizeChange:^{
        __strong typeof(weakSelf) strongSelf = self;
        if (strongSelf.preview) {
            [strongSelf fetchPhotoData];
        }else{
            
        }
    }];
}

#pragma mark - getter

- (BOOL)showPreview{
    return [MediaFactory sharedFactory].tool.maxPreviewCount > 0;
}

- (MediaShiningLabel *)shiningLabel{
    if (!_shiningLabel) {
        CGFloat shiningLabelWidth = 80;
        _shiningLabel = [[MediaShiningLabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.previewCollectionView.frame) - shiningLabelWidth) / 2, (CGRectGetHeight(self.previewCollectionView.frame) - Media_Shining_Label_Height) / 2, shiningLabelWidth, Media_Shining_Label_Height)];
        _shiningLabel.text = @"无照片";
        _shiningLabel.backgroundColor = [UIColor greenColor];
        _shiningLabel.textColor = [UIColor grayColor];
        _shiningLabel.font = [UIFont boldSystemFontOfSize:25];
        _shiningLabel.shimmerColor = MediaColor(255, 96, 94);
        [_shiningLabel startShimmer];
    }
    return _shiningLabel;
}

- (NSMutableArray<MediaModel *> *)photoSource{
    if (!_photoSource) {
        _photoSource = [NSMutableArray array];
    }
    return _photoSource;
}

- (NSMutableArray<MediaModel *> *)selectedPhotoSource{
    if (!_selectedPhotoSource) {
        _selectedPhotoSource = [NSMutableArray array];
    }
    return _selectedPhotoSource;
}

- (UIView *)tapView{
    if (!_tapView) {
        CGFloat collectionViewHeight = self.showPreview ? MediaCollectionViewHeight : 0;
        _tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - collectionViewHeight - CGRectGetHeight(self.fetchTable.frame))];
        _tapView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.3];
        UITapGestureRecognizer *dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeSelf)];
        [_tapView addGestureRecognizer:dismissTap];
    }
    return _tapView;
}

- (UICollectionView *)previewCollectionView{
    if (!_previewCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _previewCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.fetchTable.frame) - MediaCollectionViewHeight, CGRectGetWidth(self.frame), MediaCollectionViewHeight) collectionViewLayout:layout];
        _previewCollectionView.delegate = self;
        _previewCollectionView.dataSource = self;
        [_previewCollectionView registerClass:[MediaCollectionCell class] forCellWithReuseIdentifier:NSStringFromClass([MediaCollectionCell class])];
    }
    return _previewCollectionView;
}

- (UITableView *)fetchTable{
    if (!_fetchTable) {
        NSInteger totalCount = 0;
        for (NSUInteger i = 0, j = self.mediaFetchData.count; i < j; i++) {
            totalCount += self.mediaFetchData[i].count;
        }
        CGFloat tableHeight = MediaTableRowHeight * totalCount + MediaTableSesionHeight;
        _fetchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - tableHeight, CGRectGetWidth(self.frame), tableHeight) style:UITableViewStyleGrouped];
        _fetchTable.dataSource = self;
        _fetchTable.delegate = self;
        _fetchTable.scrollEnabled = NO;
        if ([_fetchTable respondsToSelector:@selector(setLayoutMargins:)]) {
            [_fetchTable setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([_fetchTable respondsToSelector:@selector(setSeparatorInset:)]) {
            [_fetchTable setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    return _fetchTable;
}

- (NSArray *)mediaFetchData{
    if (!_mediaFetchData) {
        _mediaFetchData = @[@[@"相机",@"相册"],@[@"取消"]];
    }
    return _mediaFetchData;
}

#pragma mark - UITableViewDelegate and UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.mediaFetchData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.mediaFetchData[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *tableCellId = @"MediaFetchTableCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellId];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    NSString *title = self.mediaFetchData[indexPath.section][indexPath.row];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), MediaTableRowHeight)];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:titleLabel];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selected = NO;
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self removeFromSuperview];
    } else {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return MediaTableRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return MediaTableSesionHeight;
    } else {
        return 0.001;
    }
}

#pragma mark - UICollectionViewDelegate adn UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count = self.photoSource.count;
    if (count == 0) {
        [self.previewCollectionView addSubview:self.shiningLabel];
    } else {
        [_shiningLabel stopShimmer];
        [_shiningLabel removeFromSuperview];
        _shiningLabel = nil;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MediaCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MediaCollectionCell class]) forIndexPath:indexPath];
    
    return cell;
}



- (void)showAlbum{
    [[MediaFactory sharedFactory].tool.targetController.view addSubview:self];
}

#pragma mark - private method

- (void)fetchPhotoData{
    [self.photoSource removeAllObjects];
    [self.photoSource addObjectsFromArray:[[MediaFactory sharedFactory].photo fetchAllAssetFormAlbumWithAscending:[MediaFactory sharedFactory].tool.sortAscending limitCount:[MediaFactory sharedFactory].tool.maxPreviewCount allowSelectVideo:[MediaFactory sharedFactory].tool.allowSelectVideo allowSelectImage:[MediaFactory sharedFactory].tool.allowSelectImage allowSelectGIF:[MediaFactory sharedFactory].tool.allowSelectGif allowSelectLivePhoto:[MediaFactory sharedFactory].tool.allowSelectLivePhoto]];
}

#pragma mark - action

- (void)removeSelf{
    [self removeFromSuperview];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
