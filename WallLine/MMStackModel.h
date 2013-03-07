//
//  MMStackModel.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/07/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VCTimeLineTypeNews = 0,    
    VCTimeLineTypeFriend = 1,
    VCTimeLineTypeEvent = 2,
    VCTimeLineTypePage = 3,
    VCTimeLineTypeStream = 4,
    VCTimeLineTypeGroup = 5,
    VCTimeLineTypeApplication = 6,
    VCTimeLineTypePlace = 7,
    VCTimeLineTypeFriendOrPage = 99,
    VCTimeLineTypeUnknow = -1
} VCTimeLineType;

@interface MMStackModel : NSObject <NSCoding>

@property (copy, nonatomic) NSString* UUID;
@property (copy, nonatomic) NSString* ID;
@property (copy, nonatomic) NSString* SUBID;
@property (copy, nonatomic) NSString* objectType;
@property (strong, nonatomic) NSArray *datas;
@property (strong, nonatomic) NSDictionary *paging;
@property (nonatomic) CGFloat tableOffset;   
@property (nonatomic) BOOL isRequested;
@property (nonatomic) NSUInteger fontSize;
// option
@property (strong, nonatomic) MMFriendModel* friendModel;
@property (strong, nonatomic) MMPageModel* pageModel;
@property (strong, nonatomic) MMGroupModel* groupModel;
@property (strong, nonatomic) MMEventModel* eventModel;
@property (strong, nonatomic) MMApplicationModel* applicationModel;
@property (strong, nonatomic) MMPlaceModel* placeModel;

- (void) archive;
+ (MMStackModel*) unarchive:(NSString*)UUID;

- (MMAbstModel*) model;
- (BOOL) isIDAsAlias;
- (void) setObjectType:(NSString*)objectType ID:(NSString *)ID SUBID:(NSString*)SUBID;
- (NSString*) title;
- (NSURL*) URLCoverImage;
- (NSURL*) URLForFacebookApp;
- (VCTimeLineType) timeLineType;

@end
