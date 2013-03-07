//
//  MMImageManager.h
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/20.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMImageManager : NSObject

+ (MMImageManager *) sharedManager;

+ (UIImage*) imageForUserProfile:(UIImage*)_image;
- (UIImage*) imageForFacebookIcon;
- (UIImage*) imageForFacebookIconRounded;
- (UIImage*) imageForPrivacy:(NSString*)value;

@end
