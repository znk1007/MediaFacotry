 //
 //   MediaTableViewController.m
 //   MediaFacotry
 //
 //   Created by HuangSam on 2017 / 12 / 1.
 //   Copyright © 2017年 HM. All rights reserved.
 //

#import "MediaTableViewController.h"
#import "MediaModel.h"
#import "MediaFactory.h"
#import "MediaShiningLabel.h"
#import "MediaNavgationController.h"
#import "MediaTableCell.h"
#import "MediaCollectionViewController.h"


@interface MediaTableViewController ()
@property (nonatomic, strong) NSMutableArray<MediaListModel *> *arrayDataSources;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, strong) UIImageView *placeholderImageView;
/**
 闪烁文件标签
 */
@property (nonatomic, strong) MediaShiningLabel *shiningLabel;
@end

@implementation MediaTableViewController

- (void)dealloc
{
     //     NSLog(@"---- %s", __FUNCTION__);
}

- (UIView *)placeholderView{
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] initWithFrame:self.view.bounds];
        [_placeholderView addSubview:self.placeholderImageView];
        [_placeholderView addSubview:self.shiningLabel];
    }
    return _placeholderView;
}

- (UIImageView *)placeholderImageView{
    if (!_placeholderImageView) {
        _placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
        _placeholderImageView.image = [UIImage imageNamed:@"defaultphoto"];
        _placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
        _placeholderImageView.center = CGPointMake(kMediaScreenWidth / 2, kMediaScreenHeight / 2-90);
    }
    return _placeholderImageView;
}

- (MediaShiningLabel *)shiningLabel{
    if (!_shiningLabel) {
        _shiningLabel = [[MediaShiningLabel alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.view.frame) - Media_Shining_Label_Height) / 2, CGRectGetWidth(self.view.frame), Media_Shining_Label_Height)];
        _shiningLabel.text = @"无照片";
        _shiningLabel.textColor = [UIColor grayColor];
        _shiningLabel.font = [UIFont boldSystemFontOfSize:25];
        _shiningLabel.shimmerColor = MediaColor(255, 96, 94);
        [_shiningLabel startShimmer];
    }
    return _shiningLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.title = @"照片";
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self initNavBtn];
    
    if (@available(iOS 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __weak typeof(self) weakSelf = self;
        [[MediaFactory sharedFactory].photo fetchPhotoAlbumList:[MediaFactory sharedFactory].tool.allowSelectVideo allowSelectImage:[MediaFactory sharedFactory].tool.allowSelectImage completion:^(NSArray<MediaListModel *> * _Nullable albums) {
            __strong typeof(weakSelf) strongSelf = self;
            strongSelf.arrayDataSources = [NSMutableArray arrayWithArray:albums];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }];
    });
}

- (void)initNavBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = 40;
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:[MediaFactory sharedFactory].style.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)navRightBtn_Click
{
    MediaNavgationController *nav = (MediaNavgationController *)self.navigationController;
    if ([MediaFactory sharedFactory].tool.cancelBlock) {
        [MediaFactory sharedFactory].tool.cancelBlock();
    }
    [nav dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrayDataSources.count == 0) {
        [self.view addSubview:self.placeholderView];
    } else {
        [_placeholderView removeFromSuperview];
    }
    return self.arrayDataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaTableCell"];
    
    if (!cell) {
        cell = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"MediaTableCell" owner:self options:nil] lastObject];
    }
    MediaListModel *albumModel = self.arrayDataSources[indexPath.row];
    cell.cornerRadio = [MediaFactory sharedFactory].style.cellCornerRadio;
    cell.model = albumModel;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushThumbnailVCWithIndex:indexPath.row animated:YES];
}

- (void)pushThumbnailVCWithIndex:(NSInteger)index animated:(BOOL)animated
{
    MediaListModel *model = self.arrayDataSources[index];
    
    MediaCollectionViewController *collectionVC = [[MediaCollectionViewController alloc] init];
    collectionVC.albumListModel = model;
    [self.navigationController showViewController:collectionVC sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
     //  Dispose of any resources that can be recreated.
}

 /*
#pragma mark - Navigation

 //  In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     //  Get the new view controller using [segue destinationViewController].
     //  Pass the selected object to the new view controller.
}
*/

@end
