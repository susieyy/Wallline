//
//  VCTimeLineViewController+Sliding.h
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/20.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCTimeLineViewController.h"

@interface VCTimeLineViewController (Sliding)

- (void)viewDidLoadForSliding;
- (void)viewWillAppearForSliding;
- (void)didReceiveMemoryWarningForSliding;


- (IBAction) revealListViewController:(id)sender;
- (IBAction) revealNotificationViewController:(id)sender;

@end
