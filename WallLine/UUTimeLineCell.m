//
//  UUTimeLineCell.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UUTimeLineCell.h"
#import "UUTimeLineCell+Define.h"
#import "UUTimeLineCell+Create.h"
#import "UUTimeLineCell+Action.h"
#import "UUTimeLineCell+Layout.h"


#import "RTLabel.h"

#import "SDImageCache.h"
//#import "UIImageView+WebCacheCustom.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"


@interface UIImageOuterView : UIImageView

@end

@implementation UIImageOuterView

- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    [super drawLayer:layer inContext:ctx];
}

- (void) drawRect:(CGRect)rect  
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    CGContextSetStrokeColorWithColor(context, HEXCOLOR(0x990000).CGColor);
    CGContextSetLineWidth(context, 4.0f);
    CGContextStrokeRect(context, rect);    
    
    CGContextRestoreGState(context);        
}

@end

@interface UUTimeLineCell () <RTLabelDelegate>

@end


@implementation UUTimeLineCell

- (void) reset
{
    self.viewForLinkLine.hidden = YES;
    
    self.labelForMessage.hidden = YES;
    self.labelForMessage.text = @"";
    
    self.labelForLink.hidden = YES;
    self.labelForLink.text = @"";
    
    self.labelForDescription.hidden = YES;        
    self.labelForDescription.text = @"";
    
    self.buttonForPicture.hidden = YES;
    self.viewForPhotoOuter.hidden = YES;
    
    self.labelForPhotoTags.hidden = YES;
    
    self.viewForButtonsOuter.hidden = YES;
}

- (void) _updateLikeButton;
{
    NSString* title = nil;
    if (self.statusModel.isLiked) {
        title = NSLocalizedString(@"Liked (Unlike)", @"");
    } else {
        title = NSLocalizedString(@"Like!", @"");
    }
    [self.buttonForLike setTitle:title forState:UIControlStateNormal];
}


- (void) _setImageClear:(UIButton*)button
{
    UIImage* image = nil;
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateHighlighted];
    [button setImage:image forState:UIControlStateSelected];
    self.isSettedImage = NO;
}

- (void) _setImage:(UIImage *)image button:(UIButton*)button type:(MMDataType)type
{
    if (image == nil) {
        return;
    }
    SS_MLOG(self);
    if (type == MMDataTypePhoto) {
        CGSize sizeForPhoto = image.size;
        if (image.scale < [[UIScreen mainScreen] scale]) {
            CGFloat r = image.scale / [[UIScreen mainScreen] scale];
            sizeForPhoto = CGSizeMake(sizeForPhoto.width * r, sizeForPhoto.height * r);
        }
        [self _setSizeForPhoto:sizeForPhoto];
    }
    
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:nil forState:UIControlStateHighlighted];
    [button setImage:nil forState:UIControlStateSelected];
    self.isSettedImage = YES;
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



