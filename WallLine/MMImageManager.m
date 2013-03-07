//
//  MMImageManager.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/20.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "MMImageManager.h"
#import "UIImage+SSNoAlpha.h"

@interface MMImageManager ()
@property (strong, nonatomic) NSMutableDictionary* caches;
@end

@implementation MMImageManager
//@synthesize caches = _caches;

+ (MMImageManager *) sharedManager 
{
    static dispatch_once_t pred;
    static MMImageManager *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[MMImageManager alloc] init];
    });
    return shared;
}

- (id) init
{
	self = [super init];
	if (self) {
		self.caches = [NSMutableDictionary dictionary];
	}
	return self;
}

+ (UIImage*) imageForUserProfile:(UIImage*)_image
{
    UIImage *imagepaper = [UIImage imageNamed:@"paper.png"];
    UIImage* image = [UIImage imageAsNoAlpha:^(CGContextRef context, CGFloat scale, CGSize size){
        CGRect bounds = CGRectMake(0, 0, size.width*scale, size.height*scale);            
        CGContextDrawTiledImage(context, CGRectOfSize(imagepaper.size), imagepaper.CGImage);
        
        SSContextAddRoundedRectToPath(context, bounds, bounds.size.width/6.0f, SSRoundedCornerPositionAll);
        CGContextClip(context);                    
        CGContextDrawImage(context, bounds, _image.CGImage);   
        
        SSContextAddRoundedRectToPath(context, bounds, bounds.size.width/6.0f, SSRoundedCornerPositionAll);
        CGContextSetFillColorWithColor(context, HEXCOLOR(0x666666).CGColor);
        CGContextSetLineWidth(context, 0.5f);
        CGContextStrokePath(context);
        
    } size:_image.size];
    return image;
}

- (UIImage*) imageForFacebookIconRounded;
{
    NSString* key = @"FacebookIconRounded";
    UIImage* image = [self.caches objectForKey:key];
    if (image == nil) {
        UIImage* _image = [UIImage imageNamed:@"facebookicon.png"];        
        image = [[self class] imageForUserProfile:_image];
        [self.caches setValue:image forKey:key];
    }
    return image;
}

- (UIImage*) imageForFacebookIcon;
{
    NSString* key = @"FacebookIcon";
    UIImage* image = self.caches[key];
    if (image == nil) {
        UIImage* _image = [UIImage imageNamed:@"facebookicon.png"];        
        image = _image;
        self.caches[key] = image;
    }
    return image;
}


- (UIImage*) imageForPrivacy:(NSString*)value;
{
    NSString* key = [NSString stringWithFormat:@"%@-%@", @"privacy", value];
    UIImage* image = self.caches[key];
    UIColor* color = HEXCOLOR(0xCCCCCC);
    if (image == nil) {
        if ([value isEqualToString:FacebookPrivacyEvryone]) {
            image = [[UIImage imageNamed:@"notification"] imageAsInnerResizeTo:CGSizeMake(60*0.60, 60*0.60)];
        } else if ([value isEqualToString:FacebookPrivacyAllFriends]) {
            image = [[UIImage imageNamed:@"friend"] imageAsInnerResizeTo:CGSizeMake(60*0.60, 60*0.60)];
        } else if ([value isEqualToString:FacebookPrivacyFriendsOfFriedns]) {
            image = [[UIImage imageNamed:@"friends"] imageAsInnerResizeTo:CGSizeMake(60*0.60, 60*0.60)];
        } else if ([value isEqualToString:FacebookPrivacyCustom]) {
            image = [[UIImage imageNamed:@"setting"] imageAsInnerResizeTo:CGSizeMake(60*0.60, 60*0.60)]; 
        } else if ([value isEqualToString:FacebookPrivacySelf]) {
            image = [[UIImage imageNamed:@"ifno"] imageAsInnerResizeTo:CGSizeMake(60*0.60, 60*0.60)]; // TODO:
        } else if ([value isEqualToString:FacebookPrivacyNetworksFriends]) {
            image = [[UIImage imageNamed:@"ifno"] imageAsInnerResizeTo:CGSizeMake(60*0.60, 60*0.60)]; // TODO:
        }
        image = [image imageAsMaskedColor:color];
        if (image) self.caches[key] = image;
    }
    return image;
}


@end
