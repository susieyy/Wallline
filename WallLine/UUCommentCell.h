//
//  UUCommentCell.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/10.
//
//

#import <UIKit/UIKit.h>

@interface UUCommentCell : UITableViewCell
@property (strong, nonatomic) NSMutableDictionary* data;
@property (copy, nonatomic) NSString* keyForNotification;

- (void) cancelRequest;
+ (CGFloat) heightFromData:(NSDictionary*)data;
+ (UUCommentCell*) cell:(UITableView*)tableView;
@end
