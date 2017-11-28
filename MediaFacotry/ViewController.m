//
//  ViewController.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaButton.h"

#import "ViewController.h"
#import "DataDownloadManager.h"
static NSString * const downloadUrl = @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4";
static NSString * const imageUrl = @"http://img0.pconline.com.cn/pconline/1410/17/5585300_03.jpg";

#define placeholderImage [UIImage imageNamed:@"placeholder.jpg"]

@interface ViewController ()<DataDownloadDelegate>
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *testButton1;
@property (nonatomic, strong) UIButton *testButton2;
@property (nonatomic, strong) UIButton *testButton3;
@property (nonatomic, strong) UIButton *testButton4;
@property (nonatomic, strong) UIButton *testButton5;

@property (nonatomic, strong) UIImageView *testImageView1;
@property (nonatomic, strong) UIImageView *testImageView2;
@property (nonatomic, strong) UIImageView *testImageView3;

@property (nonatomic, strong) UIButton *cleanButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    [self.view addSubview:self.downloadButton];
//    [DataDownloadManager defaultManager].delegate = self;
    [self.view addSubview:self.cleanButton];
    [self.view addSubview:self.testButton1];
    
}

- (UIButton *)cleanButton{
    if (!_cleanButton) {
        _cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = 60;
        CGFloat height = 40;
        _cleanButton.frame = CGRectMake((CGRectGetWidth(self.view.frame) - width) / 2, (CGRectGetHeight(self.view.frame) - height), width, height);
        [_cleanButton setTitle:@"清除" forState: UIControlStateNormal];
        _cleanButton.backgroundColor = [UIColor blueColor];
        [_cleanButton addTarget:self action:@selector(cleanClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanButton;
}

- (UIButton *)testButton1{
    if (!_testButton1) {
        _testButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        _testButton1.frame = CGRectMake(80, 100, 200, 200);
        [_testButton1 znk_setImageWithURL:imageUrl forState:UIControlStateNormal];
        [_testButton1 addTarget:self action:@selector(downloadImageClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testButton1;
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
        if (model.state == DataDownloadStateReady || model.state == DataDownloadStateRunning) {
            return;
        }
        if ([manager isDownloadCompletedWithDownloadModel:model]) {
            return;
        }
        [manager downloadWithModel:model downloadProgress:^(DataDownloadProgress *progress) {
            NSLog(@"download progress 1---> %f",progress.progress);
            NSLog(@"download speed 1---> %f",progress.speed);
            NSLog(@"download bytesWritten 1---> %lld",progress.bytesWritten);
            NSLog(@"download totalBytesWritten 1---> %lld",progress.totalBytesWritten);
            NSLog(@"download totalBytesExpectedToWrite 1---> %lld",progress.totalBytesExpectedToWrite);
        } downloadState:^(DataDownloadState state, NSString *filePath, NSError *error) {
            if (state == DataDownloadStateCompleted) {
                NSLog(@"download file path 1----> %@", filePath);
            }
        }];
        return;
    }
    model = [[DataDownloadModel alloc] initWithURLString:downloadUrl];
    if ([manager isDownloadCompletedWithDownloadModel:model]) {
        return;
    }
    [manager downloadWithModel:model downloadProgress:^(DataDownloadProgress *progress) {
        NSLog(@"download progress 2---> %f",progress.progress);
        NSLog(@"download speed 2---> %f",progress.speed);
        NSLog(@"download bytesWritten 2---> %lld",progress.bytesWritten);
        NSLog(@"download totalBytesWritten 2---> %lld",progress.totalBytesWritten);
        NSLog(@"download totalBytesExpectedToWrite 2---> %lld",progress.totalBytesExpectedToWrite);
    } downloadState:^(DataDownloadState state, NSString *filePath, NSError *error) {
        if (state == DataDownloadStateCompleted) {
            NSLog(@"download file path 2----> %@", filePath);
        }
    }];
}

- (void)downloadModel:(DataDownloadModel *)model didChangeState:(DataDownloadState)state dowloadFilePath:(NSString *)filePath downlaodError:(NSError *)error{
    if (state == DataDownloadStateCompleted) {
        NSLog(@"download file path 3----> %@", filePath);
    }
}

- (void)downloadModel:(DataDownloadModel *)model didUpdateDownloadProgress:(DataDownloadProgress *)progress{
    NSLog(@"download progress 3---> %f",progress.progress);
    NSLog(@"download speed 3---> %f",progress.speed);
    NSLog(@"download bytesWritten 3---> %lld",progress.bytesWritten);
    NSLog(@"download totalBytesWritten 3---> %lld",progress.totalBytesWritten);
    NSLog(@"download totalBytesExpectedToWrite 3---> %lld",progress.totalBytesExpectedToWrite);
}

- (void)cleanClick:(UIButton *)btn{
    [[DataDownloadManager defaultManager] deleteAllDownloadWithDownloadDirectory:nil];
}

- (void)downloadImageClick:(UIButton *)btn{
    [btn znk_setImageWithURL:imageUrl forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
