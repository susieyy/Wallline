//
//  MMRequestManager.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/07.
//
//

#import "MMRequestManager.h"
#import "VCProgressViewController.h"

#define INTERVAL 90

@interface NSError (FBFacebook)
- (NSUInteger) errorHTTPStatusCodeKey;
@end

@implementation NSError (FBFacebook)

- (NSUInteger) errorHTTPStatusCodeKey;
{
    NSNumber* n = [self userInfo][FBErrorHTTPStatusCodeKey];
    NSUInteger code = [n integerValue];
    return code;
}

@end



static NSString * const KeyLike = @"like";
static NSString * const KeyUnlike = @"unlike";
static NSString * const KeyComment = @"comment";
static NSString * const KeyStatus = @"status";
static NSString * const KeyPhoto = @"photo";
static NSString * const KeyNotification = @"notification";

@interface MMRequestManager ()
@property (strong, nonatomic) NSTimer* timerForIntervalRequest;
@property (strong, nonatomic) NSFNanoStore *nanoStore;
@property (strong, nonatomic) FBRequestConnection* requestConnection;
@property (nonatomic) BOOL isExecuting;
@end

@implementation MMRequestManager

+ (MMRequestManager *) sharedManager;
{
    static dispatch_once_t pred;
    static MMRequestManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MMRequestManager alloc] init];
    });
    return shared;
}

- (id) init
{
	self = [super init];
	if (self) {
        [self _startIntervalRequest];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didLogin) name:NFDidLogin object:nil];        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didLogout:) name:NFDidLogout object:nil];

	}
	return self;
}

- (void) dealloc
{
    SS_MLOG(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) __error:(NSError*)error
{
    if (error) {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
    }
}

#pragma -
#pragma

- (void) _didLogin
{
    SS_MLOG(self);
    [self doRequestNow];
}

- (void) _didLogout
{
    SS_MLOG(self);
    [self closeStore];
    NSString *path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"data.sql"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];    
    [self openStore];
}

#pragma -
#pragma Store

- (void) openStore;
{
    SS_MLOG(self);
    NSString *path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"data.sql"];
    NSError * error = nil;
    NSFNanoStore *nanoStore = [NSFNanoStore createAndOpenStoreWithType:NSFPersistentStoreType path:path error:&error];
    [nanoStore setSaveInterval:1000];    
    self.nanoStore = nanoStore;
    [self __error:error];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _doRequest];
    });

}

- (void) closeStore;
{
    NSError * error = nil;
    [self.nanoStore closeWithError:&error];
    [self __error:error];
}

#pragma -
#pragma Timer

- (void) _startIntervalRequest
{
    self.timerForIntervalRequest = [NSTimer scheduledTimerWithTimeInterval:INTERVAL target:self selector:@selector(_doIntervalRequest) userInfo:nil repeats:YES];
}

- (void) _restartIntervalRequest
{
    [self.timerForIntervalRequest invalidate];
    self.timerForIntervalRequest = nil;
    [self _startIntervalRequest];
}


#pragma -
#pragma

- (BOOL) _removeObject:(NSString*)objectID type:(NSString*)type
{
    NSError * error = nil;
    NSFNanoSearch *search = [NSFNanoSearch searchWithStore:self.nanoStore];
    search.attribute = @"objectID";
    search.match = NSFEqualTo;
    search.value = objectID;
    NSDictionary *objects = [search searchObjectsWithReturnType:NSFReturnObjects error:&error];
    for (NSFNanoObject *object in objects.allValues) {
        NSDictionary* info = [object info];
        if ([info[@"type"] isEqualToString:type]) {
            [self.nanoStore removeObject:object error:nil];
            [self.nanoStore saveStoreAndReturnError:nil];
            return YES;
        }
    }
    return NO;
}

#pragma -
#pragma Like

- (void) doLikeObjectID:(NSString*)objectID
{
    SS_MLOG(self);
    
    BOOL isRemoved = [self _removeObject:objectID type:KeyUnlike];
    if (isRemoved) return;
    
    NSString* type = KeyLike;
    [self _removeObject:objectID type:type];
    {
        NSError * error = nil;        
        NSDictionary* info = @{@"objectID":objectID, @"type":type};
        NSFNanoObject *object = [NSFNanoObject nanoObjectWithDictionary:info];
        [self.nanoStore addObject:object error:nil];
        [self.nanoStore saveStoreAndReturnError:&error];
        [self __error:error];    

        [self doRequestNow];
    }
}

