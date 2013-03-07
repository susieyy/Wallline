//
//  VCTimeLineViewController+DoURL.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/13.
//
//

#import "VCTimeLineViewController+DoURL.h"

#import "SVWebViewController.h"

@implementation VCTimeLineViewController (DoURL)

- (void) _doTimeLineURL:(NSURL*)URL type:(NSString*)type
{
    SS_MLOG(self);
    __weak VCTimeLineViewController* _self = self;
    
    ///////////////////////////////////////////////////////////////////////////////
    //
    NSString* url = [URL absoluteString];
    NSString* ID = [url stringMatchedByRegex:@"://([^/]+)"];
    NSString* SUBID = nil;
    NSString* objectType = [url stringMatchedByRegex:@"^([^:]+)://"];
    
    SSLog(@"    DoTimeLineURL [%@]", url);

    ///////////////////////////////////////////////////////////////////////////////
    // Debug
    if ([objectType isEqualToString:@"debug"]) {
        MMStatusModel* statusModel = [self __statusModelFromID:ID];
        self.debugJSONViewController.statusModel = statusModel;
        SSLog([statusModel description]);
        [self presentSemiViewController:self.debugJSONViewController];
        return;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // PARSE Facebook URL
    NSDictionary* info = [MMFacebookManager parseURL:URL];
    if (info) {
        objectType = info[@"objectType"];
        ID = info[@"ID"];
        SUBID = info[@"SUBID"];        
    }

    ///////////////////////////////////////////////////////////////////////////////
    // http
    if (info == nil && [url hasPrefix:@"http"]) {
        // TODO:
        /*
        // Add access token
        if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/"]) {
            NSString* r = @"?";
            if ([url matchesPatternRegexPattern:@"\\?"]) r = @"&";
            url = [NSString stringWithFormat:@"%@%@access_token=%@", url, r, FBSession.activeSession.accessToken];
            URL = [NSURL URLWithString:url];
        }
        */ 
        SSLog(@"    Open Web [%@]", url);
        [self revealWebViewController:URL];
        // SVWebViewController *controller = [[SVWebViewController alloc] initWithURL:URL];
        // [self.navigationController pushViewController:controller animated:YES];
        return;
        
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    //
    if ([objectType isEqualToString:@"photo"]) {
        NSDictionary* userInfo = @{@"objectID":ID, @"type":@"photo" };
        [self performSegueWithIdentifier:@"SEGUE_PHOTO" sender:userInfo];
        return;
        
    } else if ([objectType isEqualToString:@"album"]) {
        NSDictionary* userInfo = @{@"objectID":ID, @"type":@"album" };
        [self performSegueWithIdentifier:@"SEGUE_PHOTO" sender:userInfo];
        return;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Stack For Feed
    [self openWithObjectType:objectType ID:ID SUBID:SUBID];
}

- (void) doTimeLineURL:(NSNotification*)notification
{
    SS_MLOG(self);
    NSURL* URL = [notification object];
    NSDictionary* userInfo = [notification userInfo];
    NSString* type = userInfo[@"type"];
    NSString* keyForNotification = userInfo[@"keyForNotification"];
    if (keyForNotification) {
        if ([NSStringFromClass([self class]) isEqualToString:keyForNotification] == NO) {
            [self dismissViewControllerAnimated:YES completion:nil];
            //return;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _doTimeLineURL:URL type:type];
    });    
}

@end
