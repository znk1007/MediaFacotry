//
//  MediaButton.m
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/26.
//  Copyright © 2017年 HM. All rights reserved.
//
#import <objc/runtime.h>
#import "MediaButton.h"
#import "DataDownloadManager.h"
#import "MediaExtension.h"

#define mediaFactoryActivityIndicatorViewTag (10000)
#define mediaFactoryCoverViewTag (10001)
#define mediaFactoryIndicatorViewWithAndHeight (20)

@interface UIView (MediaFactoryView)

/**
 加载菊花
 */
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

/**
 遮罩
 */
@property (nonatomic, strong) UIView *coverView;

/**
 进度条
 */
@property (nonatomic, strong) UIProgressView *progressView;

/**
 添加菊花
 */
- (void)znk_addIndicatorView;

/**
 移除菊花
 */
- (void)znk_removeIndicatorView;

/**
 添加遮罩
 */
- (void)znk_addCoverView;

/**
 移除遮罩
 */
- (void)znk_removeCoverView;

/**
 添加进度条
 */
- (void)znk_addProgressViewWithProgress:(float)progress;

/**
 移除
 */
- (void)znk_removeProgressView;
@end

@implementation UIView (MediaFactoryView)


- (void)setIndicatorView:(UIActivityIndicatorView *)indicatorView{
    objc_setAssociatedObject(self, @selector(indicatorView), indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)indicatorView{
    return (UIActivityIndicatorView *)objc_getAssociatedObject(self, @selector(indicatorView));
}

- (void)setCoverView:(UIView *)coverView{
    objc_setAssociatedObject(self, @selector(coverView), coverView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)coverView{
    return (UIView *)objc_getAssociatedObject(self, @selector(coverView));
}

- (void)setProgressView:(UIProgressView *)progressView{
    objc_setAssociatedObject(self, @selector(progressView), progressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIProgressView *)progressView{
    return (UIProgressView *)objc_getAssociatedObject(self, @selector(progressView));
}

/**
 添加菊花
 */
- (void)znk_addIndicatorView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.indicatorView) {
            self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
            self.indicatorView.hidesWhenStopped = YES;
            [self addSubview:self.indicatorView];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.indicatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
        }
        [self.indicatorView startAnimating];
    });
}

/**
 移除菊花
 */
- (void)znk_removeIndicatorView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.indicatorView) {
            [self.indicatorView stopAnimating];
            [self.indicatorView removeFromSuperview];
            self.indicatorView = nil;
        }
    });
}

/**
 添加遮罩
 */
- (void)znk_addCoverView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.coverView) {
            self.coverView = [[UIView alloc] init];
            self.coverView.translatesAutoresizingMaskIntoConstraints = NO;
            self.coverView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
            [self addSubview:self.coverView];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.coverView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.coverView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.coverView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.coverView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
        }
    });
}

/**
 移除遮罩
 */
- (void)znk_removeCoverView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.coverView) {
            [self.coverView removeFromSuperview];
            self.coverView = nil;
        }
    });
}

/**
 添加进度条
 */
- (void)znk_addProgressViewWithProgress:(float)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.progressView) {
            self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            self.progressView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:96 / 255.0 blue:94 / 255.0 alpha:1.0];
            [self addSubview:self.progressView];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        }
        self.progressView.progress = progress;
        if (progress >= 1.0) {
            [self znk_removeProgressView];
        }
    });
}

/**
 移除
 */
- (void)znk_removeProgressView{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressView) {
            [self.progressView removeFromSuperview];
            self.progressView = nil;
        }
    });
}

/**
 UIImageView、UIButton设置网络图片基方法

 @param URLString 下载路径
 @param placeholderImage 占位图
 @param isBackgroundImage UIButton是否为backgroundImage
 @param options MediaFactoryImageOptions
 @param completion 完成block
 */
