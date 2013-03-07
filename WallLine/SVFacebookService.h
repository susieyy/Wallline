//
//  SVFacebookService.h
//  Pickupps
//
//  Created by 杉上 洋平 on 12/05/29.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "Facebook.h"


@interface SVFacebookService : NSObject <FBRequestWithUploadProgressDelegate>

// Facebook
@property (strong, nonatomic) Facebook *facebook;
@property (copy, nonatomic) NSString* via;
@property (copy, nonatomic) NSString* title;
@property (copy, nonatomic) SSBlockVoid block;
@property (readonly, nonatomic) BOOL isEnable;
@property (assign, nonatomic) NSString* selectedUserName;

+ (SVFacebookService*) service;

- (NSString*) title;
- (NSString*) selectedUserName;
- (BOOL) isEnable;
- (NSURLConnection*) tweet:(NSString*)text image:(UIImage*)image blockCompletion:(SSBlockConnectionCompletion)blockCompletion blockProgress:(SSBlockConnectionProgress)blockProgress;
- (NSURLConnection*) tweet:(NSString*)text dataImage:(NSData*)dataImage blockCompletion:(SSBlockConnectionCompletion)blockCompletion blockProgress:(SSBlockConnectionProgress)blockProgress;
- (void) actionInView:(UIView*)view completionBlock:(SSBlockVoid)completionBlock;
- (void) clearBlock;

@end
