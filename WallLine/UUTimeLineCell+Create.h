//
//  UUTimeLineCell+Create.h
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/31.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UUTimeLineCell.h"

@interface UUTimeLineCell (Create)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
+ (RTLabel*) rtlabel;
- (void) updateFontSize;
@end
