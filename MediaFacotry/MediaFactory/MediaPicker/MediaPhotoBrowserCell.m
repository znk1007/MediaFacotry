//
//  MediaPhotoBrowserCell.m
//  多选相册照片
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaPhotoBrowserCell.h"
#import "MediaPhotoModel.h"
#import "MediaPhotoManager.h"
#import "MediaDefine.h"

@interface MediaPhotoBrowserCell ()

@property (nonatomic, copy) NSString *identifier;

@end

@implementation MediaPhotoBrowserCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setModel:(MediaAlbumListModel *)model
{
    _model = model;
    
    if (self.cornerRadio > .0) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.cornerRadio;
    }
    
    media_weak(self);
    
    self.identifier = model.headImageAsset.localIdentifier;
    [MediaPhotoManager requestImageForAsset:model.headImageAsset size:CGSizeMake(GetViewHeight(self)*2.5, GetViewHeight(self)*2.5) completion:^(UIImage *image, NSDictionary *info) {
        media_strong(weakSelf);
        
        if ([strongSelf.identifier isEqualToString:model.headImageAsset.localIdentifier]) {
            strongSelf.headImageView.image = image?:GetImageWithName(@"defaultphoto");
        }
    }];
    
    self.labTitle.text = model.title;
    self.labCount.text = [NSString stringWithFormat:@"(%ld)", model.count];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
