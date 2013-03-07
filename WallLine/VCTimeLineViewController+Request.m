//
//  VCTimeLineViewController+Request.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/20.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCTimeLineViewController+Request.h"
#import "VCTimeLineViewController+Progress.h"

#import "UUTimeLineCell.h"
#import "FBRequestConnection+Internal.h"

#import "MWRTPhotoBrowserViewController.h"

@implementation VCTimeLineViewController (Request)

- (NSString*) _createGraphPath
{
    NSString* graphPath = nil;
    switch (self.stackModel.timeLineType) {
        case VCTimeLineTypeNews:
            graphPath = @"me/home";
            break;
            
        case VCTimeLineTypeFriend:
            graphPath = [NSString stringWithFormat:@"%@/feed", self.stackModel.ID];
            break;
            
        case VCTimeLineTypeEvent:
            graphPath = [NSString stringWithFormat:@"%@/feed", self.stackModel.ID];
            break;
            
        case VCTimeLineTypePage:
            graphPath = [NSString stringWithFormat:@"%@/feed", self.stackModel.ID];
            break;
            
        default:
            graphPath = [NSString stringWithFormat:@"%@/feed", self.stackModel.ID];
            break;
    }
    return graphPath;
}

#pragma -
#pragma Request

- (void) cancelRequestConnection;
{
    SS_MLOG(self); 
    [self.requestConnection cancel];
    self.requestConnection = nil;
    
    NSString* key = NSStringFromClass([self class]);
    [VCProgressViewController requestCancelForProgress:ProgressModeFetch keyNotification:key];
}

#pragma -
#pragma Requst

- (void) requestTimeLineCompletionBlock:(SSBlockError)completionBlock
{
    SS_MLOG(self); 
    __weak VCTimeLineViewController * _self = self;
        
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];
    NSUInteger countForRequest = 0;
    
    ///////////////////////////////////////////////////////////////////////////////
    // Friend
