//
//  MMStackModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/07/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MMStackModel.h"

@implementation MMStackModel

- (id) init
{
	self = [super init];
	if (self) {
		self.UUID = [NSString stringWithUUID];
        self.datas = [NSMutableArray array];
        self.isRequested = NO;

        {
            NSString* key = @"FontSizeForTimeLine";
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            NSUInteger fontSize = [userDefaults integerForKey:key];
            self.fontSize = fontSize;
        }
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        self.UUID = [coder decodeObjectForKey:@"UUID"];
        self.isRequested = [coder decodeBoolForKey:@"isRequested"];
        self.tableOffset = [coder decodeFloatForKey:@"tableOffset"];      
        self.objectType = [coder decodeObjectForKey:@"objectType"];
        
        self.ID = [coder decodeObjectForKey:@"ID"];
        self.datas = [coder decodeObjectForKey:@"datas"];
        self.paging = [coder decodeObjectForKey:@"paging"];
        self.fontSize = [coder decodeIntegerForKey:@"fontSize"];
        
        // option
        self.friendModel = [coder decodeObjectForKey:@"friendModel"];
        self.eventModel = [coder decodeObjectForKey:@"eventModel"];
        self.pageModel = [coder decodeObjectForKey:@"pageModel"];
        self.groupModel = [coder decodeObjectForKey:@"groupModel"];
        self.applicationModel = [coder decodeObjectForKey:@"applicationModel"];
    }
    return self;
}

- (NSString*) description
{
    NSMutableString* sb = [NSMutableString string];
    [sb appendFormat:@"%@ ", [super description]];
    [sb appendFormat:@"UU [%@] ", self.UUID];
    [sb appendFormat:@"OT [%@] ", self.objectType];
    [sb appendFormat:@"ID [%@] ", self.ID];
    return sb;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.UUID forKey:@"UUID"];
    [coder encodeBool:self.isRequested forKey:@"isRequested"];
    [coder encodeFloat:self.tableOffset forKey:@"tableOffset"];
    [coder encodeInteger:self.fontSize forKey:@"fontSize"];
    
    if (self.objectType) {
        [coder encodeObject:self.objectType forKey:@"objectType"];            
    }
    if (self.ID) {
        [coder encodeObject:self.ID forKey:@"ID"];    
    }
    if (self.datas) {
        [coder encodeObject:self.datas forKey:@"datas"];
    }
    if (self.paging) {
        [coder encodeObject:self.paging forKey:@"paging"];        
    }

    // option
    if (self.friendModel) {
        [coder encodeObject:self.friendModel forKey:@"friendModel"];
    }
    if (self.eventModel) {
        [coder encodeObject:self.eventModel forKey:@"eventModel"];
    }
    if (self.pageModel) {
        [coder encodeObject:self.pageModel forKey:@"pageModel"];
    }
    if (self.groupModel) {
        [coder encodeObject:self.groupModel forKey:@"groupModel"];
    }
    if (self.applicationModel) {
        [coder encodeObject:self.applicationModel forKey:@"applicationModel"];
    }
}

#pragma -
#pragma Model

- (void) setFriendModel:(MMFriendModel *)friendModel
{
    if (friendModel == nil) return;
    _friendModel = friendModel;
    self.ID = friendModel[@"id"]; 
    self.objectType = @"friend";
}

- (void) setPageModel:(MMPageModel *)pageModel
{
    if (pageModel == nil) return;    
    _pageModel = pageModel;
    self.ID = pageModel[@"id"];     
    self.objectType = @"page";
}

- (void) setGroupModel:(MMGroupModel *)groupModel
{
    if (groupModel == nil) return;
    _groupModel = groupModel;
    self.ID = groupModel[@"id"];
    self.objectType = @"group";
}

- (void) setEventModel:(MMEventModel *)eventModel
{
    if (eventModel == nil) return;
    _eventModel = eventModel;
    self.objectType = @"event";
}

