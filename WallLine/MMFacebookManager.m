//
//  MMFacebookManager.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/15.
//
//

#import "MMFacebookManager.h"
#import "FBDialog.h"

@interface FBDialogCustom : FBDialog
@property (copy, nonatomic) SSBlockError blockCompletion;
@end

@implementation FBDialogCustom


@end


@implementation MMFacebookManager

// href group
// http://www.facebook.com/groups/fbdevelopers/
// http://www.facebook.com/178527348850758
// href group stream
// http://www.facebook.com/groups/ikuful/415086981861459/
// http://www.facebook.com/groups/ikuful/permalink/415086981861459/

// href event
// http://www.facebook.com/events/126173984192567
// href event stream
// http://www.facebook.com/events/126173984192567/permalink/126615834148382/

// href freind
// http://www.facebook.com/kijimasashi?ref=nf
// http://www.facebook.com/kijimasashi?ref=nf_fr
// http://www.facebook.com/mariko.nishijima.9
// http://www.facebook.com/100002395383603
// http://www.facebook.com/inazoh.11

// href page
// http://www.facebook.com/inoharamika
// https://www.facebook.com/jwave813fm/app_334096056680321

// href (frind/page) stream
// http://www.facebook.com/yasuhiro.fujii/posts/367546739981441
// http://www.facebook.com/youhei.sugigami/posts/326261157463699
// http://www.facebook.com/chika.yamada.391/posts/4394975834314
// http://www.facebook.com/youhei.sugigami/posts/384295708304455?comment_id=15049606

// href checkin ??
// href activity
// http://www.facebook.com/profile.php?sk=approve&highlight=362074880532259&queue_type=friends

// href album
// http://www.facebook.com/album.php?fbid=375198159214210&id=100001720883274&aid=85737

// href photo
// http://www.facebook.com/photo.php?fbid=10151068382269153&set=a.10150268493399153.339817.822384152&type=1&comment_id=7275798
// http://www.facebook.com/photo.php?fbid=378609162206443&set=a.158649957535699.39753.100001720883274&type=1
// fbid=/ALBUM_ID/
// set=a./ALBUM_ID/./?/./USER_ID/

+ (NSDictionary*) parseURL:(NSURL*)URL
{
    NSString* url = [[URL absoluteString] stringByReplacingRegexPattern:@"(\\?|&)ref=[^&]+" withString:@""]; // (\\?|&)ref=nf(_fr)?
    NSString* ID = nil;
    NSString* SUBID = nil;
    NSString* objectType = nil;
    
    SSLog(@"    Facebook ParseURL [%@]", url);
    
    if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/"] == NO) return nil;
    
    if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/photo.php"]) {
        objectType = @"photo";
        ID = [url stringMatchedByRegex:@"fbid=(\\d+)"];
        SUBID = [url stringMatchedByRegex:@"comment_id=(\\d+)"];
        
    } else if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/album.php"]) {
        objectType = @"album";
        ID = [url stringMatchedByRegex:@"fbid=(\\d+)"];
        SUBID = nil; // TODO: id=100001720883274&aid=85737

    } else if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/profile.php"]) {
        objectType = @"activity";
        ID = [url stringMatchedByRegex:@"highlight=(\\d+)"];
        SUBID = nil;

    } else if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/events/"]) {
        objectType = @"event";
        ID = [url stringMatchedByRegex:@"events/([^/]+)"];
        SUBID = [url stringMatchedByRegex:@"permalink/([\\d]+)"];        

    } else if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/groups/"]) {
        objectType = @"group";
        ID = [url stringMatchedByRegex:@"groups/([^/]+)"];
        SUBID = [url stringMatchedByRegex:@"groups/[^/]+/(?:permalink/)?(\\d+)"];
        
        if (SUBID) {
            // OK
            objectType = @"stream";            
            ID = SUBID;
            SUBID = nil;
        } else {
            // TODO: can't open graph api
        }
        
    } else if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/[a-z][a-z\\d\\.]+/app_"]) {
        objectType = @"page"; // app
        SSLog(@"    Page App Open As Web");
        return nil;
        
    } else if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/[a-z][a-z\\d\\.]+/?$"]) {
        objectType = @"friend_or_page";
        ID = [url stringMatchedByRegex:@"https?://www.facebook.com/([a-z\\d\\.]+)$"];
        SUBID = nil;
        
    } else if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/[a-z][a-z\\d\\.]+/posts/"]) {
        objectType = @"stream"; // (friend/page)
        ID = [url stringMatchedByRegex:@"https?://www.facebook.com/([a-z\\d\\.]+)/"];
        SUBID = [url stringMatchedByRegex:@"posts/(\\d+)"];
        // TODO:
        // comment_id ...
        
        if (ID && [ID matchesPatternRegexPattern:@"^\\d+$"]) {
            ID = [NSString stringWithFormat:@"%@_%@", ID, SUBID];
            SUBID = nil;
        } else {
            // OK!
            // Need ID(Alias) to ID(ObjectID)
        }
        
        
    } else if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/\\d+/posts/"]) {        
        objectType = @"stream"; // (friend/page)
        ID = [url stringMatchedByRegex:@"https?://www.facebook.com/(\\d+)/"];
        SUBID = [url stringMatchedByRegex:@"posts/(\\d+)"];
        ID = [NSString stringWithFormat:@"%@_%@", ID, SUBID];
        SUBID = nil;

    } else {
        return nil;
    }

    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    info[@"objectType"] = objectType;
    if (ID) info[@"ID"] = ID;
    if (SUBID) info[@"SUBID"] = SUBID;
    return info;
}


