//
//  VCListViewController+Footer.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/20.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCListViewController+Footer.h"
#import "UUImageLabelButton.h"
#import "ECSlidingViewController.h"

@implementation VCListViewController (Footer)


- (void) viewDidLoadForFooter
{
    
    __weak VCListViewController* _self = self;    
    UIView* viewForTarget = nil;
    
    ///////////////////////////////////////////////////////////////////////////////
    // Header
    {
        CGRect frame = CGRectMake(0, self.view.height-44.0f, self.view.width, 44);
        UIImageView* view = [[UIImageView alloc] initWithFrame:frame];
        view.userInteractionEnabled = YES;
        // view.image = image;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;        
        view.backgroundColor = HEXCOLOR(0x1D232C);
        [self.view addSubview:view];
        viewForTarget = view;
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Higlight
    {
        CGFloat height = 2.0f;
        CGRect frame = CGRectMake(0, 0, viewForTarget.width, height);
        //        CGRect frame = CGRectMake(0, self.viewForHeader.bottom-height, self.view.width, height);        
        UIBlockView* view = [[UIBlockView alloc] initWithFrame:frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
            CGRect bounds = _view.bounds;
            CGContextSetFillColorWithColor(context, COLOR_FOR_HIGHLIGHT.CGColor);
            CGContextFillRect(context, bounds);
        };
        [view setNeedsDisplay];
        [viewForTarget addSubview:view];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // SETTING
    {
        CGRect frame = CGRectMake(0, BUTTON_DEFAULT_TOP, BUTTON_DEFAULT_SIZE, BUTTON_DEFAULT_SIZE);        
        UUImageLabelButton* button = [UUImageLabelButton buttonWithFrame:frame imageName:@"setting" color:COLOR_FOR_BUTTON text:NSLocalizedString(@"Setting", @"")];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;        
        button.keyview = @"SETTING";
        button.left = OFFSET_MARGIN;
        [viewForTarget addSubview:button];
        button.blockAction = ^(UIButton* _button) {  
            [_self.slidingViewController resetTopViewWithAnimations:nil onComplete:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoShowSettingViewController object:nil userInfo:nil];                                
                });                
            }];
        };
    }
    
}


@end
