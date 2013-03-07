//
//  UUImageLabelButton.h
//  Forever
//
//  Created by 杉上 洋平 on 12/04/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIBlockButton.h"

@interface UUImageLabelButton : UIBlockButton
@property (strong, nonatomic) UIBlockButton* button;
@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) UIColor* color;

+ (UUImageLabelButton*) buttonWithFrame:(CGRect)frame imageName:(NSString*)imageName color:(UIColor*)color text:(NSString*)text key:(NSString*)key;
+ (UUImageLabelButton*) buttonWithFrame:(CGRect)frame imageName:(NSString*)imageName color:(UIColor*)color text:(NSString*)text;

+ (UIBlockButton*) setButton:(UIButton*)button withImageName:(NSString*)name size:(CGSize)buttonSize color:(UIColor*)color;
+ (UIBlockButton*) createButtonWithImageName:(NSString*)name size:(CGSize)buttonSize color:(UIColor*)color;

// (Spin)
@property (nonatomic) BOOL animating;
@end

@interface UUImageLabelButton (Spin) 

- (BOOL)isAnimating;
- (void)startAnimating;
- (void)stopAnimating;
- (void)spin;

@end