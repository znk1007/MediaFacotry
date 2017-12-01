//
//  MediaCollectionCell.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaModel.h"

@interface MediaTakePhotoCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

- (void)startCapture;

- (void)restartCapture;
@end

@interface MediaCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *btnSelect;
@property (nonatomic, strong) UIImageView *videoBottomView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIImageView *liveImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *topView;

@property (nonatomic, assign) BOOL allSelectGif;
@property (nonatomic, assign) BOOL allSelectLivePhoto;
@property (nonatomic, assign) BOOL showSelectBtn;
@property (nonatomic, assign) CGFloat cornerRadio;
@property (nonatomic, strong) MediaModel *model;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) BOOL showMask;

@property (nonatomic, copy) void (^selectedBlock)(BOOL);
@end
