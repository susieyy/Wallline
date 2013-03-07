//
//  MMNotificationModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/10.
//
//

#import "MMNotificationModel.h"

@implementation MMNotificationModel

- (id) initWithData:(NSDictionary*)data
{
	self = [super initWithData:data];
	if (self) {
        ///////////////////////////////////////////////////////////////////////////////
        // Date
        {
            NSString* key = @"updated_time";
            id obj = self.data[key];
            if (obj) {
                if ([obj isKindOfClass:[NSString class]]) {
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    //2010-12-01T21:35:43+0000
                    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
                    
                    NSString* updated = obj;
                    NSDate* date = [df dateFromString:updated];
                    if (date) {
                        self.data[key] = date;
                    }
                } else if ([obj isKindOfClass:[NSNumber class]]) {
                    NSNumber* n = obj;
                    NSUInteger updated = [n integerValue];
                    NSDate* date = [NSDate dateWithTimeIntervalSince1970:updated];
                    if (date) {
                        self.data[key] = date;
                    }
                }
            }
        }
        ///////////////////////////////////////////////////////////////////////////////
        // Title
        {
            NSString* title = self.data[@"title"];
            {
                NSString* name = self.data[@"from"][@"name"];
                NSString* r = [NSString stringWithFormat:@"<a href=''>%@</a>", name];
                title = [title stringByReplacingRegexPattern:name withString:r];
            }
            self.data[@"title"] = title;
        }
    }
    return self;
}

- (NSString*) ID;
{
    return self.data[@"application"][@"id"];
}

- (MMNotificationType) type;
{
    return MMNotificationTypeEvent;
    
}


- (NSString*) senderID;
{
    return self.data[@"from"][@"id"];
}

- (BOOL) isUnread
{
    NSUInteger isUnread = [self.data[@"is_unread"] integerValue];
    if (isUnread == 1) return YES;
    return NO;
}


@end

