//
//  MediaPlayer.m
//  CustomCamera
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface MediaPlayer ()

@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation MediaPlayer

- (void)dealloc
{
    [self removeObserver];
    [_player pause];
    _player = nil;
//    NSLog(@"---- %s", __FUNCTION__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0;
    self.playerLayer = [[AVPlayerLayer alloc] init];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
}

- (void)setVideoUrl:(NSURL *)videoUrl
{
    _player = [AVPlayer playerWithURL:videoUrl];
    if (@available(iOS 10.0, *)) {
        _player.automaticallyWaitsToMinimizeStalling = NO;
    } else {
        // Fallback on earlier versions
    }
    [_player addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.playerLayer.player = _player;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        if (_player.status == AVPlayerStatusReadyToPlay) {
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 1;
            }];
        }
    }
}

- (void)playFinished
{
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

- (void)play
{
    [_player play];
}

- (void)pause
{
    [_player pause];
}

- (void)reset
{
    [self removeObserver];
    [_player pause];
    _player = nil;
}

- (BOOL)isPlay
{
    return _player && _player.rate > 0;
}

- (void)removeObserver
{
    [_player removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
