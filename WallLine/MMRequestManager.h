//
//  MMRequestManager.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/07.
//
//

#import <Foundation/Foundation.h>

static NSString * const NFDoStartRequest = @"NFDoStartRequest";
static NSString * const NFDoProgressRequest = @"NFDoProgressRequest";
static NSString * const NFDoFinishRequest = @"NFDoFinishRequest";
static NSString * const NFDoErrorRequest = @"NFDoErrorRequest";
static NSString * const NFDoCancelRequest = @"NFDoCancelRequest";

static NSString * const NFDidNotificationOrFriendRequest = @"NFDidNotificationOrFriendRequest";
static NSString * const NFDidStatusRequest = @"NFDidStatusRequest";
static NSString * const NFWillCommentRequest = @"NFWillCommentRequest";
static NSString * const NFDidCommentRequest = @"NFDidCommentRequest";


@interface MMRequestManager : NSObject
+ (MMRequestManager *) sharedManager;

- (void) openStore;
- (void) closeStore;
- (void) request;

// 
- (void) doLikeObjectID:(NSString*)objectID;
- (void) doUnLikeObjectID:(NSString*)objectID;

- (void) doCommentObjectID:(NSString*)objectID comment:(NSString*)comment;

- (void) doPostObjectID:(NSString*)objectID status:(NSString*)status privacy:(NSString*)privacy;
// message, picture, link, name, caption, description, source, place, tags
// privacy : EVERYONE, CUSTOM, ALL_FRIENDS, NETWORKS_FRIENDS, FRIENDS_OF_FRIENDS, SELF

- (void) doReadNotification:(NSString*)objectID;
@end

@interface MMRequestManager (Request)
- (void) doRequestNowIfExsitQeue;
- (void) doRequestNow;
- (void) _doIntervalRequest;
- (void) _doRequest;
@end