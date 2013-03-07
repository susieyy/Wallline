//
//  UIImage+SSNoAlpha.m
//  Pickupps
//
//  Created by 杉上 洋平 on 12/06/04.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UIImage+SSNoAlpha.h"
#import "SSCoreGraphics.h"


@implementation UIImage (SSNoAlpha)

+ (UIImage *) imageAsNoAlpha:(SSBlockImageContext)block scale:(CGFloat)scale size:(CGSize)size
{
    size_t with = (size_t)(size.width * scale);
    size_t height = (size_t)(size.height * scale);
    
    // SSLog(@"---- SizeForScreen[%@] Scale %f , Size %d, %d" , NSStringFromCGSize(size),  scale, with, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 with, //CGImageGetWidth(imageRef),
                                                 height, //CGImageGetHeight(imageRef),
                                                 8,
                                                 // Just always return width * 4 will be enough
                                                 with * 4, // CGImageGetWidth(imageRef) * 4,
                                                 // System only supports RGB, set explicitly
                                                 colorSpace,
                                                 // Makes system don't need to do extra conversion when displayed.
                                                 kCGImageAlphaNoneSkipLast); 
    CGColorSpaceRelease(colorSpace);
    if (!context) return nil;
    
    if (block) {
        block(context, scale, size);
    }
    
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *decompressedImage = [[UIImage alloc] initWithCGImage:decompressedImageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

+ (UIImage *) imageAsNoAlpha:(SSBlockImageContext)block size:(CGSize)size
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    return [self imageAsNoAlpha:block scale:scale size:size];
}

- (UIImage*) imageAsNoAlpha:(UIColor*)color
{
    UIImage *image = [UIImage imageAsNoAlpha:^(CGContextRef context, CGFloat scale, CGSize size){
        CGRect bounds = CGRectMake(0, 0, size.width*scale, size.height*scale);            
        // Fill
        {
            CGContextSetFillColorWithColor(context, color.CGColor);
            CGContextFillRect(context, bounds);
        }        
        CGContextDrawImage(context, bounds, self.CGImage);   
    } size:self.size];
    return image;
}

- (UIImage*) imageAsNoAlphaAsRounded:(UIColor*)color
{
    UIImage *image = [UIImage imageAsNoAlpha:^(CGContextRef context, CGFloat scale, CGSize size){
        CGRect bounds = CGRectMake(0, 0, size.width*scale, size.height*scale);            
        // Fill
        {
            CGContextSetFillColorWithColor(context, color.CGColor);
            CGContextFillRect(context, bounds);
        }
        
        SSContextAddRoundedRectToPath(context, bounds, bounds.size.width/8.0f, SSRoundedCornerPositionAll);
        CGContextClip(context);                    
        CGContextDrawImage(context, bounds, self.CGImage);   
    } size:self.size];
    return image;
}

@end
