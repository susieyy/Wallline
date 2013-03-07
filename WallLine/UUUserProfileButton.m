//
//  UUUserProfileButton.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/08/01.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UUUserProfileButton.h"
#import "SDImageCache.h"
#import "UIButton+WebCache.h"

@interface UUUserProfileButton ()
@property (nonatomic) BOOL isSettedImage;

@end
@implementation UUUserProfileButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void) _setImageClear
{
    UIImage* image = [self _imageForFacebookIcon];
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateHighlighted];
    [self setImage:image forState:UIControlStateSelected];
    self.isSettedImage = NO;
}

- (UIImage*) _imageForFacebookIcon;
{
    UIImage* imageForFacebookIcon = nil;
    if (self.isIconRounded) {
        imageForFacebookIcon = [[MMImageManager sharedManager] imageForFacebookIconRounded];
    } else {
        imageForFacebookIcon = [[MMImageManager sharedManager] imageForFacebookIcon];
    }
    return imageForFacebookIcon;    
}

- (UIImage*) _image:(UIImage*)_image processor:(SSBlockImageProcessor)blockImageProcessor;
{
    UIImage *image = nil;
    if (blockImageProcessor) {
        image = blockImageProcessor(_image);
    } else {
        image = _image;
    }
    return image;
}

- (void) _setImage:(UIImage *)image
{
    [self setImage:image forState:UIControlStateNormal];
    [self setImage:nil forState:UIControlStateHighlighted];
    [self setImage:nil forState:UIControlStateSelected];
    self.isSettedImage = YES;   
}

- (void) setUserID:(NSString*)ID blockImageProcessor:(SSBlockImageProcessor)blockImageProcessor;
{
    if (ID == nil || ID.length == 0) {
        [self _setImageClear]; 
        return;
    }
    if ([self.ID isEqualToString:ID] && self.isSettedImage) {
        // Same ID
        return;
    }
    
    self.ID = ID;
    
    NSString* URLPath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", ID];
    NSURL* URL = [NSURL URLWithString:URLPath];
    // reset state
    {
        [self _setImageClear];        
    }
    
    __weak UUUserProfileButton* _self = self;
    
    UIImage* _imageMemCache = [[SDImageCache sharedImageCache] imageFromKey:URLPath fromDisk:NO];
    if (_imageMemCache) {
        UIImage *image = [self _image:_imageMemCache processor:blockImageProcessor];
        SSLog(@"    [UIImageView] Image Mem Cache Hit [%@]", URLPath);
        [_self _setImage:image];
        return;
    }
    
    {
        UIImage* imageForFacebookIcon = [self _imageForFacebookIcon];        
        [self setImage:imageForFacebookIcon forState:UIControlStateNormal];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* _imageCache = [[SDImageCache sharedImageCache] imageFromKey:URLPath fromDisk:YES];
        UIImage *imageCache = [self _image:_imageCache processor:blockImageProcessor];
        dispatch_async(dispatch_get_main_queue(), ^{                    
            if (imageCache) {
                SSLog(@"    [UIImageView] Image Disk Cache Hit [%@]", URLPath);         
                [_self _setImage:imageCache];
                
            } else {                        
                UIImage* imageForFacebookIcon = [self _imageForFacebookIcon];
                [_self setImageWithURL:URL placeholderImage:imageForFacebookIcon options:SDWebImageRetryFailed success:^(UIImage *__image) {
                    [_self _setImageClear];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage* _image = [__image imageAsNoAlpha:HEXCOLOR(0xFFFFFF)];
                        [[SDImageCache sharedImageCache] storeImage:_image
                                                          imageData:nil
                                                             forKey:URLPath
                                                             toDisk:YES];
                        //SSLog(@"  a  SDImageCache MemoryCount [%d] MemorySize [%d] DiskCount [%d]", 1, [[SDImageCache sharedImageCache] getMemorySize], [[SDImageCache sharedImageCache] getDiskCount]);
                        // [[SDImageCache sharedImageCache] getMemoryCount]
                        
                        UIImage *image = [_self _image:_image processor:blockImageProcessor];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([_self.ID isEqualToString:ID] == NO) return;
                            SSLog(@"    [UIImageView] Image Reload [%@]", URLPath);
                            [_self _setImage:image];
                        });                                
                    });
                } failure:^(NSError *error) {
                    SSLog(@"    [ERROR] Screen %@", [error description]);
                    [_self _setImageClear];
                }];
            }
        });
    });
}


@end
