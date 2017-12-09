//
//  MediaEditImageController.h
//  MediaPhotoBrowser
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaPhotoModel;

@interface MediaEditImageController : UIViewController

@property (nonatomic, strong) UIImage *oriImage;
@property (nonatomic, strong) MediaPhotoModel *model;

@end
