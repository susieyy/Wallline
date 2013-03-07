//
//  MMNotificationModel.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/10.
//
//

#import "MMAbstModel.h"
#import "MMFQLNotificationModel.h"

@interface MMNotificationModel : MMAbstModel

- (MMNotificationType) type;
- (NSString*) ID;
- (NSString*) senderID;
- (BOOL) isUnread;

@end