- (void)znk_setImageWithURLString:(NSString * _Nullable)URLString forState:(UIControlState)state placeholderImage:(UIImage * _Nullable)placeholderImage isBackgroundImage:(BOOL)isBackgroundImage fixSize:(BOOL)fixSize options:(MediaFactoryImageOptions)options completion:(void(^)(BOOL finished, NSError * _Nullable error, UIImage * _Nullable image))completion{
    if (placeholderImage) {
        [self znk_setImageWithImage:placeholderImage forState:state isBackgroundImage:isBackgroundImage];
    }
    if (!URLString || [URLString isEqualToString:@""] || (![URLString hasPrefix:@"http://"] && ![URLString hasPrefix:@"https://"])) {
        return;
    }
    NSString *filePath = [self znk_imageFilePathWithURLString:URLString];
    //如filePath存在，则直接显示
    if (filePath) {
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:imageData];
        if (fixSize) {
            image = [image fixSquareImage];
        }
        [self znk_setImageWithImage:image forState:state isBackgroundImage:isBackgroundImage];
        return;
    }
    //不存在则下载
    [self znk_addSubviewsWithOptions:options];
    __weak typeof(self) weakSelf = self;
    [self znk_imageModelWithURLString:URLString completion:^(DataDownloadState downloadState, float progress, NSString *filePath, NSError *error) {
        [weakSelf znk_handleSubviewsWithOptions:options downloadProgress:progress filePath:filePath downloadState:downloadState controlState:state isBackgroundImage:isBackgroundImage fixSize:fixSize];
        
        if (completion) {
            if (downloadState == DataDownloadStateCompleted) {
                NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                UIImage *image = [UIImage imageWithData:imageData];
                completion(YES, nil, image);
            } else {
                NSError *err = nil;
                if (downloadState == DataDownloadStateFailed) {
                    err = error;
                }
                completion(NO, err, nil);
            }
        }
    }];
}

#pragma mark - 数据请求，处理

/**
 下载资源文件

 @param URLString 下载路径
 @param completion 完成block
 */
- (void)znk_imageModelWithURLString:(NSString *)URLString completion:(void(^)(DataDownloadState state, float progress, NSString *filePath, NSError *error))completion{
    DataDownloadManager *manager = [DataDownloadManager defaultManager];
    DataDownloadModel *model = [manager currentDownloadingModelWithURLString:URLString];
    if (model) {
        if (model.state == DataDownloadStateReady || model.state == DataDownloadStateRunning) {
            DataDownloadProgress *progress = [manager currentProgressWithDownloadModel:model];
            if (completion) {
                completion(model.state, progress.progress, nil, nil);
            }
            return;
        }
        if (model.state == DataDownloadStateSuspended) {
            [manager resumeDownloadWithModel:model];
            if (completion) {
                __weak typeof(model) weakModel = model;
                model.stateBlock = ^(DataDownloadState state, NSString *filePath, NSError *error) {
                    if (state == DataDownloadStateCompleted) {
                        completion(state, 1.0, filePath, nil);
                    }else if (state == DataDownloadStateFailed){
                        completion(state, 0.0, nil, error);
                    }
                };
                model.progressBlock = ^(DataDownloadProgress *progress) {
                    completion(weakModel.state, progress.progress, nil, nil);
                };
            }
            return;
        }
        if ([manager isDownloadCompletedWithDownloadModel:model]) {
            if (completion) {
                completion(DataDownloadStateCompleted, 1.0f, model.filePath, nil);
            }
            return;
        }
        [self znk_startDownloadWithModel:model completion:completion];
        return;
    }
    model = [[DataDownloadModel alloc] initWithURLString:URLString];
    if ([manager isDownloadCompletedWithDownloadModel:model]) {
        if (completion) {
            completion(model.state, 1.0f, model.filePath, nil);
        }
        return;
    }
    [self znk_startDownloadWithModel:model completion:completion];
}


/**
 下载DataDownloadModel

 @param model DataDownloadModel
 @param completion 完成block
 */
- (void)znk_startDownloadWithModel:(DataDownloadModel *)model completion:(void(^)(DataDownloadState state, float progress, NSString *filePath, NSError *error))completion{
    DataDownloadManager *manager = [DataDownloadManager defaultManager];
    [manager downloadWithModel:model downloadProgress:^(DataDownloadProgress *progress) {
        if (completion) {
            completion(model.state, progress.progress, nil, nil);
        }
    } downloadState:^(DataDownloadState state, NSString *filePath, NSError *error) {
        if (completion) {
            if (error) {
                completion(state, 0.0, nil, error);
            } else {
                completion(state, 1.0, filePath, nil);
            }
        }
    }];
}


/**
 根据URLString获取DataDownloadModel，用户下载，暂停，删除

 @param URLString 下载路径
 @return DataDownloadModel
 */
- (DataDownloadModel *)znk_downloadModelWithURLString:(NSString *)URLString{
    return [[DataDownloadManager defaultManager] currentDownloadingModelWithURLString:URLString];
}

/**
 本地文件是否存在

 @param URLString 下载路径
 @return 文件路径
 */
- (NSString *)znk_imageFilePathWithURLString:(NSString *)URLString{
    DataDownloadManager *manager = [DataDownloadManager defaultManager];
    DataDownloadModel *model = [manager currentDownloadingModelWithURLString:URLString];
    if (model) {
        if ([manager isDownloadCompletedWithDownloadModel:model]) {
            return model.filePath;
        }
        return nil;
    }
    model = [[DataDownloadModel alloc] initWithURLString:URLString];
    if ([manager isDownloadCompletedWithDownloadModel:model]) {
        return model.filePath;
    }
    return nil;
}