#pragma -
#pragma

+ (MMFacebookManager *) sharedManager;
{
    static dispatch_once_t pred;
    static MMFacebookManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MMFacebookManager alloc] init];
    });
    return shared;
}


// @"100001892517801"
- (void) requestFriend:(NSString*)objectID completionBlock:(SSBlockError)completionBlock;
{
    NSString* action = @"friends/";
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    NSString* base = @"https://www.facebook.com/dialog/";
    NSString *dialogURL = [base stringByAppendingString:action];
    [params setObject:@"popup" forKey:@"display"]; // page, touch, iframe
    [params setObject:@"3" forKey:@"sdk"];
    [params setObject:@"fbconnect://success" forKey:@"redirect_uri"];
    [params setObject:[FBSession.activeSession appID] forKey:@"app_id"];
    [params setObject:[FBSession.activeSession accessToken] forKey:@"access_token"];
    
    [params setObject:objectID forKey:@"id"];
    
    BOOL invisible = NO;
    /*
     {
     // set invisible if all recipients are enabled for frictionless requests
     id fbid = [params objectForKey:@"to"];
     if (fbid != nil) {
     // if value parses as a json array expression get the list that way
     SBJsonParser *parser = [[[SBJsonParser alloc] init] autorelease];
     id fbids = [parser objectWithString:fbid];
     if (![fbids isKindOfClass:[NSArray class]]) {
     // otherwise seperate by commas (handles the singleton case too)
     fbids = [fbid componentsSeparatedByString:@","];
     }
     invisible = [self isFrictionlessEnabledForRecipients:fbids];
     }
     }
     */
    
    FBDialogCustom* fbDialog = [[FBDialogCustom alloc] initWithURL:dialogURL
                                                params:params
                                       isViewInvisible:invisible
                                  frictionlessSettings:nil
                                              delegate:self];
    fbDialog.blockCompletion = completionBlock;
    [fbDialog show];
}

#pragma -
#pragma FBDialogDelegate

/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(FBDialogCustom *)dialog;
{
    SS_MLOG(self);
    if (dialog.blockCompletion) {
        dialog.blockCompletion(nil);
    }
}

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url;
{
    SS_MLOG(self);
}

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url;
{
    SS_MLOG(self);
}

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialogCustom *)dialog;
{
    SS_MLOG(self);
    if (dialog.blockCompletion) {
        // Do Nothing 
        // dialog.blockCompletion([NSError errorWithDomain:@"" code:0 userInfo:nil]);
    }
}

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialogCustom*)dialog didFailWithError:(NSError *)error;
{
    SS_MLOG(self);
    if (dialog.blockCompletion) {
        dialog.blockCompletion(error);
    }
}

/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser,
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url;
{
    SS_MLOG(self);
}

@end
