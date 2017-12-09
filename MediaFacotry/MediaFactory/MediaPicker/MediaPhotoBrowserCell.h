//
//  MediaPhotoBrowserCell.h
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MediaAlbumListModel;

@interface MediaPhotoBrowserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labCount;
@property (nonatomic, assign) CGFloat cornerRadio;

@property (nonatomic, strong) MediaAlbumListModel *model;

@end
