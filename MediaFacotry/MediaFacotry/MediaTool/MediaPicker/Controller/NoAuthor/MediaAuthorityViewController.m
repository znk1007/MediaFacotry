//
//  MediaAuthorityViewController.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaAuthorityViewController.h"
#import "MediaShiningLabel.h"

@interface MediaAuthorityViewController ()

/**
 闪烁文件标签
 */
@property (nonatomic, strong) MediaShiningLabel *shiningLabel;
@end

@implementation MediaAuthorityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view addSubview:self.shiningLabel];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_shiningLabel removeFromSuperview];
    _shiningLabel = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MediaShiningLabel *)shiningLabel{
    if (!_shiningLabel) {
        _shiningLabel = [[MediaShiningLabel alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.view.frame) - Media_Shining_Label_Height) / 2, CGRectGetWidth(self.view.frame), Media_Shining_Label_Height)];
        _shiningLabel.text = @"您无权限访问";
        _shiningLabel.textColor = [UIColor grayColor];
        _shiningLabel.font = [UIFont boldSystemFontOfSize:25];
        _shiningLabel.shimmerColor = MediaColor(255, 96, 94);
        [_shiningLabel startShimmer];
    }
    return _shiningLabel;
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
