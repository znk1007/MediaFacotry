//
//  MediaNoAuthorityViewController.m
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaNoAuthorityViewController.h"
#import "MediaDefine.h"

@interface MediaNoAuthorityViewController ()
{
    UIImageView *_imageView;
    UILabel *_labPrompt;
}

@end

@implementation MediaNoAuthorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = GetLocalLanguageTextValue(MediaPhotoBrowserPhotoText);
    
    _imageView = [[UIImageView alloc] initWithImage:GetImageWithName(@"lock")];
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.frame = CGRectMake((kMediaViewWidth-kMediaViewWidth/3)/2, 100, kMediaViewWidth/3, kMediaViewWidth/3);
    [self.view addSubview:_imageView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(GetLocalLanguageTextValue(MediaPhotoBrowserCancelText), 16, YES, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:GetLocalLanguageTextValue(MediaPhotoBrowserCancelText) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    NSString *message = [NSString stringWithFormat:GetLocalLanguageTextValue(MediaPhotoBrowserNoAblumAuthorityText), [[NSBundle mainBundle].infoDictionary valueForKey:@"CFBundleDisplayName"]];
    
    _labPrompt = [[UILabel alloc] init];
    _labPrompt.numberOfLines = 0;
    _labPrompt.font = [UIFont systemFontOfSize:14];
    _labPrompt.textColor = kMediaRGB(170, 170, 170);
    _labPrompt.text = message;
    _labPrompt.frame = CGRectMake(50, CGRectGetMaxY(_imageView.frame), kMediaViewWidth-100, 100);
    _labPrompt.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labPrompt];
    
    self.navigationItem.hidesBackButton = YES;
}

- (void)navRightBtn_Click
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
