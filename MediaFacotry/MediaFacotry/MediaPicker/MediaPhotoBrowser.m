//
//  MediaPhotoBrowser.m
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPhotoBrowser.h"
#import "MediaPhotoBrowserCell.h"
#import "MediaPhotoManager.h"
#import "MediaPhotoModel.h"
#import "MediaThumbnailViewController.h"

@implementation MediaImageNavigationController

- (void)dealloc
{
//    [[SDWebImageManager sharedManager] cancelAll];
//    NSLog(@"---- %s", __FUNCTION__);
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.barStyle = UIBarStyleBlack;
        self.navigationBar.translucent = YES;
    }
    return self;
}

- (NSMutableArray<MediaPhotoModel *> *)arrSelectedModels
{
    if (!_arrSelectedModels) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}

- (void)setConfiguration:(MediaPhotoConfiguration *)configuration
{
    _configuration = configuration;
    
    [UIApplication sharedApplication].statusBarStyle = self.configuration.statusBarStyle;
    [self.navigationBar setBackgroundImage:[self imageWithColor:configuration.navBarColor] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTintColor:configuration.navTitleColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: configuration.navTitleColor}];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [UIApplication sharedApplication].statusBarStyle = self.configuration.statusBarStyle;
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
    //    [self setNeedsStatusBarAppearanceUpdate];
}

//BOOL dismiss = NO;
//- (UIStatusBarStyle)previousStatusBarStyle
//{
//    if (!dismiss) {
//        return UIStatusBarStyleLightContent;
//    } else {
//        return self.previousStatusBarStyle;
//    }
//}

@end


@interface MediaPhotoBrowser ()

@property (nonatomic, strong) NSMutableArray<MediaAlbumListModel *> *arrayDataSources;

@property (nonatomic, strong) UIView *placeholderView;

@end

@implementation MediaPhotoBrowser

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (UIView *)placeholderView
{
    if (!_placeholderView) {
        _placeholderView = [[UIView alloc] initWithFrame:self.view.bounds];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 80)];
        imageView.image = GetImageWithName(@"defaultphoto");
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.center = CGPointMake(kMediaViewWidth/2, kViewHeight/2-90);
        [_placeholderView addSubview:imageView];
        
        UILabel *placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kViewHeight/2-40, kMediaViewWidth, 20)];
        placeholderLabel.text = GetLocalLanguageTextValue(MediaPhotoBrowserNoPhotoText);
        placeholderLabel.textAlignment = NSTextAlignmentCenter;
        placeholderLabel.textColor = [UIColor darkGrayColor];
        placeholderLabel.font = [UIFont systemFontOfSize:15];
        [_placeholderView addSubview:placeholderLabel];
        
        _placeholderView.hidden = YES;
        [self.view addSubview:_placeholderView];
    }
    return _placeholderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.title = GetLocalLanguageTextValue(MediaPhotoBrowserPhotoText);
    
    self.tableView.tableFooterView = [[UIView alloc] init];
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:GetLocalLanguageTextValue(MediaPhotoBrowserBackText) style:UIBarButtonItemStylePlain target:nil action:nil];
    [self initNavBtn];
    
    if (@available(iOS 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAlways];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
        media_weak(self);
        [MediaPhotoManager getPhotoAblumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage complete:^(NSArray<MediaAlbumListModel *> *albums) {
            media_strong(weakSelf);
            strongSelf.arrayDataSources = [NSMutableArray arrayWithArray:albums];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.tableView reloadData];
            });
        }];
    });
}

- (void)initNavBtn
{
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:configuration.navTitleColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)navRightBtn_Click
{
    MediaImageNavigationController *nav = (MediaImageNavigationController *)self.navigationController;
    if (nav.cancelBlock) {
        nav.cancelBlock();
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
        self.placeholderView.hidden = NO;
    } else {
        self.placeholderView.hidden = YES;
    }
    return self.arrayDataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaPhotoBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MediaPhotoBrowserCell"];
    
    if (!cell) {
        cell = [[kZLPhotoBrowserBundle loadNibNamed:@"MediaPhotoBrowserCell" owner:self options:nil] lastObject];
    }
    
    MediaAlbumListModel *albumModel = self.arrayDataSources[indexPath.row];
    
    MediaPhotoConfiguration *configuration = [(MediaImageNavigationController *)self.navigationController configuration];
    
    cell.cornerRadio = configuration.cellCornerRadio;
    
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
    MediaAlbumListModel *model = self.arrayDataSources[index];
    
    MediaThumbnailViewController *tvc = [[MediaThumbnailViewController alloc] init];
    tvc.albumListModel = model;
    
    [self.navigationController showViewController:tvc sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
