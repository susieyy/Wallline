//
//  UUClearButton.m
//  ZowNote
//
//  Created by 杉上 洋平 on 12/07/07.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UUClearButton.h"

#define kHeight 26.0
#define kPadding 20.0
#define kFontSize 14.0


@interface UUClearButton ()
@property (strong, nonatomic) CALayer *colorLayer;

- (void)setupLayers;
- (id)initWithTitle:(NSString *)title;
@end

@implementation UUClearButton
@synthesize tint = _tint;
@synthesize tintHightlight = _tintHightlight;
@synthesize colorLayer = _colorLayer;

+ (UUClearButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title;
{
    UUClearButton *button = [[super alloc] initWithFrame:frame title:title];	
    return button;  
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
{
    self = [super initWithFrame:frame];
    if(self != nil){        
        self.layer.needsDisplayOnBoundsChange = YES;
        
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];		
        [self setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateNormal];

        [self setTitle:title forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];		
        [self setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateHighlighted];

        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.shadowOffset = CGSizeMake(0, -1);
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:kFontSize];
    }	
    return self;	
}

- (CALayer*) colorLayer
{
    if (_colorLayer == nil) {
        CAGradientLayer *bevelLayer = [CAGradientLayer layer];
        bevelLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));		
        bevelLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0 alpha:0.5].CGColor, [UIColor colorWithWhite:0.2 alpha:1.0].CGColor, nil];
        bevelLayer.cornerRadius = 4.0;
        bevelLayer.needsDisplayOnBoundsChange = YES;
        
        CALayer* layer = [CALayer layer];
        layer.frame = CGRectMake(0, 1, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-1.5);		
        layer.borderColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
        layer.backgroundColor = self.tint.CGColor;
        layer.borderWidth = 1.0;	
        layer.cornerRadius = 4.0;
        layer.needsDisplayOnBoundsChange = YES;		
        self.colorLayer = layer;
        
        CAGradientLayer *colorGradient = [CAGradientLayer layer];
        colorGradient.frame = CGRectMake(0, 1, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-1);		
        colorGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1 alpha:0.1].CGColor, [UIColor colorWithWhite:0.2 alpha:0.1].CGColor , nil];		
        colorGradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];		
        colorGradient.cornerRadius = 4.0;
        colorGradient.needsDisplayOnBoundsChange = YES;	
        
        [self.layer addSublayer:bevelLayer];
        [self.layer addSublayer:layer];
        [self.layer addSublayer:colorGradient];
        [self bringSubviewToFront:self.titleLabel];    
        [self setNeedsDisplay];        
    }
    return _colorLayer;
}

- (void) setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2f];    
    if (highlighted) {
        self.colorLayer.backgroundColor = self.tintHightlight.CGColor;
    } else {
        self.colorLayer.backgroundColor = self.tint.CGColor;
    }
    [CATransaction commit];        
}

- (void) setTintColorAsRed
{
    [self setTint:[UIColor colorWithRed:0.694 green:0.184 blue:0.196 alpha:1]];
    [self setTintHightlight:[UIColor colorWithRed:0.594 green:0.084 blue:0.096 alpha:1]];       
}

- (void) setTintColorAsBlue
{
    [self setTint:[UIColor colorWithRed:0.220 green:0.357 blue:0.608 alpha:1]];   
    [self setTintHightlight:[UIColor colorWithRed:0.120 green:0.257 blue:0.508 alpha:1]];   
}

- (void) setTintColorAsGreen
{
    [self setTint:[UIColor colorWithRed:0.439 green:0.741 blue:0.314 alpha:1.]];   
    [self setTintHightlight:[UIColor colorWithRed:0.339 green:0.641 blue:0.214 alpha:1.]];   
}

@end
