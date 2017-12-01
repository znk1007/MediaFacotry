//
//  MediaTableCell.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/12/1.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaTableCell.h"
#import "MediaFactory.h"
#import "MediaExtension.h"

@interface MediaTableCell ()

@property (nonatomic, copy) NSString *identifier;

@end
@implementation MediaTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(MediaListModel *)model
{
    _model = model;
    
    if (self.cornerRadio > .0) {
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = self.cornerRadio;
    }
    
    __weak typeof(self) weakSelf = self;
    self.identifier = model.headImageAsset.localIdentifier;
    [[MediaFactory sharedFactory].photo requestImageForAsset:model.headImageAsset size:CGSizeMake(self.height * 2.5, self.height * 2.5) completion:^(UIImage *image, NSDictionary *info) {
        __strong typeof(weakSelf) strongSelf = self;
        if ([strongSelf.identifier isEqualToString:model.headImageAsset.localIdentifier]) {
            strongSelf.headImageView.image = image ? : [UIImage imageNamed:@"defaultphoto"];
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
