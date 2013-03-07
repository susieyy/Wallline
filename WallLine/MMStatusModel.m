//
//  MMDataModel.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "MMStatusModel.h"
#import "RTLabel.h"

// https://fbcdn-photos-a.akamaihd.net/hphotos-ak-ash4/487171_404930369554213_609001113_s.jpg
// https://fbcdn-sphotos-a.akamaihd.net/hphotos-ak-snc7/s480x480/427559_4305431873142_54862607_n.jpg


@implementation MMStatusModel

- (void) createTextComponents
{
    self.textComponents = [NSMutableDictionary dictionary];
    {
        NSString* key = @"_messageAndStoryAndPlace";
        NSString* text = [self messageAndStoryAndPlace];   
        if (text) {
            NSDictionary* d = [RTLabel preExtractTextStyle:text];
            [self.textComponents setValue:d forKey:key];
        }            
    }
    {
        NSString* key = @"_linkNameAndCaption";
        NSString* text = [self linkNameAndCaption];   
        if (text) {
            NSDictionary* d = [RTLabel preExtractTextStyle:text];
            [self.textComponents setValue:d forKey:key];
        }            
    }
    {
        NSString* key = @"description";
        NSString* text = [self.data objectForKey:key];   
        if (text) {
            NSDictionary* d = [RTLabel preExtractTextStyle:text];
            [self.textComponents setValue:d forKey:key];
        }            
    }
    {
        NSString* key = @"_descriptionAndLikeAndCommentAndApplication";
        NSString* text = [self.data objectForKey:key];
        if (text) {
            NSDictionary* d = [RTLabel preExtractTextStyle:text];
            [self.textComponents setValue:d forKey:key];
        }
    }
}

- (id) initWithData:(NSDictionary*)data
{
	self = [super initWithData:data];
	if (self) {  
        MMDataType type = [self type];

        @autoreleasepool {
            // HREF
            NSArray* keys = @[@"message", @"story", @"caption", @"description"];
            for (NSString* key in keys) { 
                NSString* value = self.data[key];
                if (value) {
                    NSString* valuenew = [value stringByReplacingRegexPattern:@"\r\n" withString:@"\n"];
                    self.data[key] = [valuenew stringAsHREFWithRegex];
                }
            }
            
            ///////////////////////////////////////////////////////////////////////////////
            // Description
            NSString* _description = self.data[@"description"];
            NSMutableString* description = [NSMutableString string];            
            if (_description) {
                [description appendString:_description];                
            }
            
            // User Like
            NSString* usersForLike = [self ueersForLike];
            if (usersForLike) {
                if (description.length) {
                    [description appendFormat:@"\n\n%@", usersForLike];
                } else {
                    [description appendString:usersForLike];
                }
            }
            
            // User Comment
            NSString* ueersForComment = [self ueersForComment];
            if (ueersForComment) {
                if (description.length) {
                    [description appendFormat:@"\n%@", ueersForComment];
                } else {
                    [description appendString:ueersForComment]; 
                }
            }
            
            // Application
            if (self.data[@"application"]) {                
                NSString* application = [NSString stringWithFormat:@"<b>&lt;%@&gt;</b> <a href='application://%@'>%@</a>", 
                                         NSLocalizedString(@"From", @""),
                                         self.data[@"application"][@"id"],
                                         self.data[@"application"][@"name"]];
                if (description.length) {
                    [description appendFormat:@"\n\n%@", application];
                } else {
                    [description appendString:application];                     
                }
            }
            self.data[@"_descriptionAndLikeAndCommentAndApplication"] = description;
            
            ///////////////////////////////////////////////////////////////////////////////
            // Type Photo picture to photo
            if (type == MMDataTypePhoto) {
                NSString* picture = self.data[@"picture"];
                picture = [picture stringByReplacingRegexPattern:@"[qs].jpg$" withString:@"n.jpg"];
                picture = [picture stringByReplacingRegexPattern:@"(hphotos-ak-[^/]+/)" withString:@"$1s480x480/"];
                
                self.data[@"_photo"] = picture;
                [self.data removeObjectForKey:@"picture"];
            }
            
            ///////////////////////////////////////////////////////////////////////////////
            // Pre prase RTLabel
            //[self _createTextComponents];
            
            ///////////////////////////////////////////////////////////////////////////////
            // Date            
            NSString* key = @"updated_time";
            NSDate* date = [self dateFromString:self.data[key]];
            if (date) {
                self.data[key] = date;
            }
            
            ///////////////////////////////////////////////////////////////////////////////            
            // User Name Cache
            [self userName];
                        
            ///////////////////////////////////////////////////////////////////////////////
            // isLiked 
            {
                BOOL isLiked = [self isLikedAlready];
                if (isLiked) [self setLiked:isLiked];
            }
            
        } // END
        
	}
	return self;
}

