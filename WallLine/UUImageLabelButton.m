//
//  UUImageLabelButton.m
//  Forever
//
//  Created by 杉上 洋平 on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UUImageLabelButton.h"

@implementation UUImageLabelButton
@synthesize button = _button;
@synthesize label = _label;
@synthesize color = _color;
@synthesize animating = _animating;

+ (UUImageLabelButton*) buttonWithFrame:(CGRect)frame imageName:(NSString*)imageName color:(UIColor*)color text:(NSString*)text key:(NSString*)key
{
    UUImageLabelButton* buuton = [self createButtonWithImageName:imageName size:frame.size color:color key:key];
    buuton.origin = frame.origin;
    if (text) {
        UIFont* font = [UIFont systemFontOfSize:9];            
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.frame = CGRectMake(-10, buuton.bottom-2, buuton.width + 20, 10);
        label.textAlignment = UITextAlignmentCenter;
        label.text = text;
        label.font = font;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = color;
        buuton.label = label;
        
        [buuton addSubview:label];
    }
    buuton.color = color;
    return buuton;   
}

+ (UUImageLabelButton*) buttonWithFrame:(CGRect)frame imageName:(NSString*)imageName color:(UIColor*)color text:(NSString*)text
{
    return [self buttonWithFrame:frame imageName:imageName color:color text:text key:nil];
}

- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled == NO) {
        self.label.textColor = HEXCOLOR(0x616161);
    } else {
        if (self.selected) {
            self.label.textColor = COLOR_FOR_SELECT;
        } else {
            self.label.textColor = self.color;        
        }
    }
}

- (void) setHighlighted:(BOOL)highlighted   
{
    [super setHighlighted:highlighted];
    if (highlighted || self.selected) {
        self.label.textColor = COLOR_FOR_SELECT;
    } else {
        self.label.textColor = self.color;        
    }
}

- (void) setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.label.textColor = COLOR_FOR_SELECT;
    } else {
        self.label.textColor = self.color;        
    }
}

+ (UIBlockButton*) setButton:(UIButton*)button withImageName:(NSString*)name size:(CGSize)buttonSize color:(UIColor*)color key:(NSString*)key
{
    UIImage* __imageResized = nil;    
    {
        NSString* cacheNameForNomal = nil;
        if (key) {
            cacheNameForNomal = [NSString stringWithFormat:@"%@_%@_label_nomarl", name, key];
        } else {
            cacheNameForNomal = [NSString stringWithFormat:@"%@_label_nomarl", name];
        }
        
        UIImage* image = [UIImage loadCacheDisk:cacheNameForNomal];
        if (image == nil) {
            __imageResized = [[[UIImage imageNamed:name] imageAsResizeTo:buttonSize] imageAsInnerResizeTo:CGSizeMake(buttonSize.width*0.60, buttonSize.width*0.60)];            
            UIImage* __image = [__imageResized imageAsMaskedColor:color];
            image = [UIImage imageWithSize:buttonSize block:^(CGContextRef context, CGSize size){
                CGRect rect = CGRectOfSize(size);      
                CGContextSetShadowWithColor(context, CGSizeMake(-1.0f, 1.0f), 0.0f, HEXCOLORA(0x00000044).CGColor);
                CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 0.5f, HEXCOLORA(0xFFFFFF99).CGColor);                
                CGContextDrawImage(context, rect, __image.CGImage);
            }];  
            [image saveCacheDisk:cacheNameForNomal];
        }
        [button setBackgroundImage:image forState:UIControlStateNormal];
        // setBackgroundImage
    }    
    
    {
        NSString* cacheNameForNomal = nil;
        if (key) {
            cacheNameForNomal = [NSString stringWithFormat:@"%@_%@_label_selected", name, key];
        } else {
            cacheNameForNomal = [NSString stringWithFormat:@"%@_label_selected", name];
        }

        UIImage* image = [UIImage loadCacheDisk:cacheNameForNomal];
        if (image == nil) {
            UIImage* __image = [__imageResized imageAsMaskedColor:COLOR_FOR_SELECT];                    
            image = [UIImage imageWithSize:buttonSize block:^(CGContextRef context, CGSize size){
                CGRect rect = CGRectOfSize(size);                
                CGContextSetShadowWithColor(context, CGSizeMake(-1.0f, 1.0f), 0.0f, HEXCOLORA(0x00000044).CGColor);
                CGContextSetShadowWithColor(context, CGSizeMake(1.0f, 1.0f), 0.0f, HEXCOLORA(0xFFFFFF99).CGColor);                
                CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 0.0f), 5.0f, COLOR_FOR_SELECT.CGColor);                                        
                CGContextDrawImage(context, rect, __image.CGImage);
            }];            
            [image saveCacheDisk:cacheNameForNomal];
        }
        [button setBackgroundImage:image forState:UIControlStateHighlighted];
        [button setBackgroundImage:image forState:UIControlStateSelected];                    
    } 
    
    return button;
}

+ (UIBlockButton*) createButtonWithImageName:(NSString*)name size:(CGSize)buttonSize color:(UIColor*)color key:(NSString*)key
{
    CGRect rect = CGRectOfSize(buttonSize);
    UIBlockButton* button = [UUImageLabelButton buttonWithType:UIButtonTypeCustom];
    [button setShowsTouchWhenHighlighted:YES];
    [button setFrame:rect];          
    
    [self setButton:button withImageName:name size:buttonSize color:color key:key];
    return button;
}
@end



@implementation UUImageLabelButton (Spin)

#pragma mark - Public Methods

- (UIView*) viewForAnimation
{
    for (UIView* view in [self.subviews copy]) {
        if ([view isKindOfClass:[UIImageView class]]) {
//            view.userInteractionEnabled = YES;
            
            UIView* viewForImageContent = [[UIView alloc] initWithFrame:self.bounds];
            viewForImageContent.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            viewForImageContent.backgroundColor = [UIColor clearColor];
            viewForImageContent.tag = 99999;
            viewForImageContent.userInteractionEnabled = NO;
            [self insertSubview:viewForImageContent atIndex:0];
            [view removeFromSuperview];
            [viewForImageContent addSubview:view];
            return viewForImageContent;

        } else if (view.tag == 99999) {
            return view;
        }
    }   
    return nil;
}

- (BOOL) isAnimating
{
    UIView* view = [self viewForAnimation];
    CAAnimation *spinAnimation = [view.layer animationForKey:@"spinAnimation"];
    return (self.animating || spinAnimation);
}

- (void) startAnimating
{
    self.animating = YES;
    [self spin];
}

- (void) stopAnimating
{
    self.animating = NO;
}

- (void) spin
{
    UIView* view = [self viewForAnimation];    
    CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    spinAnimation.byValue = [NSNumber numberWithFloat:2*M_PI];
    spinAnimation.duration = 1.0f;
    spinAnimation.delegate = self;
    [view.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
}

#pragma mark - Animation Delegates

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (self.animating) {
        [self spin];
    }
}

@end