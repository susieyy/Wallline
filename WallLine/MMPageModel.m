//
//  MMPageModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/05.
//
//

#import "MMPageModel.h"

@implementation MMPageModel

- (id) initWithData:(NSDictionary*)data
{
	self = [super initWithData:data ];
	if (self) {
        self.items = [NSMutableArray array];
        
        if (self.data[@"name"]) {
            NSString* name = NSLocalizedString(@"Name", @"");
            NSString* detail = [NSString stringWithFormat:@"%@ ( %@ %@ )", self.data[@"name"], self.data[@"likes"], NSLocalizedString(@"Likes", @"")];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        
        if (self.data[@"category"]) {
            NSString* name = NSLocalizedString(@"Category", @"");
            NSString* detail = self.data[@"category"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        
        if (self.data[@"website"]) {
            NSString* name = NSLocalizedString(@"Website", @"");
            NSString* detail = [self.data[@"website"] stringAsHREFWithRegex];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        
        if (self.data[@"username"]) {
            NSString* name = NSLocalizedString(@"UserName", @"");
            NSString* detail = self.data[@"username"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        
        if (self.data[@"company_overview"]) {
            NSString* name = NSLocalizedString(@"Company", @"");
            NSString* detail = self.data[@"company_overview"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        
        if (self.data[@"about"]) {
            NSString* name = NSLocalizedString(@"About", @"");
            NSString* detail = [self.data[@"about"] stringAsHREFWithRegex];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    self.isLiked = [coder decodeBoolForKey:@"isLiked"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeBool:self.isLiked forKey:@"isLiked"];
}

@end


/*
{
    "id": "298524363579358",
    "name": "\u30a4\u30e9\u30b9\u30c8\u30ec\u30fc\u30bf\u30fc \u732a\u539f\u7f8e\u4f73 News",
    "picture": "http://profile.ak.fbcdn.net/hprofile-ak-ash2/276401_298524363579358_436697356_s.jpg",
    "link": "https://www.facebook.com/inoharamika",
    "likes": 67,
    "category": "Artist",
    "is_published": true,
    "website": "http://www.sora-cs.com/inoko/",
    "username": "inoharamika",
    "about": "\u30a4\u30e9\u30b9\u30c8\u30ec\u30fc\u30bf\u30fc Illustrator",
    "location": {
        "city": "Kamakura-shi",
        "state": "Kanagawa",
        "country": "Japan"
    },
    "talking_about_count": 26
}
*/

/*
 {
 "id": "19292868552",
 "name": "Facebook Developers",
 "picture": "http://profile.ak.fbcdn.net/hprofile-ak-ash2/276791_19292868552_1958181823_s.jpg",
 "link": "https://www.facebook.com/FacebookDevelopers",
 "likes": 34599,
 "cover": {
 "cover_id": "10150835335278553",
 "source": "http://a6.sphotos.ak.fbcdn.net/hphotos-ak-ash3/s720x720/547890_10150835335278553_344659408_n.jpg",
 "offset_y": 32
 },
 "category": "Product/service",
 "is_published": true,
 "website": "http://developers.facebook.com",
 "username": "FacebookDevelopers",
 "company_overview": "Facebook Platform enables anyone to build social apps on Facebook, mobile, and the web.",
 "about": "Build and distribute amazing social apps on Facebook. https://developers.facebook.com/",
 "talking_about_count": 16601
 }
 */

