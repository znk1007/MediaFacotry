//
//  MediaForceTouchPreviewController.m
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaForceTouchPreviewController.h"
#import "MediaDefine.h"
#import "MediaPhotoManager.h"
#import "MediaPhotoModel.h"
#import <PhotosUI/PhotosUI.h>

@interface MediaForceTouchPreviewController ()

@end

@implementation MediaForceTouchPreviewController

- (void)dealloc
{
//    NSLog(@"---- %s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithWhite:.8 alpha:.5];
    
    switch (self.model.type) {
        case MediaAssetMediaTypeImage:
            [self loadNormalImage];
            break;
        
        case MediaAssetMediaTypeGif:
            self.allowSelectGif ? [self loadGifImage] : [self loadNormalImage];
            break;
            
        case MediaAssetMediaTypeLivePhoto:
            self.allowSelectLivePhoto ? [self loadLivePhoto] : [self loadNormalImage];
            break;
            
        case MediaAssetMediaTypeVideo:
            [self loadVideo];
            break;
            
        default:
            break;
    }
}

#pragma mark - 加载静态图
- (void)loadNormalImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    CGSize size = [self getSize];
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [MediaPhotoManager requestImageForAsset:self.model.asset size:CGSizeMake(size.width*2, size.height*2) completion:^(UIImage *img, NSDictionary *info) {
        imageView.image = img;
    }];
}

- (void)loadGifImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [MediaPhotoManager requestOriginalImageDataForAsset:self.model.asset completion:^(NSData *data, NSDictionary *info) {
        imageView.image = [MediaPhotoManager transformToGifImageWithData:data];
    }];
}

- (void)loadLivePhoto
{
    if (@available(iOS 9.1, *)) {
        PHLivePhotoView *lpView = [[PHLivePhotoView alloc] init];
        lpView.contentMode = UIViewContentModeScaleAspectFit;
        lpView.frame = (CGRect){CGPointZero, [self getSize]};
        [self.view addSubview:lpView];
        
        [MediaPhotoManager requestLivePhotoForAsset:self.model.asset completion:^(PHLivePhoto *lv, NSDictionary *info) {
            lpView.livePhoto = lv;
            [lpView startPlaybackWithStyle:PHLivePhotoViewPlaybackStyleFull];
        }];
    }
}

- (void)loadVideo
{
    AVPlayerLayer *playLayer = [[AVPlayerLayer alloc] init];
    playLayer.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view.layer addSublayer:playLayer];
    
    [MediaPhotoManager requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            playLayer.player = player;
            [player play];
        });
    }];
}

- (CGSize)getSize
{
    CGFloat w = MIN(self.model.asset.pixelWidth, kMediaViewWidth);
    CGFloat h = w * self.model.asset.pixelHeight / self.model.asset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kMediaViewHeight) {
        h = kMediaViewHeight;
        w = h * self.model.asset.pixelWidth / self.model.asset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
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