/*
{
    data =     (
                {
                    application =             {
                        id = 2361831622;
                        name = "\U30b0\U30eb\U30fc\U30d7";
                    };
                    "created_time" = "2012-08-09T18:02:33+0000";
                    from =             {
                        id = 100002115327343;
                        name = "\U30de\U30b9\U30c0 \U30bf\U30ab\U30b7";
                    };
                    id = "notif_100001720883274_17209935";
                    link = "http://www.facebook.com/groups/ikuful/415086981861459/?comment_id=415124895191001";
                    title = "\U30de\U30b9\U30c0 \U30bf\U30ab\U30b7\U3055\U3093\U3082\U3044\U304f\U3075\U308b\U306e\U5199\U771f\U306b\U30b3\U30e1\U30f3\U30c8\U3057\U307e\U3057\U305f\U3002: \U300c\U68ee\U7530\U304f\U3093\U306e\U9593\U9055\U3044\U3067\U3057\U305f\Uff01w\U300d";
                    to =             {
                        id = 100001720883274;
                        name = "\U6749\U4e0a \U6d0b\U5e73";
                    };
                    unread = 0;
                    "updated_time" = "2012-08-09T18:02:33+0000";
                },
                {
                    application =             {
                        id = 2361831622;
                        name = "\U30b0\U30eb\U30fc\U30d7";
                    };
                    "created_time" = "2012-08-09T16:18:25+0000";
                    from =             {
                        id = 100002115327343;
                        name = "\U30de\U30b9\U30c0 \U30bf\U30ab\U30b7";
                    };
                    id = "notif_100001720883274_17206395";
                    link = "http://www.facebook.com/groups/ikuful/415086981861459/";
                    title = "\U30de\U30b9\U30c0 \U30bf\U30ab\U30b7\U3055\U3093\U304c\U3044\U304f\U3075\U308b\U306b\U6295\U7a3f\U3057\U307e\U3057\U305f: \U300cSMAP\U306b\U68ee\U304f\U3093\U304c\U5e30\U3063\U3066\U304d\U307e\U3057\U305f\Uff01\Uff01\Uff01\Uff01\Uff01\Uff01\Uff01\U300d";
                    to =             {
                        id = 100001720883274;
                        name = "\U6749\U4e0a \U6d0b\U5e73";
                    };
                    unread = 0;
                    "updated_time" = "2012-08-09T16:18:25+0000";
                },
                {
                    application =             {
                        id = 302324425790;
                        name = "\U30b9\U30dd\U30c3\U30c8";
                    };
                    "created_time" = "2012-08-04T11:31:19+0000";
                    from =             {
                        id = 100001892517801;
                        name = "\U6749\U4e0a \U4f51\U5b50";
                    };
                    id = "notif_100001720883274_16992959";
                    link = "http://www.facebook.com/yuko.sugigami/posts/366539556752458";
                    message = "\U30c0\U30fc\U30af\U30ca\U30a4\U30c8\U898b\U3066\U304d\U305f\U3002\U524d\U4f5c\U3082\U9762\U767d\U304b\U3063\U305f\U3051\U3069\U3001\U4eca\U4f5c\U3082\U9762\U767d\U304b\U3063\U305f\U3002\n\U305d\U3057\U3066\U3001\U30a4\U30f3\U30bb\U30d7\U30b7\U30e7\U30f3\U306e\U6642\U304b\U3089\U5bc6\U304b\U306b\U304b\U3063\U3053\U3044\U3044\U3068\U601d\U3063\U3066\U3044\U305f\U3001\U30b8\U30e7\U30bb\U30d5\U2022\U30b4\U30fc\U30c9\U30f3\Uff1d\U30ec\U30f4\U30a3\U30c3\U30c8\U304c\U3067\U3066\U305f\Uff01";
                    title = "\U6749\U4e0a \U4f51\U5b50\U3055\U3093\U304c\U81ea\U5206\U306e\U30e9\U30be\U30fc\U30ca\U5ddd\U5d0e\U30d7\U30e9\U30b6 (Lazona Kawasaki Plaza)\U3078\U306e\U30c1\U30a7\U30c3\U30af\U30a4\U30f3\U306b\U3064\U3044\U3066\U30b3\U30e1\U30f3\U30c8\U3057\U307e\U3057\U305f: \U300c\U30c0\U30fc\U30af\U30ca\U30a4\U30c8\U898b\U3066\U304d\U305f\U3002\U524d\U4f5c\U3082\U9762\U767d\U304b\U3063\U305f\U3051\U3069\U3001\U4eca\U4f5c\U3082\U9762\U767d\U304b\U3063\U305f\U3002..\U300d";
                    to =             {
                        id = 100001720883274;
                        name = "\U6749\U4e0a \U6d0b\U5e73";
                    };
                    unread = 0;
                    "updated_time" = "2012-08-04T11:31:19+0000";
                },
                {
                    application =             {
                        id = 302324425790;
                        name = "\U30b9\U30dd\U30c3\U30c8";
                    };
                    "created_time" = "2012-08-04T06:08:30+0000";
                    from =             {
                        id = 100001892517801;
                        name = "\U6749\U4e0a \U4f51\U5b50";
                    };
                    id = "notif_100001720883274_16985992";
                    link = "http://www.facebook.com/profile.php?sk=approve&highlight=366539556752458&queue_type=friends";
                    title = "\U6749\U4e0a \U4f51\U5b50\U3055\U3093\U304c\U30e9\U30be\U30fc\U30ca\U5ddd\U5d0e\U30d7\U30e9\U30b6 (Lazona Kawasaki Plaza)\U306b\U3042\U306a\U305f\U3092\U30bf\U30b0\U4ed8\U3051\U3057\U307e\U3057\U305f\U3002\U627f\U8a8d\U3057\U3066\U30bf\U30a4\U30e0\U30e9\U30a4\U30f3\U306b\U63b2\U8f09\U3059\U308b\U306b\U306f\U3001\U30bf\U30a4\U30e0\U30e9\U30a4\U30f3\U63b2\U8f09\U306e\U78ba\U8a8d\U3078\U79fb\U52d5\U3057\U3066\U304f\U3060\U3055\U3044\U3002";
                    to =             {
                        id = 100001720883274;
                        name = "\U6749\U4e0a \U6d0b\U5e73";
                    };
                    unread = 0;
                    "updated_time" = "2012-08-04T06:08:30+0000";
                }
                );
    paging =     {
        next = "https://graph.facebook.com/100001720883274/notifications?format=json&include_read=1&locale=ja_JP&access_token=BAAGPdtWcoUIBAOIZBXYc4e7NWAimsABj3DqDIIUp0SqHsZCeLVY4mEYlumCcG3Ca3gWcmqGqDEMMrJppJwWS5J4ABu9tdvkyITVL6cmiHTZAyilw050YUHetpZBtEm8ZD&limit=5000&until=1344060510&__paging_token=notif_100001720883274_16985992";
        previous = "https://graph.facebook.com/100001720883274/notifications?format=json&include_read=1&locale=ja_JP&access_token=BAAGPdtWcoUIBAOIZBXYc4e7NWAimsABj3DqDIIUp0SqHsZCeLVY4mEYlumCcG3Ca3gWcmqGqDEMMrJppJwWS5J4ABu9tdvkyITVL6cmiHTZAyilw050YUHetpZBtEm8ZD&limit=5000&since=1344535353&__paging_token=notif_100001720883274_17209935&__previous=1";
    };
    summary =     (
    );
}
*/