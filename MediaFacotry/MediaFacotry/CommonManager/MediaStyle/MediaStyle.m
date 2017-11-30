//
//  MediaStyle.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaStyle.h"
#import "MediaExtension.h"

@implementation MediaStyle

- (instancetype)init{
    self = [super init];
    if (self){
        [self setupDefault];
    }
    return self;
}

- (void)setupDefault{
    _navTranslucent = NO;
    _statusBarStyle = UIStatusBarStyleLightContent;
    _cellCornerRadio = 0;
}

#pragma mark - getter

- (UIColor *)navBarColor{
    if (!_navBarColor) {
        _navBarColor = [UIColor blackColor];
    }
    return _navBarColor;
}

- (UIColor *)bottomBtnsNormalTitleColor{
    if (!_bottomBtnsNormalTitleColor) {
        _bottomBtnsNormalTitleColor = MediaColor(80, 180, 234);
    }
    return _bottomBtnsNormalTitleColor;
}

- (UIColor *)bottomViewBgColor{
    if (!_bottomViewBgColor) {
        _bottomViewBgColor = [UIColor whiteColor];
    }
    return _bottomViewBgColor;
}

- (UIColor *)bottomBtnsDisableBgColor{
    if (!_bottomBtnsDisableBgColor) {
        _bottomBtnsDisableBgColor = MediaColor(200, 200, 200);
    }
    return _bottomBtnsDisableBgColor;
}

- (UIColor *)selectedMaskColor{
    if (!_selectedMaskColor) {
        _selectedMaskColor = [UIColor blackColor];
    }
    return _selectedMaskColor;
}

- (UIImage *)leftCutImage{
    if (!_leftCutImage) {
        _leftCutImage = [UIImage imageWithColor:MediaColor(255, 96, 94) size:CGSizeMake(11, kMediaEditItemHeight)];
    }
    return _leftCutImage;
}

- (UIImage *)rightCutImage{
    if (!_rightCutImage) {
        _leftCutImage = [UIImage imageWithColor:MediaColor(255, 96, 94) size:CGSizeMake(11, kMediaEditItemHeight)];
    }
    return _rightCutImage;
}

- (UIImage *)cutBarImage{
    if (!_cutBarImage) {
        _cutBarImage = [UIImage imageWithColor:MediaColor(255, 96, 94) size:CGSizeMake(11, kMediaEditItemHeight)];
    }
    return _cutBarImage;
}

#pragma mark - setter


@end