- (void) setApplicationModel:(MMApplicationModel *)applicationModel
{
    if (applicationModel == nil) return;
    _applicationModel = applicationModel;
    self.objectType = @"application";
}

- (void) setPlaceModel:(MMPlaceModel *)placeModel
{
    if (placeModel == nil) return;
    _placeModel = placeModel;
    self.objectType = @"place";
}

- (MMAbstModel*) model
{
    MMAbstModel* model = nil;
    if (self.timeLineType == VCTimeLineTypeEvent) {
        model = self.eventModel;
        
    } else if (self.timeLineType == VCTimeLineTypePage) {
        model = self.pageModel;
        
    } else if (self.timeLineType == VCTimeLineTypeFriend) {
        model = self.friendModel;

    } else if (self.timeLineType == VCTimeLineTypeGroup) {
        model = self.groupModel;

    } else if (self.timeLineType == VCTimeLineTypeEvent) {
        model = self.eventModel;
        
    } else if (self.timeLineType == VCTimeLineTypeApplication) {
        model = self.applicationModel;
        
    } else if (self.timeLineType == VCTimeLineTypePlace) {
        model = self.placeModel;

    } else if (self.timeLineType == VCTimeLineTypeStream) {
        if (self.datas.count) model = self.datas[0];
    }
    return model;
}

#pragma -
#pragma

// status / friend / event / page
- (void) setObjectType:(NSString*)objectType ID:(NSString *)ID SUBID:(NSString*)SUBID;
{
    self.ID = ID;
    self.SUBID = SUBID;
    self.objectType = objectType;
}



#pragma -
#pragma Arvhive / Unarchve

- (void) archive
{
    SSLog(@"    STACK ARCHIVE %@", [self description]);
    NSString* fileName = [NSString stringWithFormat:@"%@.dat", self.UUID];
    NSString* path = [[[UIApplication pathForDocuments] stringByAppendingPathComponent:@"stacks"] stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:self toFile:path];
}

+ (MMStackModel*) unarchive:(NSString*)UUID;
{    
    NSString* fileName = [NSString stringWithFormat:@"%@.dat", UUID];
    NSString* path = [[[UIApplication pathForDocuments] stringByAppendingPathComponent:@"stacks"] stringByAppendingPathComponent:fileName];
    MMStackModel* stackModel = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    SSLog(@"    STACK UNARCHIVE %@", [stackModel description]);
    return stackModel;
}


#pragma -
#pragma

- (BOOL) isIDAsAlias
{
    return ![self.ID matchesPatternRegexPattern:@"[\\d]+"];
}

#pragma -
#pragma

- (NSString*) title
{
    NSString* title = nil;
    
    if (self.timeLineType  == VCTimeLineTypeNews) {
        title = @"Wallline";
        
    } else if (self.timeLineType  == VCTimeLineTypeFriend) {
        NSString* text = [[MMNameManager sharedManager] objectForKey:self.ID];
        title = text;
        
    } else if (self.timeLineType  == VCTimeLineTypeEvent) {
        title = self.eventModel[@"name"];

    } else if (self.timeLineType  == VCTimeLineTypePage) {
        title = self.pageModel[@"name"];

    } else if (self.timeLineType  == VCTimeLineTypeApplication) {
        title = self.applicationModel[@"name"];

    } else if (self.timeLineType  == VCTimeLineTypeFriendOrPage) {
        title = NSLocalizedString(@"Page", @"");

    } else if (self.timeLineType  == VCTimeLineTypeStream) {
        if (self.datas.count) {
            NSString* name = self.datas[0][@"from"][@"name"];
            if (name) {
                title = [NSString stringWithFormat:@"%@%@", name, NSLocalizedString(@"'s stream", @"")];
            }
        }
    }
    
    if (title == nil) {
        title = NSLocalizedString([self.objectType stringAsCapitalizedFirstLetter], @"");
    }
    return title;
}