/**
 UIImageView、UIButton设置图片

 @param image 图片
 @param state 状态
 @param isBackgroundImage 是否背景图
 */
- (void)znk_setImageWithImage:(UIImage *)image forState:(UIControlState)state isBackgroundImage:(BOOL)isBackgroundImage{
    if ([self isKindOfClass:[UIImageView class]]) {
        UIImageView *imageView = (UIImageView *)self;
        imageView.image = image;
    } else if ([self isKindOfClass:[UIButton class]]){
        UIButton *imageButton = (UIButton *)self;
        if (isBackgroundImage) {
            [imageButton setBackgroundImage:image forState:UIControlStateNormal];
        } else {
            [imageButton setImage:image forState:UIControlStateNormal];
        }
    }
}

/**
 根据MediaFactoryImageOptions添加视图

 @param options MediaFactoryImageOptions
 */
- (void)znk_addSubviewsWithOptions:(MediaFactoryImageOptions)options{
    switch (options) {
        case MediaFactoryImageOptionsNormal:
        {
            
        }
            break;
        case MediaFactoryImageOptionsCover:
        {
            [self znk_addCoverView];
        }
            break;
        case MediaFactoryImageOptionsIndicator:
        {
            [self znk_addIndicatorView];
        }
            break;
        case MediaFactoryImageOptionsProgressBar:
        {
            [self znk_addProgressViewWithProgress:0.0f];
        }
            break;
        case MediaFactoryImageOptionsCoverAndIndicator:
        {
            [self znk_addCoverView];
            [self znk_addIndicatorView];
        }
            break;
        case MediaFactoryImageOptionsCorverAndProgressBar:
        {
            [self znk_addCoverView];
            [self znk_addProgressViewWithProgress:0.0f];
        }
            break;
            
        default:
            break;
    }
}

- (void)znk_handleSubviewsWithOptions:(MediaFactoryImageOptions)options downloadProgress:(float)downloadProgress filePath:(NSString *)filePath downloadState:(DataDownloadState)downloadState controlState:(UIControlState)controlState isBackgroundImage:(BOOL)isBackgroundImage fixSize:(BOOL)fixSie{
    switch (options) {
        case MediaFactoryImageOptionsNormal:
        {
            
        }
            break;
        case MediaFactoryImageOptionsCover:
        {
            if (downloadState == DataDownloadStateFailed || downloadState == DataDownloadStateCompleted) {
                [self znk_removeCoverView];
            }
        }
            break;
        case MediaFactoryImageOptionsIndicator:
        {
            if (downloadState == DataDownloadStateFailed || downloadState == DataDownloadStateCompleted) {
                [self znk_removeIndicatorView];
            }
        }
            break;
        case MediaFactoryImageOptionsProgressBar:
        {
            [self znk_addProgressViewWithProgress:downloadProgress];
            if (downloadState == DataDownloadStateFailed || downloadState == DataDownloadStateCompleted) {
                [self znk_removeProgressView];
            }
        }
            break;
        case MediaFactoryImageOptionsCoverAndIndicator:
        {
            if (downloadState == DataDownloadStateFailed || downloadState == DataDownloadStateCompleted) {
                [self znk_removeCoverView];
                [self znk_removeIndicatorView];
            }
        }
            break;
        case MediaFactoryImageOptionsCorverAndProgressBar:
        {
            [self znk_addProgressViewWithProgress:downloadProgress];
            if (downloadState == DataDownloadStateFailed || downloadState == DataDownloadStateCompleted) {
                [self znk_removeCoverView];
                [self znk_removeProgressView];
            }
        }
            break;
            
        default:
            break;
    }
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:imageData];
    if (fixSie) {
        image = [image fixSquareImage];
    }
    [self znk_setImageWithImage:image forState:controlState isBackgroundImage:isBackgroundImage];
}

/**
 移除视图
 */
- (void)znk_removeSubviews{
    [self znk_removeCoverView];
    [self znk_removeIndicatorView];
    [self znk_removeProgressView];
}

@end


@implementation UIButton (MediaFacotry)


- (void)znk_setImageWithURL:(NSString *)URLString forState:(UIControlState)state{
    [self znk_setImageWithURLString:URLString forState:state placeholderImage:nil isBackgroundImage:NO fixSize:NO options:MediaFactoryImageOptionsNormal completion:nil];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
