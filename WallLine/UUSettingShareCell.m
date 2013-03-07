//
//  UUSettingShareCell.m
//  Kawaiines
//
//  Created by 杉上 洋平 on 12/01/01.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UUSettingShareCell.h"

@implementation UUSettingShareCell
@synthesize imageviewForSelect = _imageviewForSelect;
@synthesize labelForTitle = _labelForTitle;
@synthesize labelForUserName = _labelForUserName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        {
            CGRect frame = CGRectMake(24, 6, 32, 32);
            UIImageView* view = [[UIImageView alloc] initWithFrame:frame];
            [self addSubview:view];
            self.imageviewForSelect = view;
        }
        {
            CGRect frame = CGRectMake(64, 6, 200, 32);
            UILabel* view = [[UILabel alloc] initWithFrame:frame];
            view.font = [UIFont systemFontOfSize:12];
            view.backgroundColor = [UIColor clearColor];
            view.textColor = HEXCOLOR(0x333333);
            [self addSubview:view];
            self.labelForTitle = view;
        }
        {
            CGRect frame = CGRectMake(0, 6, 300, 32);
            UILabel* view = [[UILabel alloc] initWithFrame:frame];
            view.font = [UIFont systemFontOfSize:12];
            view.backgroundColor = [UIColor clearColor];
            view.textAlignment = UITextAlignmentRight;
            view.textColor = HEXCOLOR(0x333333);
            view.right = 300;
            [self addSubview:view];
            self.labelForUserName = view;
        }
        
    }
    return self;
}

- (void) setEnable:(BOOL)enable 
{
    if (enable) {
        [self.imageviewForSelect setImage:[UIImage imageNamed:@"multiselected"]];
    } else {
        [self.imageviewForSelect setImage:[UIImage imageNamed:@"multinone"]];        
    }
}

@end