/*
    if (VCTimeLineTypeFriend == self.stackModel.timeLineType) {
        SSLog(@"    REQUEST [%@]", [self.stackModel.objectType stringAsCapitalizedFirstLetter]);
        countForRequest++;
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];    
        [params setValue:locale forKey:@"locale"];    
        NSString* fql = [NSString stringWithFormat:@"SELECT id,name,bio,birthday,cover,education,hometown,work FROM user WHERE uid = %@", self.stackModel.ID];
        SSLog(@"    FQL [%@]", fql);
        [params setValue:fql forKey:@"q"];

        // email,website,
        FBRequestHandler block2 = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            SSLog([results description]);
            _self.stackModel.friendModel = [[MMUserModel alloc] initWithData:results];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self updateCoverImage];
            });
        };
        NSString* graphPath = @"fql";
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block2];        
    }
*/
/*
    if (VCTimeLineTypeFriend == self.stackModel.timeLineType) {
        SSLog(@"    REQUEST [%@]", [self.stackModel.objectType stringAsCapitalizedFirstLetter]);
        countForRequest++;
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        [params setValue:locale forKey:@"locale"];
        
        [params setValue:@"id,name,bio,birthday,cover,education,hometown,work" forKey:@"fields"];
        // email,website,
        FBRequestHandler block2 = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            SSLog([results description]);
            _self.stackModel.friendModel = [[MMUserModel alloc] initWithData:results];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self updateCoverImage];
            });
        };
        NSString* graphPath = [NSString stringWithFormat:@"%@", self.stackModel.ID];
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block2];
    }
*/
    
    ///////////////////////////////////////////////////////////////////////////////
    // Friend/Event/Page/Application/Group
    if (VCTimeLineTypeEvent == self.stackModel.timeLineType ||
        VCTimeLineTypeApplication == self.stackModel.timeLineType ||
        VCTimeLineTypeGroup == self.stackModel.timeLineType ||
        VCTimeLineTypePage == self.stackModel.timeLineType ||
        VCTimeLineTypeFriend == self.stackModel.timeLineType ||
        VCTimeLineTypeFriendOrPage == self.stackModel.timeLineType) {
        countForRequest++;
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        params[@"locale"] = locale;
        // params[@"metadata"] = @"1";

        if (VCTimeLineTypeFriend == _self.stackModel.timeLineType) {
            [params setValue:@"id,name,bio,birthday,cover,education,hometown,work" forKey:@"fields"];
            // email,website,
        }
        
        FBRequestHandler block2 = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            SSLog([results description]);
            if (error == nil) {
                if (VCTimeLineTypeFriend == _self.stackModel.timeLineType) {
                    _self.stackModel.friendModel = [[MMFriendModel alloc] initWithData:results];
                }
                if (VCTimeLineTypeEvent == _self.stackModel.timeLineType) {
                    _self.stackModel.eventModel = [[MMEventModel alloc] initWithData:results];
                }
                if (VCTimeLineTypeApplication == _self.stackModel.timeLineType) {
                    _self.stackModel.applicationModel = [[MMApplicationModel alloc] initWithData:results];
                }
                if (VCTimeLineTypePlace == _self.stackModel.timeLineType) {
                    _self.stackModel.placeModel = [[MMPlaceModel alloc] initWithData:results];
                }
                if (VCTimeLineTypePage == _self.stackModel.timeLineType) {
                    _self.stackModel.pageModel = [[MMPageModel alloc] initWithData:results];
                }
                if (VCTimeLineTypeGroup == _self.stackModel.timeLineType) {
                    _self.stackModel.groupModel = [[MMGroupModel alloc] initWithData:results];
                }
                if (VCTimeLineTypeFriendOrPage == _self.stackModel.timeLineType) {
                    if (results[@"birthday"] || results[@"gender"]) {
                        _self.stackModel.friendModel = [[MMFriendModel alloc] initWithData:results];
                    } else {
                       _self.stackModel.pageModel = [[MMPageModel alloc] initWithData:results]; 
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_self updateHeaderTitle];
                    [_self updateCoverImage];
                });
            }
        };
        NSString* graphPath = [NSString stringWithFormat:@"%@", self.stackModel.ID];
        SSLog(@"    REQUEST [%@] GraphPath [%@]", [self.stackModel.objectType stringAsCapitalizedFirstLetter], graphPath);
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block2];
    }

    ///////////////////////////////////////////////////////////////////////////////
    // IsLiked
    if (VCTimeLineTypePage == self.stackModel.timeLineType ||
        VCTimeLineTypeFriendOrPage == self.stackModel.timeLineType) {

        FBRequestHandler block2 = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            SSLog([results description]);
            if (error == nil) {
                NSArray* datas = [results objectForKey:@"data"];
                if (datas && datas.count) {
                    MMPageModel* pageModel = (MMPageModel*) _self.stackModel.model;
                    if (pageModel) {
                        pageModel.isLiked = YES;
                    }
                } else {
                    // DoNothing
                }
            }
        };
        
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        params[@"locale"] = locale;

        NSString* graphPath = [NSString stringWithFormat:@"%@/likes/%@", [[MMMeModel sharedManager] objectForKey:@"id"], self.stackModel.ID];
        SSLog(@"    REQUEST [%@] GraphPath [%@]", @"IS LIKE", graphPath);
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block2];
    }

    ///////////////////////////////////////////////////////////////////////////////
    // IsFriend
    if (VCTimeLineTypeFriend == self.stackModel.timeLineType ||
        VCTimeLineTypeFriendOrPage == self.stackModel.timeLineType) {
        
        FBRequestHandler block2 = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            SSLog([results description]);
            if (error == nil) {
                NSArray* datas = [results objectForKey:@"data"];
                if (datas && datas.count) {
                    MMFriendModel* friendModel = (MMFriendModel*) _self.stackModel.model;
                    if (friendModel) {
                        friendModel.isFriend = YES;
                    }
                } else {
                    // DoNothing
                }
            }
        };
        
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        params[@"locale"] = locale;
        
        NSString* graphPath = [NSString stringWithFormat:@"%@/friends/%@", [[MMMeModel sharedManager] objectForKey:@"id"], self.stackModel.ID];
        SSLog(@"    REQUEST [%@] GraphPath [%@]", @"IS FRIEND", graphPath);
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block2];
    }

    ///////////////////////////////////////////////////////////////////////////////
    // Stream
    if (VCTimeLineTypeStream == self.stackModel.timeLineType) {

        FBRequestHandler block2 = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphObject> *results, NSError *error) {
            SSLog([results description]);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (connection.isResultFromCache) {
                    SSLog(@"    ResultFromCache URL [%@]", [connection.urlRequest URL]);
                }
                [self __debug:results];
                if (error == nil) {
                    MMStatusModel* statusModel = [[MMStatusModel alloc] initWithData:results]; // !
                    [statusModel createTextComponents]; // !
                    
                    _self.stackModel.paging = results[@"paging"];
                    _self.stackModel.datas = @[ statusModel ]; // !
                    _self.stackModel.isRequested = YES;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock(error);
                    [_self updateCoverImage]; // !
                    if (error) {
                        NSString* key = NSStringFromClass([self class]);
                        [VCProgressViewController requestErrorForProgress:ProgressModeFetch keyNotification:key error:error];
                    } else {
                        NSString* key = NSStringFromClass([self class]);
                        [VCProgressViewController requestFinishForProgress:ProgressModeFetch keyNotification:key];
                    }
                });
            });
        };

        if ([self.stackModel.ID matchesPatternRegexPattern:@"^[\\d_]+$"]) {
            countForRequest++;
            NSMutableDictionary* params = [NSMutableDictionary dictionary];
            NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
            params[@"locale"] = locale;
            
            NSString* graphPath = [NSString stringWithFormat:@"%@", self.stackModel.ID];
            SSLog(@"    REQUEST [%@] GraphPath [%@]", [self.stackModel.objectType stringAsCapitalizedFirstLetter], graphPath);
            FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
            [requestConnection addRequest:request completionHandler:block2];
            
        } else if (self.stackModel.SUBID) {
            countForRequest++;            
            {
                NSMutableDictionary* params = [NSMutableDictionary dictionary];                
                [params setValue:@"id" forKey:@"fields"];                
                NSString* graphPath = self.stackModel.ID;
                SSLog(@"    REQUEST [%@] GraphPath [%@]", @"MULTI", self.stackModel.ID);
                FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
                [requestConnection addRequest:request completionHandler:nil batchEntryName:@"get-id"];
            }
            {
                NSMutableDictionary* params = [NSMutableDictionary dictionary];
                NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
                params[@"locale"] = locale;

                NSString* graphPath = [NSString stringWithFormat:@"{result=get-id:$.id}_%@", self.stackModel.SUBID];
                SSLog(@"    REQUEST [%@] GraphPath [%@]", @"MULTI", graphPath);
                FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
                [requestConnection addRequest:request completionHandler:block2];
                
            }
        }
    }
    

    ///////////////////////////////////////////////////////////////////////////////
    // Feed
    if (VCTimeLineTypeStream != self.stackModel.timeLineType) {
        countForRequest++;        
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];    
        params[@"locale"] = locale;
        params[@"limit"] = @"25";
        
        FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (connection.isResultFromCache) {
                    SSLog(@"    ResultFromCache URL [%@]", [connection.urlRequest URL]);
                }
                [self __debug:results];
                if (error == nil) {
                    _self.stackModel.paging = results[@"paging"];
                    _self.stackModel.datas = [_self _datasFromResults:results];
                    _self.stackModel.isRequested = YES;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock(error);
                    if (error) {
                        NSString* key = NSStringFromClass([self class]);
                        [VCProgressViewController requestErrorForProgress:ProgressModeFetch keyNotification:key error:error];

                    } else {
                        NSString* key = NSStringFromClass([self class]);
                        [VCProgressViewController requestFinishForProgress:ProgressModeFetch keyNotification:key];
                        
                        [[MMRequestManager sharedManager] doRequestNowIfExsitQeue];
                    }
                });           
            });            
        };

        NSString* graphPath = [self _createGraphPath];
        SSLog(@"    REQUEST [Feed] GraphPath [%@]", graphPath);        
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block];
    }
    
    if (countForRequest > 0) {
        NSString* key = NSStringFromClass([self class]);
        [VCProgressViewController requestStartForProgress:ProgressModeFetch keyNotification:key];
        [requestConnection startWithBlockProgress:^(float progress) {
            [VCProgressViewController requestProgressForProgress:ProgressModeFetch keyNotification:key progress:progress];
        }];
        self.requestConnection = requestConnection;
        SSLog(@"    URL [%@]", [requestConnection.urlRequest URL]);        
    }
}

