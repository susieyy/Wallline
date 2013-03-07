//
//  UIImage+SSNoAlpha.h
//  Pickupps
//
//  Created by 杉上 洋平 on 12/06/04.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^SSBlockImageContext)(CGContextRef context, CGFloat scale, CGSize size);
@interface UIImage (SSNoAlpha)

+ (UIImage *) imageAsNoAlpha:(SSBlockImageContext)block scale:(CGFloat)scale size:(CGSize)size;
+ (UIImage *) imageAsNoAlpha:(SSBlockImageContext)block size:(CGSize)size;

- (UIImage*) imageAsNoAlpha:(UIColor*)color;
- (UIImage*) imageAsNoAlphaAsRounded:(UIColor*)color;
@end