- (MMDataType) type;
{
    NSString* type = [self.data objectForKey:@"type"];
    if ([type isEqualToString:@"status"]) return MMDataTypeStatus;
    if ([type isEqualToString:@"link"]) return MMDataTypeLink;
    if ([type isEqualToString:@"photo"]) return MMDataTypePhoto;    
    if ([type isEqualToString:@"video"]) return MMDataTypeVideo;    
    if ([type isEqualToString:@"swf"]) return MMDataTypeVideo;    
    if ([type isEqualToString:@"checkin"]) return MMDataTypeCheckin;    
    if ([type isEqualToString:@"music"]) return MMDataTypeMusic;    
    if ([type isEqualToString:@"offer"]) return MMDataTypeOffer;    
    if ([type isEqualToString:@"question"]) return MMDataTypeQuestion;
    return MMDataTypeUnknown;
}

#pragma -
#pragma NSCoding

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        self.height = [coder decodeFloatForKey:@"height"];                        
        
        // self.textComponents = [coder decodeObjectForKey:@"textComponents"];        
        [self createTextComponents];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeFloat:self.height forKey:@"height"];
    
    //[coder encodeObject:self.textComponents forKey:@"textComponents"];    
}

#pragma -
#pragma Count ( Like / Comment )

- (NSUInteger) countForLike
{
    NSUInteger count = 0;
    NSString* v = self.data[@"likes"][@"count"];
    if (v) count = [v integerValue];
    return count;
}

- (NSUInteger) countForComment
{
    NSUInteger count = 0;
    NSString* v = self.data[@"comments"][@"count"];
    if (v) count = [v integerValue];
    return count;
}

#pragma -
#pragma Name

- (NSString*) userName
{
    NSString* key = @"_user_name";
    if (self.data[key]) return self.data[key];
    
    NSMutableString* s = [NSMutableString string];
#ifdef DEBUG
    [s appendFormat:@"[%@] ", [self.data[@"type"] substringToIndex:1]];
#endif

    // From
    [s appendFormat:@"<a href='friend://%@'>%@</a>", self.data[@"from"][@"id"], self.data[@"from"][@"name"]];
    [[MMNameManager sharedManager] setValue:self.data[@"from"][@"name"] forKey:self.data[@"from"][@"id"]];
    
    // To
    if (self.data[@"to"]) {
        NSArray* datas = self.data[@"to"][@"data"];        
        NSMutableArray* array = [NSMutableArray array];
        for (NSDictionary* data in datas) {
            NSString* text = [NSString stringWithFormat:@"<a href='friend://%@'>%@</a>", data[@"id"], data[@"name"]];
            [array addObject:text];
            [[MMNameManager sharedManager] setValue:data[@"name"] forKey:data[@"id"]];
        }
        if (array.count) {
            [s appendFormat:@" <b>＞</b> %@", [array join:@","]];
        }
    }
    
#ifdef DEBUG
    if ([self URLForActionEvent]) {
        [s appendFormat:@" [Event]"];
    }
    /*
     if ([statusModel URLForActionTwitter]) {
     [s appendFormat:@" [Twitter]"];
     }
     */
    if (self.data[@"shares"]) {
        [s appendFormat:@" [Shares %@]", self.data[@"shares"][@"count"]];
    }
    if (self.data[@"source"]) {
        [s appendFormat:@" [Source]%@", self.data[@"source"]];
    }
#endif
    
    self.data[key] = s;
    return s;
}

#pragma -
#pragma

