//
//  MediaPlayer.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPlayer.h"

@interface MediaPlayer ()

/**
 播放层
 */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/**
 播放器
 */
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
    [self.layer addSublayer:self.playerLayer];
}

#pragma mark - getter

- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.frame = self.bounds;
    }
    return _playerLayer;
}

- (void)setVideoUrl:(NSURL *)videoUrl
{
    if (_player) {
        [_player pause];
        _player = nil;
    }
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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
