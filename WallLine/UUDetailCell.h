//
//  UUDetailCell.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/06.
//
//

#import <UIKit/UIKit.h>

@interface UUDetailCell : UITableViewCell
@property (weak, nonatomic) RTLabel* labelForDetail;
- (void) setData:(NSDictionary*)data;
+ (UUDetailCell*) cell:(UITableView*)tableView;
+ (CGFloat) heightFromData:(NSDictionary*)data;
@end