- (NSString*) _effectTags:(NSString*)key
{
    NSString* target = self.data[key];
    if (target) {
        NSString* keytags = [NSString stringWithFormat:@"%@_tags", key];
        NSDictionary* tags = self.data[keytags];
        if (tags) {
            for (NSArray* _tag in tags.allValues) {
                if (_tag.count == 0) continue;
                NSDictionary* tag = [_tag objectAtIndex:0];
                NSString* type = @"facebook"; // default
                type = tag[@"type"];
                
                if ([type isEqualToString:@"user"]) {
                    type = @"friend"; // replace
                    [[MMNameManager sharedManager] setValue:tag[@"name"] forKey:tag[@"id"]];
                }
                
                NSString* r = [NSString stringWithFormat:@"<a href='%@://%@'>%@</a>",
                               type,
                               tag[@"id"],
                               tag[@"name"]
                               ];
                target = [target stringByReplacingOccurrencesOfString:tag[@"name"] withString:r];
                
            }
        }
    }
    return target;    
}

- (NSString*) messageAndStoryAndPlace;
{
    NSString* key = @"_messageAndStoryAndPlace";
    if (self.data[key]) return self.data[key];
    
    BOOL isAppend = NO;
    NSMutableString* s = [NSMutableString string];
    
    {
        isAppend = YES;
        [s appendFormat:@"%@　\n", [self userName]];
    }

    NSString* story = [self _effectTags:@"story"];
    if (story) {
        isAppend = YES;
        [s appendFormat:@"%@", story];
    }
    
    /*
    NSString* story = self.data[@"story"];
    if (story) {
        isAppend = YES;        
        NSDictionary* tags = self.data[@"story_tags"];
        if (tags) {
            for (NSArray* _tag in tags.allValues) {
                if (_tag.count == 0) continue;                
                NSDictionary* tag = [_tag objectAtIndex:0];
                NSString* type = @"facebook"; // default
                type = tag[@"type"];
                
                if ([type isEqualToString:@"user"]) {
                    type = @"friend"; // replace
                    [[MMNameManager sharedManager] setValue:tag[@"name"] forKey:tag[@"id"]];
                }
                
                NSString* r = [NSString stringWithFormat:@"<a href='%@://%@'>%@</a>", 
                               type,
                               tag[@"id"],
                               tag[@"name"]
                               ];
                story = [story stringByReplacingOccurrencesOfString:tag[@"name"] withString:r];
                
            }
        }
        [s appendFormat:@"%@", story];    
    }
    */
    
    if (self.data[@"message"] && self.data[@"story"]) {
        [s appendString:@"\n"];                
    }

    NSString* message = [self _effectTags:@"message"];
    if (message) {
        isAppend = YES;
        [s appendFormat:@"%@", message];
    }

    if (self.data[@"place"]) {
        isAppend = YES;        
        [s appendFormat:@" - %@: <a href='place://%@'>%@</a>",
         NSLocalizedString(@"Place", @""),
         self.data[@"place"][@"id"],
         self.data[@"place"][@"name"]];    
    }
    if (isAppend) {
        [self.data setValue:s forKey:key];
        return s;
    }
    return nil;
}

- (NSString*) linkNameAndCaption;
{
    NSString* key = @"_linkNameAndCaption";
    if (self.data[key]) return self.data[key];

    BOOL isAppend = NO;    
    NSMutableString* s = [NSMutableString string];
    if (self.data[@"name"]) {
        isAppend = YES;        
        [s appendFormat:@"<a href='%@'>%@</a>", self.data[@"link"], self.data[@"name"]];    
    }
    if (self.data[@"name"] && self.data[@"caption"]) {
        [s appendString:@" "];                
    }
    if (self.data[@"caption"]) {
        isAppend = YES;        
        [s appendFormat:@"<font color='#999999'>%@</font>", self.data[@"caption"]];    
    }
    if (isAppend) {
        [self.data setValue:s forKey:key];
        return s;
    }
    return nil;
}

- (BOOL) isLikedAlready
{
    NSString* ID = [[MMMeModel sharedManager] objectForKey:@"id"];
    if (ID == nil) return NO;
    
    NSArray* datas = self.data[@"likes"][@"data"];
    if (datas == nil || datas.count == 0) return NO;
    for (NSDictionary* data in datas) {
        if ([ID isEqualToString:data[@"id"]]) {
            return YES;
        }
    }
    return NO;
}

