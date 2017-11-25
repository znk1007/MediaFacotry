//
//  MediaFactory.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaFactory.h"


@implementation MediaFactory
/**
 MediaFactory单例
 
 @return MediaFactory
 */
+ (MediaFactory *)sharedFactory{
    static MediaFactory *factory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        factory = [[self alloc] init];
    });
    return factory;
}

- (instancetype)init{
    self = [super init];
    if (self){
        
    }
    return self;
}

#pragma mark - Method
- (void)show{
    _style = [[MediaStyle alloc] init];
    _tool = [[MediaTool alloc] init];
}

- (void)hide{
    _style = nil;
    _tool = nil;
}
@end