- (void) setDataModel:(MMStatusModel *)statusModel
{
    NSString* IDo = self.statusModel[@"id"];
    NSString* IDn = statusModel[@"id"];
    _statusModel = statusModel;
    
    if ([IDo isEqualToString:IDn] && statusModel.isNeedCellUpdate == NO) {
        // [self layoutSubviews];
        // return;
    }
    
    statusModel.isNeedCellUpdate = NO;
    
    MMDataType type = [statusModel type];
    __weak UUTimeLineCell* _self = self;

    [self reset];
    [self updateFontSize];
    
    // Date
    {
        self.labelForDate.text = [self.statusModel[@"updated_time"] stringRelativeDate]; 
    }
        
    // [RTLABEL] Message / Story / Place
    NSString* messageAndStoryAndPlace = [statusModel messageAndStoryAndPlace];
    if (messageAndStoryAndPlace) {
        NSDictionary* d = statusModel.textComponents[@"_messageAndStoryAndPlace"];
        [self.labelForMessage setText:messageAndStoryAndPlace extractTextStyle:d];
        self.labelForMessage.hidden = NO;        
    }  
    
    // [RTLABEL] Link ( Name / Caption )
    if ([statusModel hasLinkSection]) {
        NSString* linkNameAndCaption = [statusModel linkNameAndCaption];
        NSDictionary* d = statusModel.textComponents[@"_linkNameAndCaption"];
        [self.labelForLink setText:linkNameAndCaption extractTextStyle:d];
        self.labelForLink.hidden = NO;
        self.viewForLinkLine.hidden = NO;
    }    
    
    // [RTLABEL] Description
    NSString* key = nil;
    if (self.isStatusMode) {
        key = @"description";
    } else {
        key = @"_descriptionAndLikeAndCommentAndApplication";
    }
    NSString* description = statusModel[key];
    if (description) {
        NSDictionary* d = statusModel.textComponents[key];
        [self.labelForDescription setText:description extractTextStyle:d];
        self.labelForDescription.hidden = NO;
    }
    
    // Photo Tags
    if (type == MMDataTypePhoto) {
        NSString* s = [statusModel tagsForPhoto];
        if (s) {
            self.labelForPhotoTags.text = s;
            self.labelForPhotoTags.height = self.labelForPhotoTags.optimumSize.height;
            self.labelForPhotoTags.hidden = NO;
        }
    }
     
    // Like !
    {
        if ([statusModel URLForActionLike]) {
            [self _updateLikeButton];
            self.buttonForLike.hidden = NO;
            self.viewForButtonsOuter.hidden = NO;
        } else {
            self.buttonForLike.hidden = YES;        
        }
    }
    // Like / Comment
    {
        NSMutableArray* a = [NSMutableArray array];
        if ([statusModel URLForActionLike]) {
            NSUInteger count = [statusModel countForLike];
            NSString* t = [NSString stringWithFormat:@"%d %@", count, NSLocalizedString(@"Like", @"")];
            [a addObject:t];
        }
        if ([statusModel URLForActionComment]) {
            NSUInteger count = [statusModel countForComment];
            NSString* t = [NSString stringWithFormat:@"%d %@", count, NSLocalizedString(@"Comment", @"")];
            [a addObject:t];
        }
            
        if (a.count) {
            NSString* t = [a join:@", "];
            [self.buttonForComment setTitle:t forState:UIControlStateNormal];
            self.buttonForComment.hidden = NO;        
            self.viewForButtonsOuter.hidden = NO;        
        } else {
            self.buttonForComment.hidden = YES;        
        }

    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // isStatusMode
    if (statusModel.isStatusMode) {
        self.buttonForComment.hidden = YES;
    } else {
        
    }
    
    // Privacy
    {
        if (statusModel[@"privacy"] && statusModel[@"privacy"][@"value"]) {
            UIImage* image = [[MMImageManager sharedManager] imageForPrivacy:statusModel[@"privacy"][@"value"]];
            [self.buttonForPrivacy setImage:image forState:UIControlStateNormal];
            self.buttonForPrivacy.hidden = NO;
        } else {
            self.buttonForPrivacy.hidden = YES;
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // UserProfile
    {
        NSString* userID = [[statusModel objectForKey:@"from"] objectForKey:@"id"];
        [self.buttonForUserProfile setUserID:userID blockImageProcessor:^UIImage *(UIImage *_image) {
            return [MMImageManager imageForUserProfile:_image];
        }];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Photo / Picture
    {
        NSString* URLPath = [statusModel URLPathForPicture];
        UIView* viewForOuter = nil;
        UIButton* button = nil;
        if (type == MMDataTypePhoto) {
            button = self.buttonForPhoto;
            viewForOuter = self.viewForPhotoOuter;
        } else {
            button = self.buttonForPicture;            
            viewForOuter = nil;
            
            if (URLPath) {
                self.viewForLinkLine.hidden = NO;
            }
        }
        
        [self _setImageClear:button];        
        
        if (URLPath) {
            button.hidden = NO;
            viewForOuter.hidden = NO;
            
            NSURL* URL = [NSURL URLWithString:URLPath];
            // reset state
            {
                if (type == MMDataTypePhoto) {
                    [self _setSizeForPhoto:CGSizeMake(SIZE_FOR_ORIGIN_PHOTO/2, SIZE_FOR_ORIGIN_PHOTO/2)];
                }
            }
            
            SSBlockImageProcessor blockImageProcessor = ^(UIImage *_image) {
                CGSize size;
                if (type == MMDataTypePhoto) {
                    size = CGSizeMake(SIZE_FOR_ORIGIN_PHOTO/2, SIZE_FOR_ORIGIN_PHOTO/2);
                } else {
                    size = CGSizeMake(130.0f/2, 130.0f/2);
                }
                UIImage* image = [[_image imageAsNoAlpha:HEXCOLOR(0xFFFFFF)] resizedImageToFitInSize:size scaleIfSmaller:NO];
                return image;
            };
            
            UIImage* _imageMemCache = [[SDImageCache sharedImageCache] imageFromKey:[URL absoluteString] fromDisk:NO];
            if (_imageMemCache) {
                SSLog(@"    [UIImageView] Image Mem Cache Hit [%@]", [URL absoluteString]);
                [self _setImage:_imageMemCache button:button type:type];

            } else {
            
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage* imageCache = [[SDImageCache sharedImageCache] imageFromKey:[URL absoluteString] fromDisk:YES];                
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (imageCache) {
                            SSLog(@"    [UIImageView] Image Disk Cache Hit [%@]", [URL absoluteString]);  
                            SSLog(@"IMAGE [%f] %@", imageCache.scale, NSStringFromCGSize(imageCache.size));
                            [_self _setImage:imageCache button:button type:type];
                            
                        } else {                        
                            [button setImageWithURL:URL placeholderImage:nil options:SDWebImageRetryFailed success:^(UIImage *_image) {
                                // Alread set image
                                [_self _setImageClear:button];
                                
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                                                                    
                                    UIImage *image = [_self _image:_image processor:blockImageProcessor];
                                    
                                    SSLog(@"IMAGE [%f] %@ [%f] %@", image.scale, NSStringFromCGSize(image.size), image.scale, NSStringFromCGSize(_image.size));
                                    [[SDImageCache sharedImageCache] storeImage:image
                                                                      imageData:nil
                                                                         forKey:[URL absoluteString]
                                                                         toDisk:YES];
                                    //SSLog(@"    SDImageCache MemoryCount [%d] MemorySize [%d] DiskCount [%d]", 1, [[SDImageCache sharedImageCache] getMemorySize], [[SDImageCache sharedImageCache] getDiskCount]);
                                    // [[SDImageCache sharedImageCache] getMemoryCount]
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSString* _URLPath = [_self.statusModel URLPathForPicture];
                                        if ([URLPath isEqualToString:_URLPath] == NO) return;
                                        SSLog(@"    [UIImageView] Image Reload [%@]", [URL absoluteString]);
                                                                                
                                        [_self _setImage:image button:button type:type];
                                    }); // dispatch_async m                                    
                                }); // dispatch_async s
                                
                            } failure:^(NSError *error) {
                                SSLog(@"    [ERROR] Screen %@", [error description]);
                                [_self _setImageClear:button];
                            }];
                        }
                    }); // dispatch_async m
                }); // dispatch_async s
                
            }
        }
    }
    
    [self layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma -
#pragma 

+ (UUTimeLineCell*) cell:(UITableView*)tableView
{
    static NSString* Identifier = @"UUTimeLineCell";
    UUTimeLineCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UUTimeLineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}


#pragma -
#pragma Height

+ (RTLabel*) rtlabelForHeight
{
    static RTLabel* _label = nil;
    if (_label == nil) {
        _label = [self rtlabel];
    }
    return _label;
}

+ (CGFloat) heightFromData:(MMStatusModel *)statusModel
{
    NSUInteger fontSize;
    {
        NSString* key = @"FontSizeForTimeLine";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        fontSize = [userDefaults integerForKey:key];
    }
    

    MMDataType type = [statusModel type];
    
    CGFloat height = MARGIN * 2;
    
    // name
    //height += HEIGHT_FOR_NAME;
        
    RTLabel* label = [self rtlabelForHeight];
    label.frame = CGRectMake(0, 0, WIDTH_FOR_TEXT, INT_MAX);
    label.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    
    // user_name / message / story / place
    NSString* msg = [statusModel messageAndStoryAndPlace];
    if (msg && msg.length) {
        NSDictionary* d = statusModel.textComponents[@"_messageAndStoryAndPlace"];
        [label setText:msg extractTextStyle:d];
        height += label.optimumSize.height;
    }
    
    // Link ( Name / Caption )    
    
    if ([statusModel hasLinkSection]) {
        label.font = [UIFont fontWithName:FONT_NAME size:fontSize-2];
        
        // Link width
        if (statusModel[@"picture"]) {
            label.width = WIDTH_FOR_TEXT - 130/2 - 8.0f - WIDTH_FOR_LINK_INDENT;
        } else {
            label.width = WIDTH_FOR_TEXT - WIDTH_FOR_LINK_INDENT;
        }
        
        // Link
        {
            height += MARGIN_INTERVAL;      
            NSDictionary* d = statusModel.textComponents[@"_linkNameAndCaption"];            
            [label setText:[statusModel linkNameAndCaption] extractTextStyle:d];            
            //label.text = [statusModel linkNameAndCaption];
            CGFloat heightOptimum = label.optimumSize.height;

            if (statusModel[@"picture"] && heightOptimum < 130.0f/2) {
                height += 130.f/2;
            } else {
                height += heightOptimum + MARGIN_OPTIMUM;
            }
        }        
    } else if (statusModel[@"picture"]) {
        height += MARGIN_INTERVAL;            
        height += 130.f/2;
    }
    
    // Photo
    if (MMDataTypePhoto == type) {
        NSValue* v = statusModel[@"_size_for_photo"];
        CGFloat _height;
        if (v) {
            CGSize size = [v CGSizeValue];
            _height = size.height;            
        } else {
            _height = SIZE_FOR_ORIGIN_PHOTO/2;                         
        }
        height += MARGIN_INTERVAL*2;                    
        height += _height + (1.0f * 2);
        height += MARGIN_INTERVAL;                                
    }
    
    // Description
    NSString* key = nil;
    if (statusModel.isStatusMode) {
        key = @"description";
    } else {
        key = @"_descriptionAndLikeAndCommentAndApplication";
    }
    if (statusModel[key]) {
        label.font = [UIFont fontWithName:FONT_NAME size:fontSize-2];
        label.width = WIDTH_FOR_TEXT;
        
        NSDictionary* d = statusModel.textComponents[key];
        [label setText:statusModel[key] extractTextStyle:d];
        //label.text = statusModel[key];
        height += MARGIN_INTERVAL;            
        height += label.optimumSize.height + MARGIN_OPTIMUM;            
    }

    // Button
    if ([statusModel URLForActionLike] || [statusModel URLForActionComment]) {    
        height += MARGIN;
        height += HEIGHT_FOR_BUTTONS;
    }
    
    if (height < 88.0f) height = 88.0f;
    return height;
}


- (void) cancelRequest;
{
    SS_MLOG(self);
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // User Profile
    [manager cancelForDelegate:self.buttonForUserProfile];

    // Picture
    [manager cancelForDelegate:self.buttonForPicture];

    // Photo
    [manager cancelForDelegate:self.buttonForPhoto];
}
@end
