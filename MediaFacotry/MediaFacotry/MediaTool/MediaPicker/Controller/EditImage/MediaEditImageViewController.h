//
//  MediaEditImageViewController.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/30.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaModel.h"

@interface MediaEditImageViewController : UIViewController
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) MediaModel *model;
@end
