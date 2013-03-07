//
//  VCTimeLineViewController+Header.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/06/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCTimeLineViewController+Header.h"

@implementation VCTimeLineViewController (Header)

- (void) viewDidLoadForHeader
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didNotificationOrFriendRequest:) name:NFDidNotificationOrFriendRequest object:nil];

    ///////////////////////////////////////////////////////////////////////////////
    // PrettyNavigationBar
    {
        PrettyNavigationBar *navBar = (PrettyNavigationBar *)self.navigationController.navigationBar;
        navBar.topLineColor = [UIColor colorWithHex:0x6975C8];
        navBar.gradientStartColor = [UIColor colorWithHex:0x395598];
        navBar.gradientEndColor = [UIColor colorWithHex:0x193578];    
        navBar.bottomLineColor = [UIColor colorWithHex:0x092568];   
        navBar.tintColor = navBar.gradientEndColor;
        navBar.roundedCornerRadius = 8;
    }
    
    if (self.navigationItem.titleView == nil) {
        UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0f)];
        navLabel.backgroundColor = HEXCOLORA(0x00000033);//  [UIColor clearColor];
        navLabel.textColor = [UIColor whiteColor];
        navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        navLabel.font = [UIFont boldSystemFontOfSize:15];
        navLabel.textAlignment = UITextAlignmentCenter;        
        navLabel.userInteractionEnabled = YES;
        self.navigationItem.titleView = navLabel;
        
        UIImage* image = [UIImage imageWithSize:navLabel.bounds.size color:HEXCOLORA(0x99000033)];
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        //button.backgroundColor = HEXCOLORA(0x99000033);
        [button setImage:image forState:UIControlStateHighlighted];
        [button setImage:image forState:UIControlStateSelected];
        button.backgroundColor = [UIColor clearColor];
        button.frame = navLabel.bounds;
        [button addTarget:self action:@selector(requestNowAction:) forControlEvents:UIControlEventTouchDownRepeat];
        [navLabel addSubview:button];
    }

    ///////////////////////////////////////////////////////////////////////////////
    // Notification Button
    {
        [self _updateNotificationButtonAsNotice:NO];
    }
}

#pragma -
#pragma Notification

- (void) _updateNotificationButtonAsNotice:(BOOL)isNotice
{
    UIBarButtonItem *item = nil;
    {
        CGFloat buttonsize = 20.0f;
        UIColor* color = nil;
        if (isNotice) {
            color = HEXCOLOR(0xFF3333);
        } else {
            color = HEXCOLOR(0xFFFFFF);
        }
        UIImage* image = [[[UIImage imageNamed:@"notification.png"] imageAsMaskedColor:color] imageAsInnerResizeTo:CGSizeMake(60*0.80, 60*0.80)];
        UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonsize, buttonsize)];
        [customView setBackgroundImage:image forState:UIControlStateNormal];
        [customView addTarget:self action:@selector(revealNotificationViewController:) forControlEvents:UIControlEventTouchUpInside];
        item = [[UIBarButtonItem alloc] initWithCustomView:customView];
    }
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    navigationBar.topItem.rightBarButtonItem = item;
}

- (void) _didNotificationOrFriendRequest:(NSNotification*)notification
{
    SS_MLOG(self);

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger countForUnreadNotification = [userDefaults integerForKey:@"countForUnreadNotification"];
    NSUInteger countForUnreadFriendRequest = [userDefaults integerForKey:@"countForUnreadFriendRequest"];
    
    if (countForUnreadNotification > 0 || countForUnreadFriendRequest > 0) {
        [self _updateNotificationButtonAsNotice:YES];
    } else {
        [self _updateNotificationButtonAsNotice:NO];
    }    
}

#pragma -
#pragma Update

- (void) updateHeaderTitle
{
    UILabel* label = (UILabel*) self.navigationItem.titleView;
    label.text = [self.stackModel title];
}

-(void) updateHeaderButtons
{
    CGFloat buttonsize = 20.0f;
    
    UIBarButtonItem *item = nil;
    if (self.stackUUIDs.count == 1) {
        
        /***
         UIImage* image = [[[UIImage imageNamed:@"list.png"] imageAsMaskedColor:HEXCOLOR(0xFFFFFF)] imageAsInnerResizeTo:CGSizeMake(60*0.60, 60*0.60)];
         UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonsize, buttonsize)];
         [customView setBackgroundImage:image forState:UIControlStateNormal];
         [customView addTarget:self action:@selector(revealListViewController:) forControlEvents:UIControlEventTouchUpInside];
         item1 = [[UIBarButtonItem alloc] initWithCustomView:customView];
         ***/
        
        UIImage* image = [[[UIImage imageNamed:@"setting.png"] imageAsMaskedColor:HEXCOLOR(0xFFFFFF)] imageAsInnerResizeTo:CGSizeMake(60*0.80, 60*0.80)];
        UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonsize, buttonsize)];
        [customView setBackgroundImage:image forState:UIControlStateNormal];
        [customView addTarget:self action:@selector(doShowSettingViewController:) forControlEvents:UIControlEventTouchUpInside];
        item = [[UIBarButtonItem alloc] initWithCustomView:customView];
        
    } else {
        UIImage* image = [[[UIImage imageNamed:@"cancel.png"] imageAsMaskedColor:HEXCOLOR(0xFFFFFF)] imageAsInnerResizeTo:CGSizeMake(60*0.80, 60*0.80)];
        UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonsize, buttonsize)];
        [customView setBackgroundImage:image forState:UIControlStateNormal];
        [customView addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        item = [[UIBarButtonItem alloc] initWithCustomView:customView];
        
    }    
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    navigationBar.topItem.leftBarButtonItem = item;
}



@end