// OLD
- (void) requestTimeLineNextCompletionBlock:(SSBlockError)completionBlock
{
    SS_MLOG(self);
    __weak VCTimeLineViewController * _self = self;    
    
    NSString* __graphPath = [self.stackModel.paging objectForKey:@"next"];
    if (__graphPath == nil) {
        NSDictionary* userInfo = @{};
        NSError* error = [NSError errorWithDomain:@"" code:0 userInfo:userInfo];
        if (completionBlock) completionBlock(error);
        return;
    }
    
    SSLog(@"GraphPath [%@]", __graphPath);
    NSString* until = [__graphPath stringMatchedByRegex:@"until=(\\d+)"];
                       
    if (until == nil) {
        if (completionBlock) completionBlock(nil);
        return;
    }
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:until forKey:@"until"];
    [params setValue:@"25" forKey:@"limit"];        
    [params setValue:@"1" forKey:@"value"];
    NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];    
    params[@"locale"] = locale;

    
    FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_self __debug:results];
            
            if (error == nil) {
                NSMutableArray* datas = [NSMutableArray arrayWithArray:_self.stackModel.datas];
                [datas addObjectsFromArray:[_self _datasFromResults:results]];
                _self.stackModel.datas = datas;            
                _self.stackModel.paging = results[@"paging"];
                _self.stackModel.isRequested = YES;                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) completionBlock(error);    
                if (error) {
                    NSString* key = NSStringFromClass([self class]); 
                    [VCProgressViewController requestErrorForProgress:ProgressModeFetch keyNotification:key error:error];
                } else {
                    NSString* key = NSStringFromClass([self class]);
                    [VCProgressViewController requestFinishForProgress:ProgressModeFetch keyNotification:key];
                }  
            });            
        });
    };
    
    NSString* graphPath = [self _createGraphPath];    
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];
    [requestConnection addRequest:request completionHandler:block];
    
    NSString* key = NSStringFromClass([self class]);
    [VCProgressViewController requestStartForProgress:ProgressModeFetch keyNotification:key];
    [requestConnection startWithBlockProgress:^(float progress) {
        [VCProgressViewController requestProgressForProgress:ProgressModeFetch keyNotification:key progress:progress];
    }];
    self.requestConnection = requestConnection;
    SSLog(@"    URL [%@]", [requestConnection.urlRequest URL]);        
}

