//
//  MediaProgressHUD.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaProgressHUD.h"

@interface MediaProgressHUD ()

/**
 遮罩视图
 */
@property (nonatomic, strong) UIView *hudCoverView;

/**
 提示标签
 */
@property (nonatomic, strong) UILabel *hudLabel;

/**
 菊花
 */
@property (nonatomic, strong) UIActivityIndicatorView *hudIndicator;
@end

@implementation MediaProgressHUD

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

#pragma mark - getter

- (UIView *)hudCoverView{
    if (!_hudCoverView) {
        _hudCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 110, 80)];
        _hudCoverView.layer.masksToBounds = YES;
        _hudCoverView.layer.cornerRadius = 5.0f;
        _hudCoverView.backgroundColor = [UIColor darkGrayColor];
        _hudCoverView.alpha = 0.8;
        _hudCoverView.center = self.center;
    }
    return _hudCoverView;
}

- (UIActivityIndicatorView *)hudIndicator{
    if (!_hudIndicator) {
        _hudIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(40, 15, 30, 30)];
        _hudIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [_hudIndicator startAnimating];
    }
    return _hudIndicator;
}

- (UILabel *)hudLabel{
    if (!_hudLabel) {
        _hudLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 110, 30)];
        _hudLabel.textAlignment = NSTextAlignmentCenter;
        _hudLabel.textColor = [UIColor whiteColor];
        _hudLabel.font = [UIFont systemFontOfSize:16];
        _hudLabel.text = @"正在处理...";
    }
    return _hudLabel;
}


- (void)createUI
{
    self.frame = [UIScreen mainScreen].bounds;
    [self addSubview:self.hudCoverView];
    [self.hudCoverView addSubview:self.hudIndicator];
    [self.hudCoverView addSubview:self.hudLabel];
}

- (void)show
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide];
    });
}

- (void)hide
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

@end
