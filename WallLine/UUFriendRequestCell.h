//
//  UUFriendRequestCell.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/17.
//
//

#import <UIKit/UIKit.h>

static NSString * const NFConfirmFriendRequest = @"NFConfirmFriendRequest";
static NSString * const NFNotNowFriendRequest = @"NFNotNowFriendRequest";

@interface UUFriendRequestCell : UITableViewCell

+ (UUFriendRequestCell*) cell:(UITableView*)tableView;
- (void) setData:(UUFriendRequestCell*)data;
- (void) cancelRequest;
+ (CGFloat) heightFromData:(UUFriendRequestCell*)data;


@end
