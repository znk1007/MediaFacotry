//
//  MediaThumbnailViewController.h
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaAlbumListModel;

@interface MediaThumbnailViewController : UIViewController

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *bline;
@property (nonatomic, strong) UIButton *btnEdit;
@property (nonatomic, strong) UIButton *btnPreView;
@property (nonatomic, strong) UIButton *btnOriginalPhoto;
@property (nonatomic, strong) UILabel *labPhotosBytes;
@property (nonatomic, strong) UIButton *btnDone;

//相册model
@property (nonatomic, strong) MediaAlbumListModel *albumListModel;

@end
