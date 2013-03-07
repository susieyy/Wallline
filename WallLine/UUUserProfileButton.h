//
//  UUUserProfileButton.h
//  Wallline
//
//  Created by 杉上 洋平 on 12/08/01.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UIBlockButton.h"
typedef UIImage* (^SSBlockImageProcessor)(UIImage *_image);

@interface UUUserProfileButton : UIBlockButton
@property (copy, nonatomic) NSString* ID;
@property (nonatomic) BOOL isIconRounded;

- (void) setUserID:(NSString*)ID blockImageProcessor:(SSBlockImageProcessor)blockImageProcessor;

@end
