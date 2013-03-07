//
//  AppDelegate.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/06/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "AppDelegate.h"
#import "SDImageCache.h"
#import "ECSlidingViewController.h"

@class VCTimeLineViewController;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    ///////////////////////////////////////////////////////////////////////////////
    // Random Seed
    srand((unsigned)time( NULL ));
    
    ///////////////////////////////////////////////////////////////////////////////
    // Remove Stack
    {
        NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"stacks"];
        [NSFileManager createDirectoryAtPathIfNotExist:path];
    }

    ///////////////////////////////////////////////////////////////////////////////
    // SDImageCache
    // Delete Expiration Cache (1 week)
    [[SDImageCache sharedImageCache] cleanDisk];
    
#ifdef DEBUG
    // Delete Cache
    [[SDImageCache sharedImageCache] clearDisk];
#endif
    
    ///////////////////////////////////////////////////////////////////////////////
    // Facebook session open
    {
        NSArray *permissions = [MMPermissionModel permissionsForLogin];        
        FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        [FBSession setActiveSession:session];
        SSLog(@"FBSession State [%d]", FBSession.activeSession.state);
        if (FBSessionStateCreatedTokenLoaded == FBSession.activeSession.state) {
            [session openWithCompletionHandler:nil];
        }
    }

    ///////////////////////////////////////////////////////////////////////////////
    //
    {
        NSMutableDictionary* defaults = [NSMutableDictionary dictionary];
        defaults[@"FontSizeForTimeLine"] = @13;
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults registerDefaults:defaults];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // MMRequestManager
    [[MMRequestManager sharedManager] openStore];
    
    ///////////////////////////////////////////////////////////////////////////////
    // ViewController
    {
        ECSlidingViewController *slidingViewController = (ECSlidingViewController *)self.window.rootViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        UINavigationController* navi = [storyboard instantiateViewControllerWithIdentifier:@"INITIALNAVI_IDENTIFIER"];
        slidingViewController.topViewController = navi;
    }
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[MMRequestManager sharedManager] doRequestNow];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];    
    [[MMRequestManager sharedManager] closeStore];    
}

// For 4.2+ support 
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [FBSession.activeSession handleOpenURL:url];
}

@end
