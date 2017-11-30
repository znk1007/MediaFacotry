//
//  MediaRecordButton.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MediaRecordButton : UIView
/**仅允许单击*/
@property (nonatomic, assign) BOOL singleTap;
/**
 计时时长
 */
@property (nonatomic, assign) NSTimeInterval interval;
/**
 重置进度条
 */
@property (nonatomic, assign) BOOL resetProgress;
/**
 获取状态
 */
- (void)videoRecordState:(void(^)(MediaRecordButtonState state))completion;
/**
 获取时间
 */
- (void)videoRecordTime:(void(^)(NSInteger time))completion;
@end
