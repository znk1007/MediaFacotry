//
//  MediaTableCell.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/12/1.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaModel.h"

@interface MediaTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labCount;
@property (nonatomic, assign) CGFloat cornerRadio;
@property (nonatomic, strong) MediaListModel *model;
@end
