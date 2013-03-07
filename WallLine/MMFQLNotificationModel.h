//
//  MMNotificationModel.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/07/24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMAbstModel.h"

typedef enum {
    MMNotificationTypeEvent = 0,    
    MMNotificationTypeCheckin = 1,        
    MMNotificationTypeAlbum = 2,     
    MMNotificationTypePhoto = 3,         
    MMNotificationTypeStream = 4,         
    MMNotificationTypeFriend = 5,         
    MMNotificationTypePage = 6,  
    MMNotificationTypeGroup = 7,
    MMNotificationTypeUnknown = 99
} MMNotificationType;


@interface MMFQLNotificationModel : MMAbstModel

- (MMNotificationType) type;
- (NSString*) ID;
- (NSString*) senderID;
- (BOOL) isUnread;


- (BOOL) isNeedHTTPRequest;
@end
