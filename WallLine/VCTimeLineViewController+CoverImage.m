//
//  VCTimeLineViewController+CoverImage.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/03.
//
//

#import "VCTimeLineViewController+CoverImage.h"
#import "VCTimeLineViewController+Define.h"

#import "SDImageCache.h"
#import "UIImageView+WebCache.h"

// cover image 640x284

@implementation VCTimeLineViewController (CoverImage)


- (void) viewDidLoadForCoverImage;
{
    __weak VCTimeLineViewController* _self = self;
    
    ///////////////////////////////////////////////////////////////////////////////
    // Cover Image
    {
        CGRect frame = CGRectMake(0, 0, self.view.width, self.view.width); // Dummy
        UIScrollView* view = [[UIScrollView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor clearColor];
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator = NO;
        view.scrollsToTop = NO;

        self.scrollerForCoverImage = view;
        [self.viewForTableContainer addSubview:view];
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:imageView];
        self.viewForCoverImage = imageView;        
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // CoverImage Cover
    {
        CGFloat top = 180;
        CGRect frame = CGRectMake(0, top, self.viewForTableContainer.width, self.viewForTableContainer.height-top);
        UIView* view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        [self.scrollerForCoverImage addSubview:view];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Label
    {
        UILabel* view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, CoverImageHeight)];
        //view.autoresizesSubviews = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = [UIColor clearColor];
        view.textColor = HEXCOLOR(0xCCCCCC);
        view.textAlignment = UITextAlignmentCenter;
        view.font = [UIFont boldSystemFontOfSize:14];
        view.shadowColor = HEXCOLOR(0xFFFFFF);
        view.shadowOffset = CGSizeMake(0.5f, 0.5f);
        view.hidden = YES;
        
        [self.viewForTableContainer addSubview:view];
        self.labelForCoverImage = view;
    }
    [self updateCoverImage];
}

- (void) updateCoverImage
{
    SS_MLOG(self);
    
    __weak VCTimeLineViewController* _self = self;
    
    [self.viewForCoverImage setImage:nil];
    self.labelForCoverImage.hidden = YES;
    
    // Cancel
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager cancelForDelegate:self.viewForCoverImage];

    if (self.stackModel.timeLineType == VCTimeLineTypeNews) {
        NSString* name = [NSString stringWithFormat:@"cover%d.jpg", randomFromTo(1, 7)];
        UIImage* image= [UIImage imageNamed:name];
        self.viewForCoverImage.image = image;
        return;
    }
    
    NSURL* URL = [self.stackModel URLCoverImage];
    
    if (URL == nil) {
        self.labelForCoverImage.hidden = NO;
        self.labelForCoverImage.text = NSLocalizedString(@"No Image", @"");
        return;
    }
    
    SSLog(@"    COVER IMAGE URL [%@]", [URL description]);
    
    UIImage* imageCache = [[SDImageCache sharedImageCache] imageFromKey:[URL absoluteString] fromDisk:YES];
    if (imageCache) {
        [self.viewForCoverImage setImage:imageCache];
        return;
    }
    
    self.labelForCoverImage.hidden = NO;    
    self.labelForCoverImage.text = NSLocalizedString(@"Loading", @"");
    [self.viewForCoverImage setImageWithURL:URL placeholderImage:nil options:SDWebImageRetryFailed success:^(UIImage *__image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage* _image = [__image imageAsNoAlpha:HEXCOLOR(0xFFFFFF)];
            UIImage* image = nil;
            if (_image.size.width < 200.0f) {
                // Profile Image
                CGFloat height = 320.0f;
                if (_image.size.height < height) height = _image.size.height;
                
                UIImage* imageCoverBack = [UIImage imageNamed:@"coverback.png"];
                image = [UIImage imageWithSize:CGSizeMake(320, height) block:^(CGContextRef context, CGSize size) {
                    {
                        CGRect bounds = CGRectOfSize(size);
                        CGContextSetFillColorWithColor(context, HEXCOLOR(0xFFFFFF).CGColor);
                        CGContextFillRect(context, bounds);
                    }
                    
                    {                        
                        CGFloat top = (imageCoverBack.size.height-size.height)/2;
                        CGRect bounds = CGRectOffset(CGRectOfSize(imageCoverBack.size), 0.0f, -top);
                        CGContextDrawImage(context, bounds, imageCoverBack.CGImage);
                    }
                    
                    {
                        CGFloat left = (320-__image.size.width)/2;
                        CGRect bounds = CGRectOffset(CGRectOfSize(__image.size), left, 0.0f);
                        CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 2.0f, HEXCOLOR(0x000000).CGColor);
                        CGContextDrawImage(context, bounds, __image.CGImage);
                    }
                }];
            } else {
                // Cover Image
                image = [_image resizedImageToFitInSize:CGSizeMake(320, 960) scaleIfSmaller:NO];
            }
            [[SDImageCache sharedImageCache] storeImage:image
                                              imageData:nil
                                                 forKey:[URL absoluteString]
                                                 toDisk:YES];

            dispatch_async(dispatch_get_main_queue(), ^{
                _self.labelForCoverImage.hidden = YES;
                [_self.viewForCoverImage setImage:image];
            });
        });
    } failure:^(NSError *error) {
        SSLog(@"    [ERROR] Screen %@", [error description]);
    }];

    /*
    NSURLRequest* request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30];
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request completionBlock:^(id data, NSURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage* image = [[[UIImage imageAsBitmapFromData:data] imageAsNoAlpha:HEXCOLOR(0xFFFFFF)] resizedImageToFitInSize:CGSizeMake(320, 960) scaleIfSmaller:NO];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.viewForCoverImage setImage:image];
            });
        });
    }];
    self.connectionForCoverImage = connection;
    */
}


#pragma mark - Parallax effect

- (void) updateOffsets
{
    CGFloat yOffset   = self.tableView.contentOffset.y;
    CGFloat threshold = CoverImageHeight - CoverImageVisibleHeight;
    
    if (yOffset > -threshold && yOffset < 0) {
        self.scrollerForCoverImage.contentOffset = CGPointMake(0.0, floorf(yOffset / 2.0));
    } else if (yOffset < 0) {
        self.scrollerForCoverImage.contentOffset = CGPointMake(0.0, yOffset + floorf(threshold / 2.0));
    } else {
        self.scrollerForCoverImage.contentOffset = CGPointMake(0.0, yOffset);
    }
}

#pragma mark - View Layout
- (void) layoutImage
{
    CGFloat imageWidth   = self.scrollerForCoverImage.frame.size.width;
    CGFloat imageYOffset = floorf((CoverImageVisibleHeight  - CoverImageHeight) / 2.0);
    CGFloat imageXOffset = 0.0;
    
    self.viewForCoverImage.frame             = CGRectMake(imageXOffset, imageYOffset, imageWidth, CoverImageHeight);
    self.scrollerForCoverImage.contentSize   = CGSizeMake(imageWidth, self.viewForTableContainer.bounds.size.height);
    self.scrollerForCoverImage.contentOffset = CGPointMake(0.0, 0.0);
    
    self.labelForCoverImage.frame = self.viewForCoverImage.frame;
}

#pragma mark - View lifecycle

- (void) viewWillAppearForCoverImage;
{
    CGRect bounds = self.viewForTableContainer.bounds;
   
    self.scrollerForCoverImage.frame        = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    self.tableView.backgroundView   = nil;
    
    [self layoutImage];
    [self updateOffsets];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateOffsets];
}

@end
