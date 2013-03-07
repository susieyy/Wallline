//
//  MWRTPhotoBrowserViewController.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/22.
//
//

#import "MWPhotoBrowser.h"
#import "VCProgressViewController.h"

@interface MWRTCaptionView : UIView

// Init
- (id)initWithPhoto:(id<MWPhoto>)photo;

// To create your own custom caption view, subclass this view
// and override the following two methods (as well as any other
// UIView methods that you see fit):

// Override -setupCaption so setup your subviews and customise the appearance
// of your custom caption
// You can access the photo's data by accessing the _photo ivar
// If you need more data per photo then simply subclass MWPhoto and return your
// subclass to the photo browsers -photoBrowser:photoAtIndex: delegate method
- (void)setupCaption;

// Override -sizeThatFits: and return a CGSize specifying the height of your
// custom caption view. With width property is ignored and the caption is displayed
// the full width of the screen
- (CGSize)sizeThatFits:(CGSize)size;

@end


@interface MWRTPhoto : MWPhoto
@property (strong, nonatomic) MMPhotoModel* photoModel;
@end


static NSString * const NFDidCloseMWRTPhotoBrowserViewController = @"NFDidCloseMWRTPhotoBrowserViewController";

@interface MWRTPhotoBrowserViewController : MWPhotoBrowser

@property (strong, nonatomic) NSMutableArray* photoModels;
@property (strong, nonatomic) FBRequestConnection* requestConnectionForPhoto;
@property (strong, nonatomic) FBRequestConnection* requestConnectionForAlbum;

// Progress
@property (strong, nonatomic) VCProgressViewController* progressViewController;
@end


@interface MWRTPhotoBrowserViewController (Request) 
- (void) requestPhoto:(NSString*)objectID;
- (void) clearPhotoState;
- (void) requestPhoto:(NSString*)graphPath completionBlock:(SSBlockError)completionBlock;
- (void) requestAlbum:(NSString*)graphPath completionBlock:(SSBlockError)completionBlock;

@end