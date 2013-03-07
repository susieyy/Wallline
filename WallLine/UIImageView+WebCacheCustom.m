/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCacheCustom.h"
#import "SDImageCache.h"


@implementation UIImageView (WebCacheCustom)

#if NS_BLOCKS_AVAILABLE

- (void)setImageNoCacheWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
{
    UIImage* image = [[SDImageCache sharedImageCache] imageFromKey:[url absoluteString] fromDisk:YES];
    if (image) {
        SSLog(@"    [UIImageView] Image Cache Hit [%@]", [url absoluteString]);         
        [self setImageWithStopActivityIndicator:image];
        return;
    }
    self.image = nil; 
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    
    self.image = placeholder;
    
    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options success:success failure:failure];
    }
    [self stopActivityIndicator];
    {
        UIActivityIndicatorView* view = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        [view startAnimating];
        [self addSubview:view];
    }
}

#endif

- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
    [self stopActivityIndicator];    
}

- (void)webImageManager:(SDWebImageManager *)imageManager didProgressWithPartialImage:(UIImage *)image forURL:(NSURL *)url
{
    // self.image = image;

}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    //self.image = image;
    //[self stopActivityIndicator];
}

- (void) setImageWithStopActivityIndicator:(UIImage*)image
{
    [self setImage:image];
    [self stopActivityIndicator];
}

- (void)stopActivityIndicator;
{
    for (UIView* _view in self.subviews) {
        if ([_view isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView* view = _view;
            [view stopAnimating];
            [view removeFromSuperview];
            break;
        }
    }    
}
@end
