//
//  MMDataModel.h
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMAbstModel.h"

/*
 11 - Group created
 12 - Event created
 46 - Status update
 56 - Post on wall from another user
 66 - Note created
 80 - Link posted
 128 - Video posted
 247 - Photos posted
 237 - App story
 257 - Comment created
 272 - App story
 285 - Checkin to a place
 308 - Post in Group
*/




typedef enum {
    MMDataTypeStatus = 0,    
    MMDataTypeLink = 2,
    MMDataTypeCheckin = 3,        
    MMDataTypePhoto = 4,
    MMDataTypeVideo = 5,    
    MMDataTypeMusic = 6,        
    MMDataTypeOffer = 7,
    MMDataTypeQuestion = 8,    
    MMDataTypeUnknown = 99
} MMDataType;

@interface MMStatusModel : MMAbstModel
@property (strong, nonatomic) NSMutableDictionary* textComponents; // PRE PARSE
@property (nonatomic) CGFloat height;

// No Archive
@property (nonatomic) BOOL isNeedCellUpdate;
@property (nonatomic) BOOL isStatusMode;


- (void) createTextComponents;
- (MMDataType) type;

// Count 
- (NSUInteger) countForLike;
- (NSUInteger) countForComment;

//
- (NSString*) userName;
- (NSString*) linkNameAndCaption;
- (NSString*) messageAndStoryAndPlace;
- (NSString*) ueersForLike;

// Comment
- (NSString*) ueersForComment;
- (void) addComment:(NSString*)comment;

// Actions
- (NSString*) URLForActionLike;
- (NSString*) URLForActionComment;
- (NSString*) URLForActionEvent;
- (NSString*) URLForActionTwitter;

// Tags
- (NSString*) tagsForPhoto;

- (BOOL) hasLinkSection;

// Photo Size For Cell Height
- (void) setSizeForPhoto:(CGSize)size;

//  Like
- (void) setLiked:(BOOL)isLiked;
- (BOOL) isLiked;

+ (BOOL) isNeedHTTPRequest:(NSString*)url;

- (NSString*) URLPathForPicture;

@end
