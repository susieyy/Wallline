//
//  HPGrowingCustomTextView.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/23.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "HPGrowingCustomTextView.h"
#import "MADismissiveTextView.h"

@interface MADismissiveCustomTextView : MADismissiveTextView

@end

@implementation MADismissiveCustomTextView

- (BOOL)becomeFirstResponder;
{
    SS_MLOG(self);    
    BOOL flg = [super becomeFirstResponder];
    if (flg) {
        HPGrowingCustomTextView * view = self.superview;
        self.inputAccessoryView = view.superview;
    }
    return flg;
}

- (BOOL)resignFirstResponder;
{
    SS_MLOG(self);
    BOOL flg = [super resignFirstResponder];    
    if (flg == NO) {
        self.inputAccessoryView = nil;
    }
    return flg;
}


@end

@implementation HPGrowingCustomTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)commonInitialiser
{
    // Initialization code
    CGRect r = self.frame;
    r.origin.y = 0;
    r.origin.x = 0;
    internalTextView = [[MADismissiveTextView alloc] initWithFrame:r];
    internalTextView.delegate = self;
    internalTextView.scrollEnabled = NO;
    internalTextView.font = [UIFont fontWithName:@"Helvetica" size:13]; 
    internalTextView.contentInset = UIEdgeInsetsZero;		
    internalTextView.showsHorizontalScrollIndicator = NO;
    internalTextView.text = @"-";
    [self addSubview:internalTextView];
    
    minHeight = internalTextView.frame.size.height;
    minNumberOfLines = 1;
    
    animateHeightChange = YES;
    
    internalTextView.text = @"";
    
    [self setMaxNumberOfLines:3];
}

@end
