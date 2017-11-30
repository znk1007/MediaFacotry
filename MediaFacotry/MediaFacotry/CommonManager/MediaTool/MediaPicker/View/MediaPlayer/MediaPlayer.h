//
//  MediaPlayer.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaPlayer : UIView

/**
 视频播放地址
 */
@property (nonatomic, strong) NSURL *videoUrl;
/**
 开始播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 重置
 */
- (void)reset;

/**
 是否正在播放
 */
- (BOOL)isPlay;
@end
