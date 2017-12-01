//
//  MeidaGIFImageView.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/29.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaGIFImage:UIImage

/**
 每一帧时长
 */
@property (readonly) NSTimeInterval *frameDurations;

/**
 总时长
 */
@property (readonly) NSTimeInterval totalDuration;

/**
 循环次数
 */
@property (readonly) NSUInteger loopCount;

/**
 获取某一帧图片

 @param index 帧下标
 @return 图片对象
 */
- (UIImage *)frameAtIndex:(NSUInteger)index;
@end

@interface MediaGIFImageView : UIImageView

/**
 GIF重复播放次数
 */
@property (nonatomic, assign) NSUInteger repeatCount;//default is 0 不断重复;

/**
 循环mode
 */
@property (nonatomic, copy) NSString *runLoopMode;

/**
 重新播放
 */
- (void)reStart;

/**
 停止播放
 */
- (void)stop;
@end
