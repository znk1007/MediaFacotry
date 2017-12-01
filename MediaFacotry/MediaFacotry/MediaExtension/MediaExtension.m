//
//  MediaExtension.m
//  MediaFacotry
//
//  Created by HuangSam on 2017/11/21.
//  Copyright © 2017年 HM. All rights reserved.
//

#import "MediaExtension.h"
#import <objc/runtime.h>

@implementation NSObject (MediaExtension)

@end

@implementation UIViewController (MediaExtension)

- (void)showAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

@implementation UIView (MediaExtension)
- (void)setX:(CGFloat)x{
    
    CGRect frame   =self.frame;
    
    frame.origin.x = x;
    
    self.frame     = frame;
    
}


- (CGFloat)x{
    
    return self.frame.origin.x;
    
}


- (void)setY:(CGFloat)y{
    
    CGRect frame   =self.frame;
    
    frame.origin.y = y;
    
    self.frame     = frame;
    
}


- (CGFloat)y{
    
    return self.frame.origin.y;
    
}


- (void)setHeight:(CGFloat)height{
    
    CGRect frame        =self.frame;
    
    frame.size.height   = height;
    
    self.frame          = frame;
    
}


- (CGFloat)height{
    
    return self.frame.size.height;
    
}


- (void)setWidth:(CGFloat)width{
    
    CGRect frame        =self.frame;
    
    frame.size.width    = width;
    
    self.frame          = frame;
    
}


- (CGFloat)width{
    
    return self.frame.size.width;
    
}


- (void)setCenterX:(CGFloat)centerX

{
    
    CGPoint point =self.center;
    
    point.x       = centerX;
    
    self.center   = point;
    
}


- (CGFloat)centerX

{
    
    return self.center.x;
    
}


- (void)setCenterY:(CGFloat)centerY{
    
    CGPoint point   =self.center;
    
    point.y         = centerY;
    
    self.center     = point;
    
}


- (CGFloat)centerY

{
    
    return self.center.y;
    
}


- (void)setOrigin:(CGPoint)origin{
    
    CGRect frame =self.frame;
    
    frame.origin = origin;
    
    self.frame   = frame;
    
}


- (CGPoint)origin{
    
    return self.frame.origin;
    
}


- (void)setSize:(CGSize)size{
    
    CGRect frame    =self.frame;
    
    frame.size      = size;
    
    self.frame      = frame;
    
}


- (CGSize)size{
    
    return self.frame.size;
    
}
@end

@implementation UIImage (MediaExtension)
- (UIImage *)transformImageWithColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)fixSquareImage{
    CGSize newSize;
    CGImageRef imageRef = nil;
    if ((self.size.width / self.size.height) < 1) {
        newSize.width = self.size.width;
        newSize.height = self.size.width ;
        imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectMake(0, fabs(self.size.height - newSize.height) / 2, newSize.width, newSize.height));
    } else {
        newSize.height = self.size.height;
        newSize.width = self.size.height;
        imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectMake(fabs(self.size.width - newSize.width) / 2, 0, newSize.width, newSize.height));
    }
    return [UIImage imageWithCGImage:imageRef];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *colorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return colorImg;
}

@end

@implementation UIButton (MediaExtension)
static char topNameKey;
static char leftNameKey;
static char bottomNameKey;
static char rightNameKey;
- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right{
    objc_setAssociatedObject(self, &topNameKey, [NSNumber numberWithFloat:top], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &rightNameKey, [NSNumber numberWithFloat:right], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &bottomNameKey, [NSNumber numberWithFloat:bottom], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(self, &leftNameKey, [NSNumber numberWithFloat:left], OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGRect)enlargedRect
{
    NSNumber *topEdge = objc_getAssociatedObject(self, &topNameKey);
    NSNumber *rightEdge = objc_getAssociatedObject(self, &rightNameKey);
    NSNumber *bottomEdge = objc_getAssociatedObject(self, &bottomNameKey);
    NSNumber *leftEdge = objc_getAssociatedObject(self, &leftNameKey);
    if (topEdge && rightEdge && bottomEdge && leftEdge)
    {
        return CGRectMake(self.bounds.origin.x - leftEdge.floatValue,
                          self.bounds.origin.y - topEdge.floatValue,
                          self.bounds.size.width + leftEdge.floatValue + rightEdge.floatValue,
                          self.bounds.size.height + topEdge.floatValue + bottomEdge.floatValue);
    } else {
        return self.bounds;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds)) {
        return [super hitTest:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? self : nil;
}

@end

@implementation NSString (MediaExtension)

- (CGFloat)matchView:(CGFloat)fontSize isHeightFixed:(BOOL)fixed fixedValue:(CGFloat)value{
    CGSize size;
    if (fixed) {
        size = CGSizeMake(MAXFLOAT, value);
    } else {
        size = CGSizeMake(value, MAXFLOAT);
    }
    
    CGSize resultSize;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        //返回计算出的size
        resultSize = [self boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]} context:nil].size;
    }
    if (fixed) {
        return resultSize.width;
    } else {
        return resultSize.height;
    }
}
@end