// NEW
- (void) requestTimeLinePreviousCompletionBlock:(SSBlockError)completionBlock;
{
    SS_MLOG(self);    
    __weak VCTimeLineViewController * _self = self;    
    
    
    NSString* __graphPath = [self.stackModel.paging objectForKey:@"previous"];    
    SSLog(@"GraphPath [%@]", __graphPath);  
    NSString* since = [__graphPath stringMatchedByRegex:@"since=(\\d+)"];
    
    if (since == nil) {
        if (completionBlock) completionBlock(nil);
        return;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:since forKey:@"since"];
    [params setValue:@"25" forKey:@"limit"];    
    [params setValue:@"1" forKey:@"value"];        
    [params setValue:@"1" forKey:@"__previous"];
    NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];    
    params[@"locale"] = locale;   

    SSLog(@"paging pre %@", [self.stackModel.paging description]);
    
    FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{            
            [_self __debug:results];        
            if (error == nil) {
                 NSMutableArray* datas = [NSMutableArray arrayWithArray:[_self _datasFromResults:results]];
                 [datas addObjectsFromArray:_self.stackModel.datas];
                 _self.stackModel.datas = datas;
                _self.stackModel.paging = results[@"paging"];
                _self.stackModel.isRequested = YES;                
                SSLog(@"paging aft %@", [_self.stackModel.paging description]);            
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) completionBlock(error);       
                if (error) {
                    NSString* key = NSStringFromClass([self class]);
                    [VCProgressViewController requestErrorForProgress:ProgressModeFetch keyNotification:key error:error];
                } else {
                    NSString* key = NSStringFromClass([self class]);
                    [VCProgressViewController requestFinishForProgress:ProgressModeFetch keyNotification:key];
                }              
            });
        });
    };  
    
    NSString* graphPath = [self _createGraphPath];    
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];
    [requestConnection addRequest:request completionHandler:block];
    
    NSString* key = NSStringFromClass([self class]);
    [VCProgressViewController requestStartForProgress:ProgressModeFetch keyNotification:key];
    [requestConnection startWithBlockProgress:^(float progress) {
        [VCProgressViewController requestProgressForProgress:ProgressModeFetch keyNotification:key progress:progress];
    }];
    self.requestConnection = requestConnection;
    SSLog(@"    URL [%@]", [requestConnection.urlRequest URL]);        
}

