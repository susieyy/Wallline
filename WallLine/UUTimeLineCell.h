//
//  UUTimeLineCell.h
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUUserProfileButton.h"

@interface UUTimeLineCell : UITableViewCell
@property (strong, nonatomic) MMStatusModel* statusModel;
@property (nonatomic) BOOL isStatusMode;
@property (nonatomic) BOOL isSettedImage;
@property (nonatomic) NSUInteger fontSizeLast;

+ (CGFloat) heightFromData:(MMStatusModel *)statusModel;
+ (UUTimeLineCell*) cell:(UITableView*)tableView;

- (void) setDataModel:(MMStatusModel *)statusModel;

- (void) cancelRequest;

- (void) _updateLikeButton;

@end


@interface UUTimeLineCell () 
@property (weak, nonatomic) UIView* viewForBackground;
@property (weak, nonatomic) UIView* viewForLinkLine;
@property (weak, nonatomic) UIView* viewForPhotoOuter;
@property (weak, nonatomic) UIView* viewForButtonsOuter;
@property (weak, nonatomic) UILabel* labelForDate;
@property (weak, nonatomic) RTLabel* labelForMessage;
@property (weak, nonatomic) RTLabel* labelForLink;
@property (weak, nonatomic) RTLabel* labelForDescription;
@property (weak, nonatomic) UUUserProfileButton* buttonForUserProfile;
@property (weak, nonatomic) UIButton* buttonForPicture;
@property (weak, nonatomic) UIButton* buttonForPhoto;
@property (weak, nonatomic) UIButton* buttonForLike;
@property (weak, nonatomic) UIButton* buttonForComment;
@property (weak, nonatomic) UIButton* buttonForAction;
@property (weak, nonatomic) UIButton* buttonForPrivacy;

// NO USE
@property (weak, nonatomic) RTLabel* labelForPhotoTags;
@end
