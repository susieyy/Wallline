//
//  UUTimeLineCell+Action.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/31.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UUTimeLineCell+Action.h"
#import "UUTimeLineCell+Define.h"

@implementation UUTimeLineCell (Action)

- (void) doAction:(UIButton*)button
{
    SS_MLOG(self);
    NSString* url = [NSString stringWithFormat:@"debug://%@", [self.statusModel objectForKey:@"id"]];
    NSURL* URL = [NSURL URLWithString:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];    
}

- (void) doPrivacyAction:(UIButton*)button
{
    SS_MLOG(self);
    NSString* value = self.statusModel[@"privacy"][@"value"];
    NSString* description = self.statusModel[@"privacy"][@"description"];    
    NSString* title = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Privacy", @""), description];
    [UIAlertView showWithTitle:title];
}


#pragma -
#pragma RTLabelDelegate

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)URL;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];
}

- (void) tapUserProfile:(id)sender
{
    NSString* key = @"friend";
    if (self.statusModel[@"from"][@"category"]) {
        key = @"page";
    }
    NSString* url = [NSString stringWithFormat:@"%@://%@", key, self.statusModel[@"from"][@"id"]];
    NSURL* URL = [NSURL URLWithString:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];    
}

- (void) tapPicture:(id)sender
{
    NSString* link = [self.statusModel objectForKey:@"link"];
    if (link == nil) return;
    //    NSString* url = [NSString stringWithFormat:@"picture://%@", [[self.statusModel objectForKey:@"from"] objectForKey:@"id"]];
    NSURL* URL = [NSURL URLWithString:link];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];
}

- (void) tapPhoto:(id)sender
{
    NSString* url = [NSString stringWithFormat:@"photo://%@", [self.statusModel objectForKey:@"object_id"]];
    NSURL* URL = [NSURL URLWithString:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];
}

- (void) tapLike:(id)sender
{
    NSString* objectID = [self.statusModel objectForKey:@"id"];
    BOOL isLiked = [self.statusModel isLiked];
    if (isLiked) {
        [[MMRequestManager sharedManager] doUnLikeObjectID:objectID];
    } else {
        [[MMRequestManager sharedManager] doLikeObjectID:objectID];        
    }
    [self.statusModel setLiked:!isLiked];
    [self _updateLikeButton];
}

- (void) tapComment:(id)sender
{
    NSString* url = [NSString stringWithFormat:@"stream://%@", [self.statusModel objectForKey:@"id"]];
    NSURL* URL = [NSURL URLWithString:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];
}

@end
