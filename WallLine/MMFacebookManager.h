//
//  MMFacebookManager.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/15.
//
//

#import <Foundation/Foundation.h>

static NSString * const FacebookPrivacyEvryone = @"EVERYONE";
static NSString * const FacebookPrivacyCustom = @"CUSTOM";
static NSString * const FacebookPrivacyAllFriends = @"ALL_FRIENDS";
static NSString * const FacebookPrivacyNetworksFriends = @"NETWORKS_FRIENDS";
static NSString * const FacebookPrivacyFriendsOfFriedns = @"FRIENDS_OF_FRIENDS";
static NSString * const FacebookPrivacySelf = @"SELF";


@interface MMFacebookManager : NSObject

+ (NSDictionary*) parseURL:(NSURL*)URL;

+ (MMFacebookManager *) sharedManager;
- (void) requestFriend:(NSString*)objectID completionBlock:(SSBlockError)completionBlock;

@end
