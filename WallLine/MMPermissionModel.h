//
//  MMPermissionModel.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/09.
//
//

#import <Foundation/Foundation.h>

@interface MMPermissionModel : NSObject

+ (NSArray*) permissionsForLogin;

+ (NSArray*) permissionsForUser;
+ (NSArray*) permissionsForFriends;
+ (NSArray*) permissionsForExtended;

@end
