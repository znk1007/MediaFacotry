//
//  MediaButton.m
//  MediaFacotry
//
//  Created by 黄漫 on 2017/11/26.
//  Copyright © 2017年 HM. All rights reserved.
//
#import <objc/runtime.h>
#import "MediaButton.h"
#import "DataDownloadManager.h"
#define mediaFacotryActivityIndicatorViewTag (10000)
#define mediaFacotryCoverViewTag (10001)


@implementation UIButton (MediaFacotry)


- (DataDownloadModel *)imageModelWithURLString:(NSString *)URLString{
    DataDownloadModel *model = [[DataDownloadManager defaultManager] currentDownloadingModelWithURLString:URLString];
    return nil;
    
}

- (void)znk_setImageWithURL:(NSString *)URLString forState:(UIControlState)state{
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
