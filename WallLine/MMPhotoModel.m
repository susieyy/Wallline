//
//  MMPhotoModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/21.
//
//

#import "MMPhotoModel.h"

@implementation MMPhotoModel

- (id) initWithData:(NSDictionary*)data
{
	self = [super initWithData:data];
	if (self) {
        ///////////////////////////////////////////////////////////////////////////////
        // isLiked
        {
            BOOL isLiked = [self isLikedAlready];
            if (isLiked) [self setLiked:isLiked];
        }    
	}
	return self;
}

- (NSString*) albumID
{
    NSString* link = self.data[@"link"];
    NSString* albumID = [link stringMatchedByRegex:@"set=a.(\\d+)"];
    return albumID;
}

#pragma -
#pragma Count ( Like / Comment )

- (NSUInteger) countForLike
{
    NSUInteger count = 0;
    NSString* v = self.data[@"likes"][@"count"];
    if (v) {
        count = [v integerValue];
    } else if (self.data[@"likes"][@"data"]) {
        NSArray* likes = self.data[@"likes"][@"data"];
        count = likes.count;
    }
    return count;
}

- (NSUInteger) countForComment
{
    NSUInteger count = 0;
    NSString* v = self.data[@"comments"][@"count"];
    if (v) {
        count = [v integerValue];
    } else if (self.data[@"comments"][@"data"]) {
        NSArray* comments = self.data[@"comments"][@"data"];
        count = comments.count;
    }
    return count;
}

#pragma -
#pragma Like

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

#pragma -
#pragma Comment

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

@end

/*
{
    "created_time" = "2012-08-21T07:14:18+0000";
    from =     {
        id = 1255098449;
        name = "\U8218 \U5eb7\U4e8c";
    };
    height = 537;
    icon = "https://s-static.ak.facebook.com/rsrc.php/v2/yz/r/StEh3RhPvjk.gif";
    id = 4470997053767;
    images =     (
                  {
                      height = 1527;
                      source = "https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-snc6/s2048x2048/224617_4470997053767_1295262407_n.jpg";
                      width = 2048;
                  },
                  {
                      height = 717;
                      source = "https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-snc6/224617_4470997053767_1295262407_n.jpg";
                      width = 960;
                  },
                  {
                      height = 537;
                      source = "https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-snc6/s720x720/224617_4470997053767_1295262407_n.jpg";
                      width = 720;
                  },
                  {
                      height = 358;
                      source = "https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-snc6/s480x480/224617_4470997053767_1295262407_n.jpg";
                      width = 480;
                  },
                  {
                      height = 238;
                      source = "https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-snc6/s320x320/224617_4470997053767_1295262407_n.jpg";
                      width = 320;
                  },
                  {
                      height = 134;
                      source = "https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/224617_4470997053767_1295262407_a.jpg";
                      width = 180;
                  },
                  {
                      height = 97;
                      source = "https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/224617_4470997053767_1295262407_s.jpg";
                      width = 130;
                  },
                  {
                      height = 97;
                      source = "https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/s75x225/224617_4470997053767_1295262407_s.jpg";
                      width = 130;
                  }
                  );
    likes =     {
        data =         (
                        {
                            id = 100001459028573;
                            name = "\U677e\U672c \U82f1\U63ee";
                        },
                        {
                            id = 100002594747069;
                            name = "\U5b89\U6589 \U7f8e\U9999";
                        },
                        {
                            id = 100001229686657;
                            name = "\U9234\U6728 \U88d5\U4e00";
                        },
                        {
                            id = 100002563887373;
                            name = "\U6df1\U6fa4 \U62d3\U90ce";
                        }
                        );
        paging =         {
            next = "https://graph.facebook.com/4470997053767/likes?access_token=BAAGPdtWcoUIBAOIZBXYc4e7NWAimsABj3DqDIIUp0SqHsZCeLVY4mEYlumCcG3Ca3gWcmqGqDEMMrJppJwWS5J4ABu9tdvkyITVL6cmiHTZAyilw050YUHetpZBtEm8ZD&limit=25&offset=25&__after_id=100002563887373";
        };
    };
    link = "https://www.facebook.com/photo.php?fbid=4470997053767&set=a.2317819465673.2139043.1255098449&type=1";
    name = "\U5348\U524d\U4e2d\U306f\U30cf\U30ce\U30a4\U521d\U8857\U6b69\U304d\U3001\U5ac1\U3055\U3093\U624b\U4f5c\U308a\U5c0f\U7269\U306b\U72c2\U559c\U3057\U5927\U91cf\U4ed5\U5165\U308c\U3002\n\U5348\U5f8c\U306b\U306a\U3063\U3066\U30b9\U30b3\U30fc\U30eb\U306e\U3088\U3046\U306a\U96e8\U3001\U30db\U30c6\U30eb\U3067\U4f11\U61a9 with \U30d5\U30ec\U30c3\U30b7\U30e5\U30b8\U30e5\U30fc\U30b9\U3002";
    picture = "https://fbcdn-photos-a.akamaihd.net/hphotos-ak-snc6/224617_4470997053767_1295262407_s.jpg";
    place =     {
        id = 188643411161870;
        location =         {
            city = "Ha Noi";
            country = Vietnam;
            latitude = "21.024296924764";
            longitude = "105.84823843289";
        };
        name = "Melia Hanoi Hotel";
    };
    position = 1;
    source = "https://fbcdn-sphotos-c-a.akamaihd.net/hphotos-ak-snc6/s720x720/224617_4470997053767_1295262407_n.jpg";
    "updated_time" = "2012-08-21T07:17:41+0000";
    width = 720;
}
*/