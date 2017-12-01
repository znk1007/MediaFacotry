//
//  MediaLargeImageCell.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaModel.h"

@import PhotosUI;
@class MediaPreviewView;
@interface MediaLargeImageCell : UICollectionViewCell
@property (nonatomic, assign) BOOL showGif;
@property (nonatomic, assign) BOOL showLivePhoto;

@property (nonatomic, strong) MediaPreviewView *previewView;
@property (nonatomic, strong) MediaModel *model;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);
@property (nonatomic, copy)   void (^longPressCallBack)(void);
@property (nonatomic, assign) BOOL willDisplaying;


/**
 界面停止滑动后，加载gif和livephoto，保持界面流畅
 */
- (void)reloadGifLivePhoto;

/**
 界面滑动时，停止播放gif、livephoto、video
 */
- (void)pausePlay;
@end

//预览大图，image、gif、livephoto、video

@class MediaPreviewImageAndGif;
@class MediaPreviewLivePhoto;
@class MediaPreviewVideo;

@interface MediaPreviewView : UIView

@property (nonatomic, assign) BOOL showGif;
@property (nonatomic, assign) BOOL showLivePhoto;

@property (nonatomic, strong) MediaPreviewImageAndGif *imageGifView;
@property (nonatomic, strong) MediaPreviewLivePhoto *livePhotoView;
@property (nonatomic, strong) MediaPreviewVideo *videoView;
@property (nonatomic, strong) MediaModel *model;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);
@property (nonatomic, copy)   void (^longPressCallBack)(void);

/**
 界面每次即将显示时，重置scrollview缩放状态
 */
- (void)resetScale;

/**
 处理划出界面后操作
 */
- (void)handlerEndDisplaying;

/**
 reload gif,livephoto,video
 */
- (void)reload;

- (void)resumePlay;

- (void)pausePlay;

- (UIImage *)image;

@end

//---------------base preview---------------
@interface MediaBasePreviewView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, copy)   void (^singleTapCallBack)(void);

- (void)singleTapAction;

- (void)loadNormalImage:(PHAsset *)asset;

- (void)resetScale;

- (UIImage *)image;

@end

//---------------image与gif---------------
@interface MediaPreviewImageAndGif : MediaBasePreviewView

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, copy)   void (^longPressCallBack)(void);

- (void)loadGifImage:(PHAsset *)asset;
- (void)loadImage:(id)obj;

- (void)resumeGif;
- (void)pauseGif;

@end


//---------------livephoto---------------
PHOTOS_CLASS_AVAILABLE_IOS_TVOS(9_1, 10_0)
@interface MediaPreviewLivePhoto : MediaBasePreviewView

@property (nonatomic, strong) PHLivePhotoView *lpView PHOTOS_AVAILABLE_IOS_TVOS(9_1, 10_0);

- (void)loadLivePhoto:(PHAsset *)asset;

- (void)stopPlayLivePhoto;

@end


//---------------video---------------
@interface MediaPreviewVideo : MediaBasePreviewView

@property (nonatomic, strong) AVPlayerLayer *playLayer;
@property (nonatomic, strong) UILabel *icloudLoadFailedLabel;
@property (nonatomic, strong) UIButton *playBtn;

- (BOOL)haveLoadVideo;

- (void)stopPlayVideo;

@end
