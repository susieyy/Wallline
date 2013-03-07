//
//  SVFacebookService.m
//  Pickupps
//
//  Created by 杉上 洋平 on 12/05/29.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "SVFacebookService.h"
#import "FBRequest+SSAddtions.h"
#import "SSKeychainItemWrapper.h"

@interface SVFacebookService ()
- (void) _loginFacebookActionCompletionBlock:(SSBlockVoid)completionBlock;
- (void) _logoutFacebookActionCompletionBlock:(SSBlockVoid)completionBlock;
@end

@implementation SVFacebookService
@synthesize facebook = _facebook;
@synthesize block = _block;
@synthesize isEnable = _isEnable;
@synthesize title = _title;
@synthesize via = _via;

#pragma -
#pragma Keychain

- (NSString*) _valueFromKeychainForKey:(NSString*)key
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [NSString stringWithFormat:@"%@.%@", bundleIdentifier, key];
    SSKeychainItemWrapper *wrapper = [[SSKeychainItemWrapper alloc] initWithIdentifier:identifier
                                                                           serviceName:bundleIdentifier
                                                                           accessGroup:nil];    
    NSString *value = [wrapper stringForKey];
    if (value && value.length == 0) return nil;
    return value;    
}

- (void) _setValueFromKeychainForKey:(NSString*)key value:(NSString*)value
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *identifier = [NSString stringWithFormat:@"%@.%@", bundleIdentifier, key];
    SSKeychainItemWrapper *wrapper = [[SSKeychainItemWrapper alloc] initWithIdentifier:identifier
                                                                           serviceName:bundleIdentifier
                                                                           accessGroup:nil];
    
    [wrapper resetKeychainItem];
    if (value) {
        [wrapper setString:value];
    }    
}  


+ (SVFacebookService*) service
{
    static dispatch_once_t pred;
    static SVFacebookService *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[SVFacebookService alloc] init];
    });
    return shared;
}


- (id) init
{
	self = [super init];
	if (self) {
        self.title = @"Facebook";
        self.facebook = [[Facebook alloc] initWithAppId:kFacebookAPIKey andDelegate:self];
        
        NSString* fbAccessTokenKey = [self _valueFromKeychainForKey:@"FBAccessTokenKey"];        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        NSDate* fbExpirationDateKey = [userDefaults objectForKey:@"FBExpirationDateKey"];
        
        [self _valueFromKeychainForKey:@"FBExpirationDateKey"];
        if (fbAccessTokenKey && fbExpirationDateKey) {
            self.facebook.accessToken = fbAccessTokenKey;
            self.facebook.expirationDate = fbExpirationDateKey;
        }
	}
	return self;
}

- (BOOL) isEnable
{
    return [self.facebook isSessionValid];
}

- (void) clearBlock
{
    self.block = nil;    
}

#pragma -
#pragma Facebook Login Action

/**
 * Show the authorization dialog.
 */
- (void) _loginFacebookActionCompletionBlock:(SSBlockVoid)completionBlock
{
    SS_MLOG(self);
    if (self.isEnable == NO) {
        self.block = nil;
        [self.facebook logout];        
        
        self.block = completionBlock;
        // photo_upload
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"user_about_me",
                                    @"offline_access",
                                    @"photo_upload",
                                    @"user_photos",
                                    @"friends_photos",
                                    @"publish_stream",
                                    @"read_stream",
                                    @"manage_notifications",
                                    nil];
            [self.facebook authorize:permissions];            
        }];	
        
    } else {
        // Logined
    }
}

- (void) _logoutFacebookActionCompletionBlock:(SSBlockVoid)completionBlock
{
    self.block = completionBlock;    
    [self.facebook logout];
}

#pragma -
#pragma FBSessionDelegate

- (void) fbDidLogin {
    SS_MLOG(self);
    [self _setValueFromKeychainForKey:@"FBAccessTokenKey" value:[self.facebook accessToken]];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [userDefaults synchronize];
    
    
    if (self.block) {
        self.block();
        self.block = nil;
    }
    
}

