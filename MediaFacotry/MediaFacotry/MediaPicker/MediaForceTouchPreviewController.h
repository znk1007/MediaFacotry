//
//  MediaForceTouchPreviewController.h
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaPhotoModel;

@interface MediaForceTouchPreviewController : UIViewController

@property (nonatomic, assign) BOOL allowSelectGif;
@property (nonatomic, assign) BOOL allowSelectLivePhoto;
@property (nonatomic, strong) MediaPhotoModel *model;

@end