- (void) doUnLikeObjectID:(NSString*)objectID
{
    SS_MLOG(self);    
    BOOL isRemoved = [self _removeObject:objectID type:KeyLike];
    if (isRemoved) return;

    NSString* type = KeyUnlike;    
    [self _removeObject:objectID type:type];    
    {
        NSError * error = nil;
        NSDictionary* info = @{@"objectID":objectID, @"type":type};
        NSFNanoObject *object = [NSFNanoObject nanoObjectWithDictionary:info];
        [self.nanoStore addObject:object error:nil];
        [self.nanoStore saveStoreAndReturnError:&error];
        [self __error:error];
        
        [self doRequestNow];
    }
}

#pragma -
#pragma Comment

- (void) doCommentObjectID:(NSString*)objectID comment:(NSString*)comment;
{
    SS_MLOG(self);
    NSString* type = KeyComment;
    {
        NSError * error = nil;
        NSDictionary* info = @{@"objectID":objectID, @"type":type, @"comment":comment };
        NSFNanoObject *object = [NSFNanoObject nanoObjectWithDictionary:info];
        [self.nanoStore addObject:object error:nil];
        [self.nanoStore saveStoreAndReturnError:&error];
        [self __error:error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NFWillCommentRequest object:info userInfo:nil];
        });

        [self doRequestNow];
    }

}

#pragma -
#pragma PostStatus

- (void) doPostObjectID:(NSString*)objectID status:(NSString*)status privacy:(NSString*)privacy;
{
    SS_MLOG(self);
    if (objectID == nil) objectID = @"me";
    
    NSString* type = KeyStatus;
    {
        NSError * error = nil;
        NSDictionary* info = @{@"objectID":objectID, @"type":type, @"status":status, @"privacy":privacy };
        NSFNanoObject *object = [NSFNanoObject nanoObjectWithDictionary:info];
        [self.nanoStore addObject:object error:nil];
        [self.nanoStore saveStoreAndReturnError:&error];
        [self __error:error];
        
        [self doRequestNow];
    }    
}

#pragma -
#pragma

- (void) doReadNotification:(NSString*)objectID;
{
    SS_MLOG(self);
    NSString* type = KeyNotification;
    [self _removeObject:objectID type:type];    
    {
        NSError * error = nil;
        NSDictionary* info = @{@"objectID":objectID, @"type":type };
        NSFNanoObject *object = [NSFNanoObject nanoObjectWithDictionary:info];
        [self.nanoStore addObject:object error:nil];
        [self.nanoStore saveStoreAndReturnError:&error];
        [self __error:error];
        
        // [self doRequestNow]; No Requst Here
    }   
}
@end


@implementation MMRequestManager (Request) 

- (void) _doStartRequestNotification
{
    SS_MLOG(self);
    [VCProgressViewController requestStartForProgress:ProgressModeSend keyNotification:nil];
}

- (void) _doProgressRequestNotification:(CGFloat)_progress
{
    CGFloat progress = _progress / 3.8f;    
    SSLog(@"    SEND PROGRESS [%f] [%f]", _progress, progress);
    [VCProgressViewController requestProgressForProgress:ProgressModeSend keyNotification:nil progress:_progress];
}

- (void) _doFinishRequestNotification
{
    SS_MLOG(self);
    [VCProgressViewController requestFinishForProgress:ProgressModeSend keyNotification:nil];
}

- (void) _doCancelRequestNotification
{
    SS_MLOG(self);
}

- (void) _doErrorRequestNotification:(NSError*)error
{
    SS_MLOG(self);
    [VCProgressViewController requestErrorForProgress:ProgressModeSend keyNotification:nil error:error];
    
    NSDictionary* userInfo = [error userInfo];
    NSError* innerError = [userInfo objectForKey:FBErrorInnerErrorKey];
    NSLog(@"[ERROR] [REQUEST] %@", [innerError description]);
    //WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", @"") message:[innerError localizedDescription]];
    //notice.delay = 3.0f;
    //[notice show];
}

#pragma -
#pragma

