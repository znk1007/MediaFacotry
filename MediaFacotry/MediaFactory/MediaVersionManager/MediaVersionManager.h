//
//  MediaVersionManager.h
//  MediaFacotry
//
//  Created by HuangSam on 2017/12/8.
//  Copyright © 2017年 HM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaVersionManager : NSObject
/**
 *  内部打开appstore default No.
 */
@property (nonatomic, assign) BOOL openAPPStoreInsideAPP;
/**
 设置区域
 */
@property (nonatomic, copy) NSString *countryAbbreviation;
/**
 *  单例
 */
+ (instancetype)sharedCheckManager;
/**
 *  检查版本,默认方法
 */
- (void)checkVersion;
/**
 *  提示框，下一版本，确定项
 */
- (void)checkVersionWithAlertTitle:(NSString *)alertTitle nextTimeTitle:(NSString *)nextTimeTitle confimTitle:(NSString *)confimTitle;
/**
 *  提示框，下一版本，确定项，跳过版本
 */
- (void)checkVersionWithAlertTitle:(NSString *)alertTitle nextTimeTitle:(NSString *)nextTimeTitle confimTitle:(NSString *)confimTitle skipVersionTitle:(NSString *)skipVersionTitle;
@end
