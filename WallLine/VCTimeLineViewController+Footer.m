//
//  VCTimeLineViewController+Footer.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/31.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCTimeLineViewController+Footer.h"
#import "UUImageLabelButton.h"
#import "PrettyToolbar.h"


@implementation VCTimeLineViewController (Footer)

- (void) viewDidLoadForFooter
{
    __weak VCTimeLineViewController* _self = self;
    UIView* viewForTarget = nil;
    {
        CGRect frame = CGRectMake(0, 0, self.view.width, 44.0f);
        PrettyToolbar* view = [[PrettyToolbar alloc] initWithFrame:frame];
        //view.backgroundColor = HEXCOLOR(0x132557);
        [self.view addSubview:view];
        self.viewForFooter = view;
        viewForTarget = view;
        
        view.topLineColor = [UIColor colorWithHex:0x6975C8];
        view.gradientStartColor = [UIColor colorWithHex:0x395598];
        view.gradientEndColor = [UIColor colorWithHex:0x193578];    
        view.bottomLineColor = [UIColor colorWithHex:0x092568];   
    }
    
    {
        UIView *view = [[UIView alloc] initWithFrame:viewForTarget.bounds];
        view.backgroundColor = HEXCOLORA(0x00000033);//  [UIColor clearColor];
        [viewForTarget addSubview:view];
    }

    
    ///////////////////////////////////////////////////////////////////////////////
    // 
    {
        CGRect frame = CGRectMake(0, BUTTON_DEFAULT_TOP, BUTTON_DEFAULT_SIZE, BUTTON_DEFAULT_SIZE);        
        UUImageLabelButton* button = [UUImageLabelButton buttonWithFrame:frame imageName:@"write" color:HEXCOLOR(0xFFFFFF) text:NSLocalizedString(@"Write", @"")];    
        button.left = OFFSET_MARGIN;
        [viewForTarget addSubview:button];
        button.blockAction = ^(UIButton* _button) {  
            [_self doShowWriteAction:nil];
            
        };
    }
    {
        CGRect frame = CGRectMake(0, BUTTON_DEFAULT_TOP, BUTTON_DEFAULT_SIZE, BUTTON_DEFAULT_SIZE);        
        UUImageLabelButton* button = [UUImageLabelButton buttonWithFrame:frame imageName:@"facebook" color:HEXCOLOR(0xFFFFFF) text:NSLocalizedString(@"Facebook", @"")];     
        button.centerX = viewForTarget.width/2;
        [viewForTarget addSubview:button];
        button.blockAction = ^(UIButton* _button) {  
            [_self doShowFacebookAction:nil];
        };
    }
    {
        CGRect frame = CGRectMake(0, BUTTON_DEFAULT_TOP, BUTTON_DEFAULT_SIZE, BUTTON_DEFAULT_SIZE);        
        UUImageLabelButton* button = [UUImageLabelButton buttonWithFrame:frame imageName:@"camera" color:HEXCOLOR(0xFFFFFF) text:NSLocalizedString(@"Photo", @"")];     
        button.right = viewForTarget.width - OFFSET_MARGIN;
        [viewForTarget addSubview:button];
        button.blockAction = ^(UIButton* _button) {  
            
        };
    }

}

@end