- (void)fbDidNotLogin:(BOOL)cancelled;
{
    SS_MLOG(self);
}

/**
 * Called when the request logout has succeeded.
 */
- (void) fbDidLogout {    
    SS_MLOG(self);    
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    [self _setValueFromKeychainForKey:@"FBAccessTokenKey" value:nil];
    [self _setValueFromKeychainForKey:@"FBUserName" value:nil];    
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"FBExpirationDateKey"];
    [userDefaults synchronize];
    
    [self setSelectedUserName:nil];
    
    if (self.block) {
        self.block();
        self.block = nil;
    } 
}

/**
 * Called when the session has expired.
 */
- (void )fbSessionInvalidated {   
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Auth Exception", @"") 
                              message:NSLocalizedString(@"Your session has expired.", @"")
                              delegate:nil 
                              cancelButtonTitle:@"OK" 
                              otherButtonTitles:nil, 
                              nil];
    [alertView show];
    [self fbDidLogout];
}

#pragma -
#pragma UserName

- (NSString*) selectedUserName
{
    NSString* key = @"FBUserName";
    return [self _valueFromKeychainForKey:key];    
}

- (void) setSelectedUserName:(NSString*)value
{
    NSString* key = @"FBUserName";
    [self _setValueFromKeychainForKey:key value:value];
}


///////////////////////////////////////////////////////////////////////////////


#pragma -
#pragma Tweet
- (NSURLConnection*) tweet:(NSString*)tweet image:(UIImage*)image blockCompletion:(SSBlockConnectionCompletion)blockCompletion blockProgress:(SSBlockConnectionProgress)blockProgress;
{
    NSData *dtaImage = UIImageJPEGRepresentation(image, 0.7f);
    [self tweet:tweet image:dtaImage blockCompletion:blockCompletion blockProgress:blockProgress];
}

- (NSURLConnection*) tweet:(NSString*)text dataImage:(NSData*)dataImage blockCompletion:(SSBlockConnectionCompletion)blockCompletion blockProgress:(SSBlockConnectionProgress)blockProgress;
{
    SS_MLOG(self);
    
    // Append via
    if (self.via) {
        text = [NSString stringWithFormat:@"%@\n%@", text, self.via];
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                                   dataImage, @"source", 
                                   text, @"message",
                                   nil];
    
    FBRequest* request = [self.facebook requestWithGraphPath:@"me/photos"
                                                   andParams:params
                                               andHttpMethod:@"POST"
                                             blockCompletion:blockCompletion
                                               blockProgress:blockProgress];
    
    /*
     // REST API 
     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
     dataImage, @"picture", 
     text, @"caption",
     nil];
     FBRequest* request = [self.facebook requestWithMethodName:@"photos.upload"
     andParams:params
     andHttpMethod:@"POST"
     blockCompletion:blockCompletion
     blockProgress:blockProgress];
     */ 
    return request.connection;
}

#pragma -
#pragma ActionSheet for Login

- (void) actionInView:(UIView*)view completionBlock:(SSBlockVoid)completionBlock
{
    __weak SVFacebookService* _self = self;
    if (self.isEnable) {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Logout from Facebook.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:NSLocalizedString(@"Logout", @"") otherButtonTitles:nil];
        [actionSheet showFromView:view buttonBlock:^(UIActionSheet* _actionSheet, NSInteger buttonIndex){
            if (buttonIndex == _actionSheet.cancelButtonIndex) {
                // Cancel
            } else {             
                [_self _logoutFacebookActionCompletionBlock:completionBlock];
            }
        }];
        
    } else {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Login to Facebook.", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:NSLocalizedString(@"Login", @"") otherButtonTitles:nil];
        [actionSheet showFromView:view buttonBlock:^(UIActionSheet* _actionSheet, NSInteger buttonIndex){
            if (buttonIndex == _actionSheet.cancelButtonIndex) {
                // Cancel
            } else {
                [_self _loginFacebookActionCompletionBlock:completionBlock];
            }
        }];
    }
    
}
@end
