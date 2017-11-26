//
//  ViewController.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "ViewController.h"
#import "DataDownloadManager.h"
static NSString * const downloadUrl = @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4";
@interface ViewController ()
@property (nonatomic, strong) UIButton *downloadButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (UIButton *)downloadButton{
    if (!_downloadButton) {
        _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = 60;
        CGFloat height = 40;
        _downloadButton.frame = CGRectMake((CGRectGetWidth(self.view.frame) - width) / 2, (CGRectGetHeight(self.view.frame) - height) / 2, width, height);
        [_downloadButton setTitle:@"下载" forState: UIControlStateNormal];
        _downloadButton.backgroundColor = [UIColor blueColor];
        [_downloadButton addTarget:self action:@selector(downloadClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (void)downloadClick:(UIButton *)btn{
    DataDownloadManager *manager = [DataDownloadManager defaultManager];
    DataDownloadModel *model = [manager currentDownloadingModelWithURLString:downloadUrl];
    if (model) {
        [manager downloadWithModel:model downloadProgress:^(DataDownloadProgress *progress) {
            NSLog(@"download progress ---> %f",progress.progress);
            NSLog(@"download speed ---> %f",progress.speed);
            NSLog(@"download bytesWritten ---> %lld",progress.bytesWritten);
            NSLog(@"download totalBytesWritten ---> %lld",progress.totalBytesWritten);
            NSLog(@"download totalBytesExpectedToWrite ---> %lld",progress.totalBytesExpectedToWrite);
        } downloadState:^(DataDownloadState state, NSString *filePath, NSError *error) {
            if (state == DataDownloadStateCompleted) {
                NSLog(@"download file path ----> %@", filePath);
            }
        }];
        return;
    }
    model = [[DataDownloadModel alloc] initWithURLString:downloadUrl];
    
}

- (void)startDownload{
    DataDownloadManager *manager = [DataDownloadManager defaultManager];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
