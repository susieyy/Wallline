//
//  VCTimeLineViewController+Sliding.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/20.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCTimeLineViewController+Sliding.h"
#import "ECSlidingViewController.h"

#import "VCListViewController.h"
#import "VCNotificationViewController.h"

@implementation VCTimeLineViewController (Sliding)


- (void) _removeSideViewController
{
    SS_MLOG(self);
    if ([self.slidingViewController underLeftShowing] == NO) {
        self.slidingViewController.underLeftViewController = nil;
    }
    if ([self.slidingViewController underRightShowing] == NO) {
        UIViewController* controller = self.slidingViewController.underRightViewController;
        if ([controller isKindOfClass:[VCNotificationViewController class]]) {
            self.slidingViewController.underRightViewController = nil;
        }
        self.slidingViewController.underRightViewController = self.webNaviViewController;
    }
}

- (void) _didResetECSlidingViewTop:(NSNotification*)notification
{
    id obj = [notification object];
    if (obj != self.slidingViewController) return;
    
    [self _removeSideViewController];
}

- (void) didReceiveMemoryWarningForSliding;
{
    [self _removeSideViewController];
}

- (void) viewDidLoadForSliding
{
    self.navigationController.view.layer.shadowOpacity = 0.75f;
    self.navigationController.view.layer.shadowRadius = 10.0f;
    self.navigationController.view.layer.shadowColor = [UIColor blackColor].CGColor;   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didResetECSlidingViewTop:) name:ECSlidingViewTopDidReset object:nil];    
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    {
        // NSURL* URL = [NSURL URLWithString:@"http://google.com"];
        // SVWebViewController *controller = [[SVWebViewController alloc] initWithURL:URL];
        // self.webViewController = controller;
        
        UIStoryboard *storyboard = self.storyboard;
        if (storyboard == nil) storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        
        UINavigationController* navi = [storyboard instantiateViewControllerWithIdentifier:@"WEB_IDENTIFIER"];
        self.slidingViewController.underRightViewController = navi;
        self.webNaviViewController = navi;
        self.webViewController = navi.viewControllers[0];
    }
}

- (void) viewWillAppearForSliding
{
    // [self.viewForHeader addGestureRecognizer:self.slidingViewController.panGesture];
}

#pragma -
#pragma VCListViewController

- (VCListViewController*) listViewController
{
    if (self.slidingViewController.underLeftViewController == nil) {
        UIStoryboard *storyboard = self.storyboard;
        if (storyboard == nil) storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        
        VCListViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"LIST_IDENTIFIER"];
        self.slidingViewController.underLeftViewController = controller;
    }    
    return (VCListViewController*) self.slidingViewController.underLeftViewController;
}


- (IBAction) revealListViewController:(id)sender
{
    SS_MLOG(self);    
    [self listViewController];
    [self.slidingViewController anchorTopViewTo:ECRight animations:nil onComplete:nil];
}

#pragma -
#pragma VCNotificationViewController

- (VCNotificationViewController*) notificationViewController
{
    SS_MLOG(self);
    if (self.slidingViewController.underRightViewController == nil ||
        NO == [self.slidingViewController.underRightViewController isKindOfClass:[VCNotificationViewController class]]) {
        UIStoryboard *storyboard = self.storyboard;
        if (storyboard == nil) storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];

        VCNotificationViewController* controller = [storyboard instantiateViewControllerWithIdentifier:@"NOTIFICATION_IDENTIFIER"];
        self.slidingViewController.underRightViewController = controller;
    }    
    return (VCNotificationViewController*) self.slidingViewController.underRightViewController;
}


- (IBAction) revealNotificationViewController:(id)sender
{
    SS_MLOG(self);
    [self notificationViewController];
    [self.slidingViewController anchorTopViewTo:ECLeft animations:nil onComplete:nil];
}

- (IBAction) revealWebViewController:(NSURL*)URL
{
    SS_MLOG(self);
    [self.webViewController loadURL:URL];
    [self.slidingViewController anchorTopViewTo:ECLeft animations:nil onComplete:nil];
}
@end
