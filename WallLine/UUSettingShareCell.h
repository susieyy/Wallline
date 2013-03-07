//
//  UUSettingShareCell.h
//  Kawaiines
//
//  Created by 杉上 洋平 on 12/01/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UUSettingShareCell : UITableViewCell
@property (weak, nonatomic) UIImageView* imageviewForSelect;
@property (weak, nonatomic) UILabel* labelForTitle;
@property (weak, nonatomic) UILabel* labelForUserName;
- (void) setEnable:(BOOL)enable;
@end