- (void) _doIntervalRequest;
{
    if (self.requestConnection) {
        [self.requestConnection cancel];
    }
    self.requestConnection = nil;
    self.isExecuting = NO;
    
    [self _doRequest];
}

- (void) doRequestNowIfExsitQeue;
{
    NSError * error = nil;
    NSFNanoSearch *search = [NSFNanoSearch searchWithStore:self.nanoStore];
    NSDictionary *objects = [search searchObjectsWithReturnType:NSFReturnObjects error:&error];
    if (objects.allValues.count == 0) return;
    [self doRequestNow];

}

- (void) doRequestNow;
{
    SS_MLOG(self);
    [self _restartIntervalRequest];
    [self _doRequest];    
}

- (void) _doRequest;
{
    SS_MLOG(self);
    __weak MMRequestManager* _self = self;
    
    if (FBSession.activeSession.isOpen == NO) {
        SSLog(@"    No FBSession is open.");
        return;
    }
    if (self.isExecuting == YES) {
        SSLog(@"    Excuting Now.");
        return;
    }
    
    SSLog(@"    START POST REQUEST");            
    self.isExecuting = YES;
    self.requestConnection = nil;
    
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];
    NSUInteger countForRequest = 0;
    NSUInteger countForNeedProgress = 0;

    ///////////////////////////////////////////////////////////////////////////////
    // Store
    {
        NSError * error = nil;
        NSFNanoSearch *search = [NSFNanoSearch searchWithStore:self.nanoStore];
        NSDictionary *objects = [search searchObjectsWithReturnType:NSFReturnObjects error:&error];
        
        for (NSFNanoObject *object in objects.allValues) {
            NSDictionary* info = [object info];
            NSString* type = info[@"type"];
            
            ///////////////////////////////////////////////////////////////////////////////
            // Like
            if ([type isEqualToString:KeyLike]) {
                countForRequest++;
                countForNeedProgress++;
                FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
                    _self.isExecuting = NO;
                    SSLog(@"    FINISH POST LIKE URL [%@] ERROR [%@]", [connection.urlRequest URL], [error description]);
                    if (error == nil || [error errorHTTPStatusCodeKey] == 400) {
                        [_self.nanoStore removeObject:object error:nil];
                        [_self.nanoStore saveStoreAndReturnError:nil];
                    }   
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            [_self _doErrorRequestNotification:error];
                        }
                    });
                };
                NSString* objectID = info[@"objectID"];
                NSString* graphPath = [NSString stringWithFormat:@"%@/likes", objectID];
                NSMutableDictionary* params = [NSMutableDictionary dictionary];
                FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"POST"];
                [requestConnection addRequest:request completionHandler:block];
                SSLog(@"    START POST LIKE URL [%@] ", graphPath);
            }
            
            ///////////////////////////////////////////////////////////////////////////////
            // Unlike
            if ([type isEqualToString:KeyUnlike]) {
                countForRequest++;
                countForNeedProgress++;                
                FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
                    _self.isExecuting = NO;
                    SSLog(@"    FINISH POST UNLIKE URL [%@] ERROR [%@]", [connection.urlRequest URL], [error description]);
                    NSUInteger code = [error errorHTTPStatusCodeKey];
                    if (error == nil || code == 400) {
                        [_self.nanoStore removeObject:object error:nil];
                        [_self.nanoStore saveStoreAndReturnError:nil];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            [_self _doErrorRequestNotification:error];
                        }
                    });
                };
                NSString* objectID = info[@"objectID"];
                NSString* graphPath = [NSString stringWithFormat:@"%@/likes", objectID];
                NSMutableDictionary* params = [NSMutableDictionary dictionary];
                //params[@"method"] = @"delete";
                FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"DELETE"];
                [requestConnection addRequest:request completionHandler:block];
                SSLog(@"    START DELETE UNLIKE URL [%@] ", graphPath);
            }

            ///////////////////////////////////////////////////////////////////////////////
            // Comment
            if ([type isEqualToString:KeyComment]) {
                countForRequest++;
                countForNeedProgress++;
                FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
                    _self.isExecuting = NO;
                    SSLog(@"    FINISH POST COMMENT URL [%@] ERROR [%@]", [connection.urlRequest URL], [error description]);                    
                    NSDictionary* _info = [[object info] copy];
                    if (error == nil) {
                        [_self.nanoStore removeObject:object error:nil];
                        [_self.nanoStore saveStoreAndReturnError:nil];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{                        
                        if (error) {
                            [_self _doErrorRequestNotification:error];
                        } else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NFDidCommentRequest object:_info userInfo:nil];
                        }
                    });
                };
                NSString* objectID = info[@"objectID"];
                NSString* graphPath = [NSString stringWithFormat:@"%@/comments", objectID];
                NSMutableDictionary* params = [NSMutableDictionary dictionary];
                params[@"message"] = info[@"comment"];
                
                FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"POST"];
                [requestConnection addRequest:request completionHandler:block];
            }

            ///////////////////////////////////////////////////////////////////////////////
            // Post Status
            if ([type isEqualToString:KeyStatus]) {
                countForRequest++;
                countForNeedProgress++;                
                FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
                    _self.isExecuting = NO;
                    NSDictionary* _info = [[object info] copy];                    
                    if (error == nil) {
                        SSLog(@"    FINISH POST STATUS URL [%@]", [connection.urlRequest URL]);
                        [_self.nanoStore removeObject:object error:nil];
                        [_self.nanoStore saveStoreAndReturnError:nil];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (error) {
                            [_self _doErrorRequestNotification:error];
                        } else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NFDidStatusRequest object:_info userInfo:nil];
                        }
                    });
                };
                NSString* objectID = info[@"objectID"];                
                NSString* graphPath = [NSString stringWithFormat:@"%@/feed", objectID];
                NSMutableDictionary* params = [NSMutableDictionary dictionary];
                params[@"message"] = info[@"status"];
                
                NSString* privacy = info[@"privacy"];
                if (privacy && privacy.length > 0) {
                    params[@"privacy"] = [@{ @"value":privacy } JSONFragment];
                }
                
                FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"POST"];
                [requestConnection addRequest:request completionHandler:block];
            }
            
            ///////////////////////////////////////////////////////////////////////////////
            // Notification
            if ([type isEqualToString:KeyNotification]) {
                countForRequest++;
                FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
                    _self.isExecuting = NO;
                    NSUInteger code = [error errorHTTPStatusCodeKey];
                    if (error == nil || code == 400) {
                        SSLog(@"    FINISH POST NOTIFICATION URL [%@]", [connection.urlRequest URL]);
                        [_self.nanoStore removeObject:object error:nil];
                        [_self.nanoStore saveStoreAndReturnError:nil];
                    }
                };
                NSString* objectID = info[@"objectID"];
                NSString* graphPath = [NSString stringWithFormat:@"notif_%@_%@", [[MMMeModel sharedManager] objectForKey:@"id"], objectID];
                NSMutableDictionary* params = [NSMutableDictionary dictionary];
                params[@"unread"] = @"0";
                FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"POST"];
                [requestConnection addRequest:request completionHandler:block];
            }
            
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Notification / FriendRequests
    {
        NSTimeInterval interval = 0;
        {
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            NSDate* dateForLast = [userDefaults objectForKey:@"dateForLastRequestNotification"];
            if (dateForLast) {
                interval = fabs([dateForLast timeIntervalSinceNow]);
            } else {
                interval = 6 * 60;
            }
        }
        BOOL isNeedRequest = !! (interval > 5 * 60);
        
        ///////////////////////////////////////////////////////////////////////////////
        // Notification
        if (isNeedRequest) {
            countForRequest++;        
            NSMutableDictionary* params = [NSMutableDictionary dictionary];
            params[@"q"] = @"SELECT notification_id,sender_id,object_type,title_html,body_text,href,is_unread,is_hidden,updated_time FROM notification WHERE recipient_id = me() LIMIT 25";
            NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
            params[@"locale"] = locale;
            
            //[params setValue:@"25" forKey:@"limit"];
            //[params setValue:@"1" forKey:@"include_read"];
            
            NSString* graphPath = @"fql";
            //NSString* graphPath = @"me/notifications";
            
            FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    SSLog([results description]);
                    _self.isExecuting = NO;                
                    if (error == nil) {
                        {
                            NSDate* date = [NSDate date];
                            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                            [userDefaults setObject:date forKey:@"dateForLastRequestNotification"];
                            [userDefaults synchronize];
                        }
                        
                        NSDictionary* dict = results;
                        NSArray* datas = dict[@"data"];
                        
                        // Unread
                        {
                            NSUInteger countForUnread = 0;
                            for (NSDictionary* data in datas) {
                                NSUInteger isUnread = [data[@"is_unread"] integerValue];
                                if (isUnread == 1) countForUnread++;
                            }
                            
                            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                            [userDefaults setInteger:countForUnread forKey:@"countForUnreadNotification"];
                            [userDefaults synchronize];

                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:NFDidNotificationOrFriendRequest object:nil userInfo:nil];
                            });
                        }
                        // Archive
                        {
                            NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"notifications.dat"];
                            [NSKeyedArchiver archiveRootObject:datas toFile:path];
                        }
                    }
                });
            };
            
            FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
            [requestConnection addRequest:request completionHandler:block];
            SSLog(@"    NOTIFICATION URL [%@]", [requestConnection.urlRequest URL]);        
        }
        
        ///////////////////////////////////////////////////////////////////////////////
        // FriendRequests
        if (isNeedRequest) {
            countForRequest++;
            NSMutableDictionary* params = [NSMutableDictionary dictionary];
            NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
            params[@"locale"] = locale;
            
            NSString* graphPath = @"me/friendrequests";
            
            FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    SSLog([results description]);
                    _self.isExecuting = NO;
                    if (error == nil) {
                        NSDictionary* dict = results;
                        NSArray* datas = dict[@"data"];
                        // Archive
                        {
                            NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"friendrequests.dat"];
                            [NSKeyedArchiver archiveRootObject:datas toFile:path];
                        }
                        // Unread
                        if (dict[@"summary"]) {
                            NSUInteger countForUnread = [dict[@"summary"][@"unread_count"] integerValue];
                            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                            [userDefaults setInteger:countForUnread forKey:@"countForUnreadFriendRequest"];
                            [userDefaults synchronize];

                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:NFDidNotificationOrFriendRequest object:nil userInfo:nil];
                            });

                        }
                    }
                });
            };
            
            FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
            [requestConnection addRequest:request completionHandler:block];
            SSLog(@"    FRIENDREQUEST URL [%@]", [requestConnection.urlRequest URL]);
        }
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // Dummy Requst Me
    if (countForRequest > 0) {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        params[@"locale"] = locale;
        // params[@"fields"] = @"id";

        FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphObject> *results, NSError *error) {
            _self.isExecuting = NO;
            _self.requestConnection = nil;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                MMMeModel* meModel = [MMMeModel sharedManager];
                [meModel setData:results];
                [meModel archive];        
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        [_self _doErrorRequestNotification:error];
                    } else {
                        [_self _doFinishRequestNotification];                    
                    }
                });
            });
        };
        
        NSString* graphPath = @"me";
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Request
    if (countForRequest > 0) {
        if (countForNeedProgress > 0) {
            [self _doStartRequestNotification];
            [requestConnection startWithBlockProgressSend:^(float progress) {
                [_self _doProgressRequestNotification:progress];
            }];
        } else {
            [requestConnection start];
        }
        self.requestConnection = requestConnection;
        SSLog(@"    POST REQUEST URL [%@]", [requestConnection.urlRequest URL]);
    } else {
        SSLog(@"    NOTHING POST REQUEST");        
        self.isExecuting = NO;
    }
}

@end

/*
privacy object
A JSON-encoded object that defines the privacy setting for a post, video, or album. It contains the following fields.

value (string): The privacy value for the object, specify one of EVERYONE, CUSTOM, ALL_FRIENDS, NETWORKS_FRIENDS, FRIENDS_OF_FRIENDS, SELF.
friends (string): For CUSTOM settings, this indicates which users can see the object. Can be one of EVERYONE, NETWORKS_FRIENDS (when the object can be seen by networks and friends), FRIENDS_OF_FRIENDS, ALL_FRIENDS, SOME_FRIENDS, SELF, or NO_FRIENDS (when the object can be seen by a network only).
networks (string): For CUSTOM settings, specify a comma-separated list of network IDs that can see the object, or 1 for all of a user's networks.
allow (string): When friends is set to SOME_FRIENDS, specify a comma-separated list of user IDs and friend list IDs that ''can'' see the post.
deny (string): When friends is set to SOME_FRIENDS, specify a comma-separated list of user IDs and friend list IDs that ''cannot'' see the post.
*/
