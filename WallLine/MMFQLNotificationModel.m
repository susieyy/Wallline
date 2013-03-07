//
//  MMNotificationModel.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/07/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MMFQLNotificationModel.h"



@implementation MMFQLNotificationModel

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
                        [self.data setValue:date forKey:key];
                    }
                } else if ([obj isKindOfClass:[NSNumber class]]) {
                    NSNumber* n = obj;
                    NSUInteger updated = [n integerValue];
                    NSDate* date = [NSDate dateWithTimeIntervalSince1970:updated];
                    if (date) {
                        [self.data setValue:date forKey:key];
                    }
                }
                
            }
        }

        
        ///////////////////////////////////////////////////////////////////////////////
        // Title HTML
        {
            NSString* text = self.data[@"title_html"];
            if (text) {
                {
                    text = [text stringByReplacingRegexPattern:@"<a [^>]+>" withString:@"<font color='#5B75A4'><b>"];
                    text = [text stringByReplacingRegexPattern:@"</a>" withString:@"</b></font>"];     
                    
                    text = [text stringByReplacingRegexPattern:@"&quot;" withString:@"\""];
                    text = [text stringByReplacingRegexPattern:@"&amp;" withString:@"&"];
                    text = [text stringByReplacingRegexPattern:@"&lt;" withString:@"<"];
                    text = [text stringByReplacingRegexPattern:@"&gt;" withString:@">"];
                    text = [text stringByReplacingRegexPattern:@"&#039;" withString:@"'"];                            
                }
                
                NSString* _type = [self.data[@"object_type"] stringAsCapitalizedFirstLetter];
                NSString* type = NSLocalizedString(_type, @"");
                NSMutableString* s = [NSMutableString string];
                [s appendFormat:@"%@ ", text];
                [s appendFormat:@"<font color='#666666'>%@</font> ", [self.data[@"updated_time"] stringRelativeDate]];
                [s appendFormat:@"<font color='#666666'>[%@]</font>", type];
                [self.data setValue:s forKey:@"title_html"];
            }
        }

	}
	return self;
}

- (MMNotificationType) type;
{
    NSString* type = self.data[@"object_type"];
    if ([type isEqualToString:@"event"]) return MMNotificationTypeEvent;
    if ([type isEqualToString:@"checkin"]) return MMNotificationTypeCheckin;    
    if ([type isEqualToString:@"album"]) return MMNotificationTypeAlbum;
    if ([type isEqualToString:@"photo"]) return MMNotificationTypePhoto;
    if ([type isEqualToString:@"stream"]) return MMNotificationTypeStream;
    if ([type isEqualToString:@"friend"]) return MMNotificationTypeFriend;
    if ([type isEqualToString:@"page"]) return MMNotificationTypePage;    
    if ([type isEqualToString:@"group"]) return MMNotificationTypeGroup;        
//    if ([type isEqualToString:@"apprequest"]) return MMNotificationTypeGroup;
    
    return MMNotificationTypeUnknown;
}

- (BOOL) isNeedHTTPRequest
{
    return [MMStatusModel isNeedHTTPRequest:self.data[@"href"]];
}

- (NSString*) ID
{
    switch (self.type) {
        case MMNotificationTypeEvent:
            return [self.data[@"href"] stringMatchedByRegex:@"events/(\\d+)"];
            break;

        case MMNotificationTypePage:
            return [self.data[@"href"] stringMatchedByRegex:@"facebook.com/([^/]+)"];
            break;

        case MMNotificationTypePhoto:
            return [self.data[@"href"] stringMatchedByRegex:@"fbid=(\\d+)"];
            break;

        case MMNotificationTypeFriend:
            return [self.data[@"href"] stringMatchedByRegex:@"facebook.com/([^/]+)"];
            break;

        case MMNotificationTypeStream:
            return [self.data[@"href"] stringMatchedByRegex:@"posts/([^/]+)"];
            break;

        case MMNotificationTypeGroup:
            return [self.data[@"href"] stringMatchedByRegex:@"groups/([^/]+)"];
            break;

        default:
            return [self.data[@"href"] stringMatchedByRegex:@"facebook.com/([^/]+)"];
            break;
    }
}

- (NSString*) senderID;
{
    NSString* senderID = nil;
    NSNumber* _senderID = self.data[@"sender_id"];
    if (_senderID) {
        senderID = [_senderID stringValue];
    }
    return senderID;
}

- (BOOL) isUnread
{
    NSUInteger isUnread = [self.data[@"is_unread"] integerValue];
    if (isUnread == 1) return YES;
    return NO;
}


@end