#pragma -
#pragma Like

- (NSString*) ueersForLike
{
    NSString* key = @"ueersForLike";
    if (self.data[key]) return self.data[key];

    NSArray* datas = self.data[@"likes"][@"data"];
    if (datas == nil || datas.count == 0) return nil;
        
    NSMutableArray* a = [NSMutableArray array];
    for (NSDictionary* data in datas) {
        [[MMNameManager sharedManager] setValue:data[@"name"] forKey:data[@"id"]];
        
        NSString* v = [NSString stringWithFormat:@"<a href='friend://%@'>%@</a>", data[@"id"], data[@"name"]];      
        [a addObject:v];
    }
    
    NSMutableString* s = [NSMutableString string];
    [s appendFormat:@"<b>&lt;%@&gt;</b> ", NSLocalizedString(@"Like", @"")];            
    [s appendString:[a join:@", "]];
    
    // and more ... 
    NSUInteger count = [self countForLike];
    if (count > a.count) {
        [s appendFormat:@" <b>%@</b>", NSLocalizedString(@"and more ...", @"")];
    }    
    
    [self.data setValue:s forKey:key];
    return s;
}

#pragma -
#pragma Comment

- (NSString*) ueersForComment
{
    NSString* key = @"ueersForComment";
    if (self.data[key]) return self.data[key];

    NSArray* datas = self.data[@"comments"][@"data"];
    if (datas == nil || datas.count == 0) return nil;
    
    NSMutableArray* a = [NSMutableArray array];
    for (NSDictionary* data in datas) {
        NSDictionary* from = data[@"from"];
        [[MMNameManager sharedManager] setValue:from[@"name"] forKey:from[@"id"]];
        
        NSString* msg = [data[@"message"] stringAsHREFWithRegex];
        NSString* v = [NSString stringWithFormat:@"<a href='friend://%@'>%@</a> %@", from[@"id"], from[@"name"], msg];
        [a addObject:v];
    }
    
    NSMutableString* s = [NSMutableString string];
    [s appendFormat:@"<b>&lt;%@&gt;</b>\n", NSLocalizedString(@"Comment", @"")];
    [s appendString:[a join:@"\n"]];
    
    // and more ... 
    NSUInteger count = [self countForComment];
    if (count > a.count) {
        [s appendFormat:@"\n<b>%@</b>", NSLocalizedString(@"and more ...", @"")];
    }
    
    [self.data setValue:s forKey:key];    
    return s;
}

- (void) addComment:(NSString*)comment
{
    SS_MLOG(self);
    if (self.data[@"comments"] == nil) self.data[@"comments"] = [NSMutableDictionary dictionary];
    if (self.data[@"comments"][@"data"] == nil) self.data[@"comments"][@"data"] = [NSMutableArray array];

    NSArray* _datas = self.data[@"comments"][@"data"];
    NSMutableArray* datas = [NSMutableArray arrayWithArray:_datas];
        
    MMMeModel* meModel = [MMMeModel sharedManager];
     
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    data[@"message"] = [comment stringAsHREFWithRegex];
    data[@"from"] = [NSMutableDictionary dictionary];
    data[@"from"][@"name"] = meModel[@"name"];
    data[@"from"][@"id"] = meModel[@"id"];
    
    [datas addObject:data];
    self.data[@"comments"][@"data"] = datas;
}

#pragma -
#pragma Actions

- (NSString*) URLForActionLike
{
    if (self.data[@"actions"] == nil) return nil;
    
    NSArray* array = self.data[@"actions"];
    for (NSDictionary* dict in array) {
        if (dict[@"name"] && [dict[@"name"] isEqualToString:@"Like"]) {
            return dict[@"link"];
        }
    }
    return nil;    
}

- (NSString*) URLForActionComment
{
    if (self.data[@"actions"] == nil) return nil;
    
    NSArray* array = self.data[@"actions"];     
    for (NSDictionary* dict in array) {
        if (dict[@"name"] && [dict[@"name"] isEqualToString:@"Comment"]) {
            return dict[@"link"];
        }
    }
    return nil;    
}

