//
//  UIButton+TapDownTintImage.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/08/01.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UIButton+TapDownTintImage.h"
#import "UIImage+Tint.h"

@implementation UIButton (TapDownTintImage)


- (void) _tapDown:(UIButton*)button
{
    SS_MLOG(self);
    UIImage* image = [button imageForState:UIControlStateNormal];
    
    if (image == nil) {
        image = [UIImage imageWithSize:self.size color:HEXCOLOR(0xDDDDDD)];
        [button setImage:image forState:UIControlStateHighlighted];
        return;
    }
    
    UIImage* _imageHighlight = [image tintedImageUsingColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
    UIImage* imageHighlight = [UIImage imageWithSize:_imageHighlight.size block:^(CGContextRef context, CGSize size) {
        CGRect bounds = CGRectOfSize(size);
        CGContextDrawImage(context, bounds, _imageHighlight.CGImage);
        
        CGContextSetStrokeColorWithColor(context, HEXCOLOR(0x0088FF).CGColor);
        CGContextSetLineWidth(context, size.width * 0.03f);
        CGContextStrokeRect(context, bounds);        
    }];
    
    [button setImage:imageHighlight forState:UIControlStateHighlighted];    
}

- (void) tapDownTintImage;
{
    [self addTarget:self action:@selector(_tapDown:) forControlEvents:UIControlEventTouchDown];              
}

@end
