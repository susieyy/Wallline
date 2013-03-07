//
//  UUTimeLineHeaderCell.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/16.
//
//

#import <UIKit/UIKit.h>

@interface UUTimeLineHeaderCell : UITableViewCell
@property (strong, nonatomic) MMStatusModel* data;

- (void) cancelRequest;
+ (UUTimeLineHeaderCell*) cell:(UITableView*)tableView;

+ (CGFloat) heightFromData:(NSDictionary*)data;

@end
