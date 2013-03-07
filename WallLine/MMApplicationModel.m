//
//  MMApplicationModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/13.
//
//

#import "MMApplicationModel.h"

@implementation MMApplicationModel


- (id) initWithData:(NSDictionary*)data
{
	self = [super initWithData:data ];
	if (self) {
        self.items = [NSMutableArray array];

        if (self.data[@"category"]) {
            NSString* name = NSLocalizedString(@"Category", @"");
            NSString* detail = self.data[@"category"];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
        if (self.data[@"description"]) {
            NSString* name = NSLocalizedString(@"Description", @"");
            NSString* detail = [self.data[@"description"] stringAsHREFWithRegex];
            [self.items addObject:@{@"name":name, @"detail":detail}];
        }
    }
    return self;
}

@end

/*
{
    "id": "2439131959",
    "name": "Graffiti ",
    "description": "Draw for your friends.",
    "category": "Lifestyle",
    "subcategory": "Other",
    "link": "https://www.facebook.com/apps/application.php?id=2439131959",
    "namespace": "graffitiwall",
    "icon_url": "https://fbcdn-photos-a.akamaihd.net/photos-ak-snc7/v43/19/2439131959/app_2_2439131959_1091.gif",
    "logo_url": "https://fbcdn-photos-a.akamaihd.net/photos-ak-snc7/v27562/19/2439131959/app_1_2439131959_7209.gif",
    "daily_active_users": "6000",
    "weekly_active_users": "40000",
    "monthly_active_users": "140000"
}
*/
