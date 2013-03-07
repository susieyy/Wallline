//
//  UUTimeLineCell+Layout.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/31.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UUTimeLineCell+Layout.h"
#import "UUTimeLineCell+Define.h"

@implementation UUTimeLineCell (Layout)


- (void) _setSizeForButtonForPhoto:(CGSize)size;
{
    if (CGSizeEqualToSize(self.buttonForPhoto.size, size)) return;
    
    CGPoint center = self.viewForPhotoOuter.center;    
    self.viewForPhotoOuter.size = CGSizeMake(size.width + 2.0f, size.height + 2.0f);
    self.viewForPhotoOuter.center = center;    
    self.buttonForPhoto.size = size;
}

- (void) _setSizeForPhoto:(CGSize)size
{    
    [self _setSizeForButtonForPhoto:size];
    
    if (size.height < SIZE_FOR_ORIGIN_PHOTO/2 * 0.9 && [self.statusModel objectForKey:@"_size_for_photo"] == nil) {
        // Need Reload Cell Height    
        self.statusModel.height = 0.0f;
        [self.statusModel setSizeForPhoto:size];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NFDoReHeightTimeLineCell object:self.statusModel userInfo:nil];
        });
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    MMDataType type = [self.statusModel type];
    
    // UserProfile
    self.buttonForUserProfile.origin = CGPointMake(OFFSET_MARGIN, MARGIN + 2.0f);
    
    CGFloat left = self.buttonForUserProfile.right + OFFSET_MARGIN;
        
    // Date
    self.labelForDate.origin = CGPointMake(self.width - 100.0f - 4.0f, 4.0f);
    //CGSize sizeForDate = [self.labelForDate.text sizeWithFont:self.labelForDate.font];
    
    // Mesasge
    {
        CGFloat height = self.labelForMessage.optimumSize.height + 2.0f;
        if (self.labelForMessage.height != height) {
            self.labelForMessage.frame = CGRectMake(left, MARGIN, WIDTH_FOR_TEXT, height);
        }
    }
    
    CGFloat topForDescription = self.labelForMessage.bottom + MARGIN_INTERVAL;
    
    // Photo
    if (type == MMDataTypePhoto) {
        self.viewForPhotoOuter.top = self.labelForMessage.bottom + MARGIN_INTERVAL*2;
        self.viewForPhotoOuter.centerX = self.contentView.width/2;
        topForDescription = self.viewForPhotoOuter.bottom + MARGIN_INTERVAL*2;      
        
        NSValue* v = [self.statusModel objectForKey:@"_size_for_photo"];
        CGSize size;
        if (v) {
            size = [v CGSizeValue];                        
        } else {
            size = self.buttonForPhoto.size;
        }
        [self _setSizeForButtonForPhoto:size];        
    }
    
    // Picture
    CGFloat top = 0.0f;    
    CGFloat _left = left + WIDTH_FOR_LINK_INDENT;    
    if (type == MMDataTypePhoto) {
        top = self.viewForPhotoOuter.bottom + MARGIN_INTERVAL*2;             
    } else {
        top = self.labelForMessage.bottom + MARGIN_INTERVAL;
    }
    self.buttonForPicture.origin = CGPointMake(_left, top);
    self.viewForLinkLine.frame = CGRectMake(left, top, 4.0f, self.buttonForPicture.height);
    
    // Link 
    if ([self.statusModel hasLinkSection]) {

        CGFloat height = 0.0f;
        if ([self.statusModel objectForKey:@"picture"]) {
            CGFloat diff = 130.0f/2 + 8.0f;
            height = self.labelForLink.optimumSize.height + MARGIN_OPTIMUM;
            if (self.labelForLink.height != height) {
                self.labelForLink.size = CGSizeMake(WIDTH_FOR_TEXT-WIDTH_FOR_LINK_INDENT-diff, height);
            }
            self.labelForLink.origin = CGPointMake(_left+diff, top);
            
            if (height < 130.0f/2) {
                height = 130.0f/2;
            } 
            
        } else {
            height = self.labelForLink.optimumSize.height + MARGIN_OPTIMUM;
            if (self.labelForLink.height != height) {
                self.labelForLink.size = CGSizeMake(WIDTH_FOR_TEXT-WIDTH_FOR_LINK_INDENT, height);
            }
            self.labelForLink.origin = CGPointMake(_left, top);  
        }
        
        self.viewForLinkLine.frame = CGRectMake(left, top, 4.0f, height);
        CGFloat bottom = self.labelForLink.bottom > self.viewForLinkLine.bottom ? self.labelForLink.bottom : self.viewForLinkLine.bottom;
        topForDescription = bottom + MARGIN_INTERVAL;
    }
    
    // Description 
    if (self.labelForDescription.text.length) {
        CGFloat height = self.labelForDescription.optimumSize.height + MARGIN_OPTIMUM;
        if (self.labelForDescription.height != height) {
            self.labelForDescription.size = CGSizeMake(WIDTH_FOR_TEXT, height);
        }
        self.labelForDescription.origin = CGPointMake(left, topForDescription);
    }
    
    // Buttons
    self.viewForButtonsOuter.origin = CGPointMake(left, self.contentView.height - MARGIN - HEIGHT_FOR_BUTTONS);        
    
    // Action
    self.buttonForAction.origin = CGPointMake(OFFSET_MARGIN, self.contentView.height - 33 - OFFSET_MARGIN);

    // Privacy
    self.buttonForPrivacy.origin = CGPointMake(OFFSET_MARGIN, 46);
        
    [self.viewForBackground setNeedsDisplay];
}

@end
