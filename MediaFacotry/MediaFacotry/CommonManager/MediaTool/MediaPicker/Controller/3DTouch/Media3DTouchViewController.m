//
//  Media3DTouchViewController.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//
@import PhotosUI;

#import "Media3DTouchViewController.h"
#import "MediaGIFImageView.h"

@interface Media3DTouchViewController ()

@end

@implementation Media3DTouchViewController

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
    switch (self.model.assetType) {
        case MediaAssetTypeImage:
            [self loadNormalImage];
            break;
            
        case MediaAssetTypeGif:
            self.allowSelectGif ? [self loadGifImage] : [self loadNormalImage];
            break;
            
        case MediaAssetTypeLivePhoto:
            self.allowSelectLivePhoto ? [self loadLivePhoto] : [self loadNormalImage];
            break;
            
        case MediaAssetTypeVideo:
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
    
    [[MediaFactory sharedFactory].photo requestImageForAsset:self.model.phAsset size:CGSizeMake(size.width * 2, size.height * 2) completion:^(UIImage *img, NSDictionary *info) {
        imageView.image = img;
    }];
}

- (void)loadGifImage
{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = (CGRect){CGPointZero, [self getSize]};
    [self.view addSubview:imageView];
    
    [[MediaFactory sharedFactory].photo requestOriginalImageDataForAsset:self.model.phAsset completion:^(NSData *data, NSDictionary *info) {
        imageView.image = [MediaGIFImage imageWithData:data];
    }];
}

- (void)loadLivePhoto
{
    if (@available(iOS 9.1, *)) {
        PHLivePhotoView *lpView = [[PHLivePhotoView alloc] init];
        lpView.contentMode = UIViewContentModeScaleAspectFit;
        lpView.frame = (CGRect){CGPointZero, [self getSize]};
        [self.view addSubview:lpView];
        
        [[MediaFactory sharedFactory].photo requestLivePhotoForAsset:self.model.phAsset completion:^(PHLivePhoto *lv, NSDictionary *info) {
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
    
    [[MediaFactory sharedFactory].photo requestVideoForAsset:self.model.phAsset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            playLayer.player = player;
            [player play];
        });
    }];
}

- (CGSize)getSize
{
    CGFloat w = MIN(self.model.phAsset.pixelWidth, kMediaScreenWidth);
    CGFloat h = w * self.model.phAsset.pixelHeight / self.model.phAsset.pixelWidth;
    if (isnan(h)) return CGSizeZero;
    
    if (h > kMediaScreenHeight) {
        h = kMediaScreenHeight;
        w = h * self.model.phAsset.pixelWidth / self.model.phAsset.pixelHeight;
    }
    
    return CGSizeMake(w, h);
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
