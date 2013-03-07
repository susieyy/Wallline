//
//  UUClearButton.h
//  ZowNote
//
//  Created by 杉上 洋平 on 12/07/07.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UIBlockButton.h"

@interface UUClearButton : UIBlockButton

@property (strong, nonatomic) UIColor *tint;
@property (strong, nonatomic) UIColor *tintHightlight;

+ (UUClearButton *)buttonWithFrame:(CGRect)frame title:(NSString *)title;
- (void) setTintColorAsRed;
- (void) setTintColorAsBlue;
- (void) setTintColorAsGreen;
- (CALayer*) colorLayer;
@end
