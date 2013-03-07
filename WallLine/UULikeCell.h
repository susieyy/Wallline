//
//  UULikeCell.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/10.
//
//

#import <UIKit/UIKit.h>

@interface UULikeCell : UITableViewCell
@property (strong, nonatomic) NSDictionary* data;
@property (copy, nonatomic) NSString* keyForNotification;

- (void) cancelRequest;
+ (UULikeCell*) cell:(UITableView*)tableView;
+ (CGFloat) heightFromData:(NSDictionary*)data;
@end