- (NSString*) URLForActionEvent
{
    if (self.data[@"actions"] == nil) return nil;
    
    NSArray* array = self.data[@"actions"];
    for (NSDictionary* dict in array) {
        if (dict[@"name"] && [dict[@"name"] isEqualToString:@"View"]) {
            return dict[@"link"];
        }
    }
    return nil;    
}

- (NSString*) URLForActionTwitter
{
    if ([self.data objectForKey:@"actions"] == nil) return nil;
    
    NSArray* array = [self.data objectForKey:@"actions"];     
    for (NSDictionary* dict in array) {
        if ([dict objectForKey:@"name"] && [[dict objectForKey:@"name"] hasSuffix:@"Twitter"]) {
            return [dict objectForKey:@"link"];
        }
    }
    return nil;    
}

#pragma -
#pragma Tags

- (NSString*) tagsForPhoto
{
    if ([self.data objectForKey:@"story_tags"] == nil) return nil;
    NSDictionary* dicts = [self.data objectForKey:@"story_tags"];
    if (dicts.count == 0) return nil;
    
    NSMutableString* s = [NSMutableString string]; 
    for (NSArray* _dict in [dicts allValues]) {
        NSDictionary* dict = [_dict objectAtIndex:0];
        //if ([[dict objectForKey:@"type"] isEqualToString:@"user"]) continue;
        [[MMNameManager sharedManager] setValue:[dict objectForKey:@"name"] forKey:[dict objectForKey:@"id"]];
        
        [s appendFormat:@"<a href='friend://%@'>%@</a>", [dict objectForKey:@"id"], [dict objectForKey:@"name"]];        
        [s setString:@" "];
    }
    return s;
}

#pragma -
#pragma 

- (BOOL) hasLinkSection;
{
    return !! (self.data[@"link"] &&
               (self.data[@"name"] != nil || self.data[@"caption"] != nil)
            );
}

- (void) setSizeForPhoto:(CGSize)size;
{
    NSValue* v = [NSValue valueWithCGSize:size];
    [self.data setValue:v forKey:@"_size_for_photo"];    
}

#pragma -
#pragma Like

- (void) setLiked:(BOOL)isLiked;
{
    self.data[@"_is_liked"] = [NSNumber numberWithBool:isLiked];
}

- (BOOL) isLiked;
{
    NSNumber* n = self.data[@"_is_liked"];
    if (n == nil) return NO;
    return [n boolValue];
}


// Alternatively, people and pages with usernames can be accessed using their username as an ID.
+ (BOOL) isNeedHTTPRequest:(NSString*)url
{
    if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/profile.php"]) {
        // Profile
        return YES;
    }
    if ([url matchesPatternRegexPattern:@"^https?://www.facebook.com/groups/[^\\d/]+"]) {
        return YES;
    }
    return NO;
}


- (NSString*) URLPathForPicture;
{
    MMDataType type = [self type];
    NSString* URLPath = nil;
    if (type == MMDataTypePhoto) {
        URLPath = self.data[@"_photo"];
    } else {
        URLPath = self.data[@"picture"];
    }
    return URLPath;
}

@end

/*
comments =     {
    count = 2;
    data =         (
                    {
                        "created_time" = "2012-08-15T11:02:31+0000";
                        from =                 {
                            id = 100001044288789;
                            name = "Yusuke Tsuzuki";
                        };
                        id = "178527348850758_417000218336802_417000695003421";
                        likes = 1;
                        message = "\U30a2\U30d6\U30ce\U30fc\U30de\U30eb\U30fb\U30a2\U30af\U30c6\U30a3\U30d3\U30c6\U30a3\U30fc";
                    },
                    {
                        "created_time" = "2012-08-15T11:04:46+0000";
                        from =                 {
                            id = 100002115327343;
                            name = "\U30de\U30b9\U30c0 \U30bf\U30ab\U30b7";
                        };
                        id = "178527348850758_417000218336802_417001058336718";
                        message = "\U30a2\U30d6\U30ce\U30fc\U30de\U30eb\U30a2\U30af\U30c6\U30a3\U30d3\U30c6\U30a3\U30fca.k.a. \U751f\U3051\U308b\U4eba\U9593\U79d8\U5b9d\Uff01\Uff01\Uff01";
                    }
                    );
};
*/