- (NSURL*) URLCoverImage
{
    NSString* url = nil;
    
    if (self.timeLineType  == VCTimeLineTypeFriend) {
        url = self.friendModel[@"cover"][@"source"];
        if (url == nil) {
            // Profile Image
            url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", self.ID];
        } else {
            // Cever Image
            url = [url stringByReplacingRegexPattern:@"s720x720" withString:@"s480x480"];
        }
    }
    if (self.timeLineType  == VCTimeLineTypeEvent || 
        self.timeLineType  == VCTimeLineTypePage ||
        self.timeLineType  == VCTimeLineTypeStream) {
        
        MMAbstModel* model = [self model];
        // url
        {
            // Cever Image
            url = [model[@"cover"][@"source"] stringByReplacingRegexPattern:@"s720x720" withString:@"s480x480"];

            if (url == nil) {
                // Picture Image
                url = [model[@"picture"] stringByReplacingRegexPattern:@"[qs].jpg" withString:@"n.jpg"];
            }
            if (url == nil) {
                // Photo Image
                url = [model[@"_photo"] stringByReplacingRegexPattern:@"[qs].jpg" withString:@"n.jpg"];
            }
            if (url == nil) {
                // Picture Image
                url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", self.ID];
            }       
        }
    }
    if (self.timeLineType  == VCTimeLineTypeApplication) {
        url = self.applicationModel[@"logo_url"];
    }
    
    if (url == nil) {
        // No Image ... 
        return nil;
    }
    
    NSURL* URL = [NSURL URLWithString:url];
    return URL;
}

- (NSURL*) URLForFacebookApp
{
    if (self.timeLineType  == VCTimeLineTypeUnknow) {
        SSLog(@"URL ObjectType Unknow");
        return nil;
    }
    /*
    if (self.timeLineType  == VCTimeLineTypePage) {
        url = [NSString stringWithFormat:@"fb://%@/", objectType, self.ID];
    }
    */ 
    
    NSString* objectType = self.objectType;    
    NSString* url = @"fb://feed";
    if (self.ID) {
        NSString* ID = self.ID;
        BOOL isIDOnlyNumber = [ID matchesPatternRegexPattern:@"^[0-9]+$"];
        if (self.timeLineType  == VCTimeLineTypeFriend) {
            objectType = @"profile";
        }
        if (self.timeLineType  == VCTimeLineTypePage && isIDOnlyNumber == NO && self.pageModel) {
            ID = self.pageModel[@"id"];
        }        
        url = [NSString stringWithFormat:@"fb://%@/%@", objectType, ID];
    }
    SSLog(@"URL %@", url);
    NSURL* URL = [NSURL URLWithString:url];
    return URL;
   
}

- (VCTimeLineType) timeLineType;
{
    if (self.objectType == nil || [self.objectType isEqualToString:@"news"]) {
        return VCTimeLineTypeNews;
        
    } else if ([self.objectType isEqualToString:@"friend"]) {
        return VCTimeLineTypeFriend;
        
    } else if ([self.objectType isEqualToString:@"event"]) {
        return VCTimeLineTypeEvent;
        
    } else if ([self.objectType isEqualToString:@"page"]) {
        return VCTimeLineTypePage;
        
    } else if ([self.objectType isEqualToString:@"stream"]) {
        return VCTimeLineTypeStream;

    } else if ([self.objectType isEqualToString:@"group"]) {
        return VCTimeLineTypeGroup;

    } else if ([self.objectType isEqualToString:@"friend_or_page"]) {
        return VCTimeLineTypeFriendOrPage;

    } else if ([self.objectType isEqualToString:@"application"]) {
        return VCTimeLineTypeApplication;

    } else if ([self.objectType isEqualToString:@"place"]) {
        return VCTimeLineTypePlace;

    }
    return VCTimeLineTypeUnknow;
    
}

@end
