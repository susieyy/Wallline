//
//  MMUserModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/07/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MMFriendModel.h"


@interface MMFriendModel ()

@end

@implementation MMFriendModel

- (id) initWithData:(NSDictionary*)data
{
	self = [super initWithData:data ];
	if (self) {
        self.items = [NSMutableArray array];
        
        if (self.data[@"name"]) {
            NSString* name = NSLocalizedString(@"Name", @"");
            NSString* detail = self.data[@"name"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        if (self.data[@"work"] && [self.data[@"work"] count]) {
            NSDictionary* info = self.data[@"work"][0];
            NSString* name = NSLocalizedString(@"Work", @"");
            NSString* detail = info[@"employer"][@"name"];    // position
            if (info[@"position"]) {
                detail = [NSString stringWithFormat:@"%@ (%@)", detail, info[@"position"][@"name"]];
            }
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        if (self.data[@"education"]) {
            NSString* name = NSLocalizedString(@"Education", @"");            
            NSMutableArray* array = [NSMutableArray array];
            for (NSDictionary* info in self.data[@"education"]) {
                NSString* _detail = info[@"school"][@"name"];
                [array addObject:_detail];
            }
            if (array.count) {
                NSString* detail = [array join:@" / "];
                [self.items addObject:@{@"name":name, @"detail":detail}];
            }
        }
        if (self.data[@"hometown"]) {
            NSString* name = NSLocalizedString(@"Hometown", @"");
            NSString* detail = self.data[@"hometown"][@"name"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        if (self.data[@"birthday"]) {
            NSString* name = NSLocalizedString(@"Birthday", @"");
            NSString* detail = self.data[@"birthday"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        if (self.data[@"bio"]) {
            NSString* name = NSLocalizedString(@"Bio", @"");
            NSString* detail = [self.data[@"bio"] stringAsHREFWithRegex];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    self.isFriend = [coder decodeBoolForKey:@"isFriend"];
    self.isSubscribedto = [coder decodeBoolForKey:@"isSubscribedto"];    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeBool:self.isFriend forKey:@"isFriend"];
    [coder encodeBool:self.isSubscribedto forKey:@"isSubscribedto"];
}

@end

/*
{
    bio = "Love Snowboarding.";
    birthday = "11/11/1975";
    cover =     {
        id = 281373191954921;
        "offset_y" = 39;
        source = "https://fbcdn-sphotos-d-a.akamaihd.net/hphotos-ak-prn1/s720x720/530442_281373191954921_187102252_n.jpg";
    };
    education =     (
                     {
                         school =             {
                             id = 110687758951273;
                             name = "\U56fd\U5b66\U9662\U5927\U5b66\U4e45\U6211\U5c71\U9ad8\U7b49\U5b66\U6821";
                         };
                         type = "High School";
                         year =             {
                             id = 135676686463386;
                             name = 1994;
                         };
                     },
                     {
                         school =             {
                             id = 105909459449949;
                             name = "\U5927\U962a\U5927\U5b66";
                         };
                         type = College;
                         year =             {
                             id = 144503378895008;
                             name = 1999;
                         };
                     }
                     );
    hometown =     {
        id = 115875015094123;
        name = "\U5175\U5eab\U770c\U5c3c\U5d0e\U5e02";
    };
    id = 100002467271954;
    name = "\U4e2d\U6751 \U5321\U4e00";
    work =     (
                {
                    employer =             {
                        id = 143636929002889;
                        name = "\U65e5\U672c\U96fb\U6c17";
                    };
                    "start_date" = "0000-00";
                },
                {
                    employer =             {
                        id = 103092013064210;
                        name = "\U65e5\U672c\U96fb\U6c17";
                    };
                    "start_date" = "0000-00";
                }
                );
}
*/