/*
- (void) requestPhoto:(NSString*)graphPath completionBlock:(SSBlockError)completionBlock
{
    SS_MLOG(self); 
    __weak VCTimeLineViewController * _self = self;
    self.photoModels = [NSMutableArray array];
    
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];
    
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];    
        params[@"locale"] = locale;   
        
        FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [_self __debug:results];
                
                if (error == nil) {
                    MMPhotoModel* model = [[MMPhotoModel alloc] initWithData:results];
                    [_self.photoModels addObject:model];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock(error);      
                    if (error) {
                        NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
                        [VCProgressViewController requestErrorForProgress:ProgressModeFetch keyNotification:key error:error];
                    } else {
                        NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
                        [VCProgressViewController requestFinishForProgress:ProgressModeFetch keyNotification:key];
                    }
                });
            });
            
        };
        
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block];
    }
    
    NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
    [VCProgressViewController requestStartForProgress:ProgressModeFetch keyNotification:key];
    
    [requestConnection startWithBlockProgress:^(float progress) {
        [VCProgressViewController requestProgressForProgress:ProgressModeFetch keyNotification:key progress:progress];
    }];
    self.requestConnectionForPhoto = requestConnection;
    SSLog(@"    URL [%@]", [requestConnection.urlRequest URL]);
}

// objectID : albumID
- (void) requestAlbum:(NSString*)objectID completionBlock:(SSBlockError)completionBlock
{
    SS_MLOG(self);
    __weak VCTimeLineViewController * _self = self;
    
    // [self _requestStart];
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];
    
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        // OFF Locale / Page photo can't get with locale ... z
        // params[@"locale"] = locale;
        
        FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [_self __debug:results];
                
                if (error == nil) {
                    NSArray* datas = results[@"data"];
                    if (datas && datas.count) {
                        if (_self.photoModels == nil) {
                            _self.photoModels = [NSMutableArray array];
                        }
                        MMPhotoModel* modelOLD = nil;
                        if (_self.photoModels && _self.photoModels.count) {
                            modelOLD = _self.photoModels[0];
                        }
                        for (NSDictionary* data in datas) {
                            MMPhotoModel* model = [[MMPhotoModel alloc] initWithData:data];
                            if (modelOLD && [modelOLD[@"id"] isEqualToString:model[@"id"]]) continue;
                            [_self.photoModels addObject:model];
                        }                    
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock(error);
                    if (error) {
                        // [_self _requestError];
                    } else {
                        //[_self _requestFinish];
                    }
                });
            });
            
        };
        
        NSString* graphPath = [NSString stringWithFormat:@"%@/photos", objectID];
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block];
    }
    [requestConnection start];
    self.requestConnectionForAlbum = requestConnection;
    SSLog(@"    URL [%@]", [requestConnection.urlRequest URL]);
}
*/

/*
{
    data =     (
                {
                    category = "\U30e6\U30fc\U30c6\U30a3\U30ea\U30c6\U30a3";
                    "company_name" = Facebook;
                    description = "Keep up with friends, wherever you are.";
                    "display_name" = "Facebook for iPhone";
                    "icon_url" = "https://s-static.ak.facebook.com/rsrc.php/v2/ym/r/y-2LR9eyI1L.gif";
                    "logo_url" = "https://fbcdn-photos-a.akamaihd.net/photos-ak-snc7/v85006/195/6628568379/app_1_6628568379_830094696.gif";
                    "website_url" = "<null>";
                }
                );
}
*/

#pragma -
#pragma Helper

- (void) __debug:(id)results
{
    return;
#ifdef DEBUG
    NSError* error = nil;
    NSData* _data = [NSJSONSerialization dataWithJSONObject:results options:NSJSONWritingPrettyPrinted error:&error];
    NSString* json = [NSString stringWithDataAsUTF8:_data];
    
    SSLog(@"-JSON---------------------------------------------------");
    SSLog(json);
    SSLog(@"-JSON---------------------------------------------------");
#endif
}

- (NSArray*) _datasFromResults:(id)results
{
    SS_MLOG(self);
    NSMutableArray* datas = [NSMutableArray array];
    
    BM_START(PARSE_DATA);
    for (NSDictionary* data in [results objectForKey:@"data"]) {
        MMStatusModel* statusModel = [[MMStatusModel alloc] initWithData:data];
        [datas addObject:statusModel];
    }
    BM_END(PARSE_DATA);
    
    BM_START(CREATE_TEXT_COMPONENTS);
    for (MMStatusModel* statusModel in datas) {
        [statusModel createTextComponents];
    }
    BM_END(CREATE_TEXT_COMPONENTS);
    
    BM_START(PARSE_HEIGHT);
    for (MMStatusModel* statusModel in datas) {
        statusModel.height = [UUTimeLineCell heightFromData:statusModel];
    }
    BM_END(PARSE_HEIGHT);
    
    SSLog(@"FINISH PRE PARSE");
    return datas;
}


@end
