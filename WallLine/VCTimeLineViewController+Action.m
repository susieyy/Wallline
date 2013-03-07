//
//  VCTimeLineViewController+Action.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/20.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCTimeLineViewController+Action.h"


#import "VCUserLineViewController.h"
#import "VCCommentViewController.h"
#import "SVWebViewController.h"
#import "MWRTPhotoBrowserViewController.h"

#import "MWPhotoBrowser.h"
#import "UUTimeLineCell.h"

#import "WBSuccessNoticeView.h"

@interface VCTimeLineViewController ()
@end

@implementation VCTimeLineViewController (Action)

- (void) calcCellHeightByFontSizeChange
{
    NSString* key = @"FontSizeForTimeLine";
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger fontSize = [userDefaults integerForKey:key];
    
    if (self.stackModel.fontSize != fontSize) {
        for (MMStatusModel* statusModel in self.stackModel.datas) {
            statusModel.height = [UUTimeLineCell heightFromData:statusModel];
        }
        self.stackModel.fontSize = fontSize;
    }
}

- (void) pinchAction:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        NSString* key = @"FontSizeForTimeLine";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSUInteger fontSize = [userDefaults integerForKey:key];
        CGFloat scale = [sender scale];
        SSLog(@"    Pinch Scale [%f]", scale);
        BOOL isChanged = NO;
        if (scale > 1.5f) {
            fontSize = fontSize + 1;
            if (fontSize > 16) fontSize = 16;
            isChanged = YES;
            [userDefaults setInteger:fontSize forKey:key];
            [userDefaults synchronize];
            
        } else if (scale < 0.5f) {
            fontSize = fontSize - 1;
            if (fontSize < 10) fontSize = 10;
            isChanged = YES;            
            [userDefaults setInteger:fontSize forKey:key];
            [userDefaults synchronize];
        }
        
        if (isChanged) {
            NSString* title = [NSString stringWithFormat:@"%@ %dpt", NSLocalizedString(@"Change font size", @""), fontSize];
            WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInView:self.view title:title];
            [notice show];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self calcCellHeightByFontSizeChange];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadDataNeedCellUpdate:YES];
                });
            });
        }
    }
}

- (IBAction) doShowFacebookAction:(id)sender;
{
    SS_MLOG(self);
    UIActionSheet* view = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"This page open by", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:NSLocalizedString(@"Facebook App",@"") otherButtonTitles:nil, nil];
    [view showFromView:self.view buttonBlock:^(UIActionSheet* sender, NSInteger buttonIndex) {
        if (sender.cancelButtonIndex == buttonIndex) {
            return;
        }
        if (buttonIndex == 0) {
            NSURL* URL = [self.stackModel URLForFacebookApp];
            if (URL == nil) {
                SSLog(@"URL ObjectType Unknow");
                return;
            }
            [[UIApplication sharedApplication] openURL:URL];
            return;
        }
        if (buttonIndex == 1) {
            NSString* url = [NSString stringWithFormat:@"https://www.facebook.com/%@?accesstoken=%@", self.stackModel.ID, FBSession.activeSession.accessToken];
            SSLog(@"URL %@", url);
            NSURL* URL = [NSURL URLWithString:url];
            SVWebViewController *controller = [[SVWebViewController alloc] initWithURL:URL];
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
    }];
}
    
#pragma -
#pragma Request

- (IBAction) requestNowAction:(id)sender
{
    SS_MLOG(self);
    __weak VCTimeLineViewController* _self = self;
    
    if (self.stackModel.timeLineType != VCTimeLineTypeStream) {
        if (self.tableView.contentOffset.y > 10.0f) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }
    }
    
    if (self.refreshControl.refreshing == NO) {
        [self.refreshControl beginRefreshing];
    }
    
    [self requestTimeLineCompletionBlock:^(NSError *error) {
        [_self.refreshControl endRefreshing];
        
        if (error == nil) {
            [_self updateHeaderTitle];

            [_self reloadDataNeedCellUpdate:YES];
            [_self updateOffsets];
            
            if (_self.stackModel.timeLineType != VCTimeLineTypeStream) {
                [_self.tableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
            }
            
            [_self removeViewForLoading];
        }
    }];
}

- (IBAction) requestNextAction:(UIButton*)button
{   
    SS_MLOG(self);
    __weak VCTimeLineViewController* _self = self;
    
    button.enabled = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //_self.pageIndex++;                    
        [button setTitle:NSLocalizedString(@"Loading", @"") forState:UIControlStateNormal];                    
        [_self requestTimeLineNextCompletionBlock:^(NSError *error) {
            button.enabled = YES;
            [button setTitle:NSLocalizedString(@"More", @"") forState:UIControlStateNormal];
            if (error == nil) {
                [_self reloadDataNeedCellUpdate:YES];
            }
        }];                        
    });
}

#pragma -
#pragma NSNotification

- (void) doShowSettingViewController:(NSNotification*)notification
{
    SS_MLOG(self);
    [self performSegueWithIdentifier:@"SEGUE_SETTING" sender:nil];
}

- (IBAction) doShowCommentAction:(id)sender
{
    SS_MLOG(self);
    NSString* objectID = self.stackModel.ID;
    [self performSegueWithIdentifier:@"SEGUE_COMMENT" sender:objectID];    
}

- (void) doShowCommentViewController:(NSNotification*)notification
{
    SS_MLOG(self);
    NSString* objectID = [notification object];
    [self performSegueWithIdentifier:@"SEGUE_COMMENT" sender:objectID];
}

- (IBAction) doShowWriteAction:(id)sender
{
    SS_MLOG(self);
    [self performSegueWithIdentifier:@"SEGUE_WRITE" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SS_MLOG(self);
    NSString* identifier = segue.identifier;
    if ([@"SEGUE_COMMENT" isEqualToString:identifier]) {
        UINavigationController* navi = (UINavigationController*) segue.destinationViewController;
        VCCommentViewController* controller = navi.viewControllers[0];
        controller.objectID = (NSString*)sender;
    }
    if ([@"SEGUE_PHOTO" isEqualToString:identifier]) {
        NSDictionary* userInfo = sender;
        NSString* objectID = userInfo[@"objectID"];
        NSString* type = userInfo[@"type"];
        UINavigationController* navi = (UINavigationController*) segue.destinationViewController;
        MWRTPhotoBrowserViewController* controller = navi.viewControllers[0];
        
        controller.view; // Need
        if ([type isEqualToString:@"photo"]) {
            [controller requestPhoto:objectID];
            
        } else if ([type isEqualToString:@"album"]) {
            [controller requestPhoto:objectID];            
            
        }
    }
}


@end
