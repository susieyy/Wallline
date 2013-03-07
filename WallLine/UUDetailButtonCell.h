//
//  UUDetailButtonCell.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/21.
//
//

#import <UIKit/UIKit.h>

@interface UUDetailButtonCell : UITableViewCell
@property (weak, nonatomic) MMStackModel* stackModel;
+ (UUDetailButtonCell*) cell:(UITableView*)tableView;
@end
