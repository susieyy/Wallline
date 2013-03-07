//
//  MWRTPhotoBrowserViewController.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/22.
//
//

#import "MWRTPhotoBrowserViewController.h"

#import "VCCommentViewController.h"
#import "VCLikesAndCommentsViewController.h"


static const CGFloat labelPadding = 10;

// Private
@interface MWRTCaptionView ()
@property (strong, nonatomic) id<MWPhoto> photo;
@property (strong, nonatomic) UILabel *label;
@end

@implementation MWRTCaptionView

- (id)initWithPhoto:(id<MWPhoto>)photo
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 44)]; // Random initial frame
    if (self) {
        self.photo = photo;
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        [self setupCaption];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat maxHeight = 9999;
    if (self.label.numberOfLines > 0) {
        maxHeight = self.label.font.leading*self.label.numberOfLines;
    }
    CGSize textSize = [self.label.text sizeWithFont:self.label.font
                                  constrainedToSize:CGSizeMake(size.width - labelPadding*2, maxHeight)
                                      lineBreakMode:self.label.lineBreakMode];
    return CGSizeMake(size.width, textSize.height + labelPadding * 2);
}

- (void)setupCaption
{
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, 0,
                                                           self.bounds.size.width-labelPadding*2,
                                                           self.bounds.size.height)];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.label.opaque = NO;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.textAlignment = UITextAlignmentCenter;
    self.label.lineBreakMode = UILineBreakModeWordWrap;
    self.label.textColor = [UIColor whiteColor];
    self.label.shadowColor = [UIColor blackColor];
    self.label.shadowOffset = CGSizeMake(1, 1);
    
    self.label.numberOfLines = 6;
    self.label.font = [UIFont systemFontOfSize:11];
    if ([self.photo respondsToSelector:@selector(caption)]) {
        self.label.text = [self.photo caption] ? [self.photo caption] : @" ";
    }
    
    [self addSubview:self.label];
}

@end

///////////////////////////////////////////////////////////////////////////////

@implementation MWRTPhoto


@end


///////////////////////////////////////////////////////////////////////////////


@interface MWRTPhotoBrowserViewController ()
@property (weak, nonatomic) UIBarButtonItem* itemForLike;
@property (weak, nonatomic) UIBarButtonItem* itemForLikesAndComments;
@end

@implementation MWRTPhotoBrowserViewController


#pragma -
#pragma Action

- (void) doLikeAction:(id)sender
{
    NSUInteger index = [self currentPageIndex];
    MWRTPhoto* photo = [self photoAtIndex:index];
    if (photo == nil) return;
    
    MMPhotoModel* model = photo.photoModel;
    
    NSString* objectID = model[@"id"];
    BOOL isLiked = [model isLiked];
    if (isLiked) {
        [[MMRequestManager sharedManager] doUnLikeObjectID:objectID];
    } else {
        [[MMRequestManager sharedManager] doLikeObjectID:objectID];
    }
    [model setLiked:!isLiked];
    
    [self updateItemForLike:model];
}

- (void) doCommentAction:(id)sender
{
    NSUInteger index = [self currentPageIndex];
    MWRTPhoto* photo = [self photoAtIndex:index];
    if (photo == nil) return;
    
    MMPhotoModel* model = photo.photoModel;
    NSString* objectID = model[@"id"];
    
    [self performSegueWithIdentifier:@"SEGUE_COMMENT" sender:objectID];
    
    /*
     VCCommentViewController* controller = [[VCCommentViewController alloc] init];
     controller.objectID = objectID;
     UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:controller];
     [self presentModalViewController:navi animated:YES];
     */
    //[[NSNotificationCenter defaultCenter] postNotificationName:NFDoShowCommentViewController object:objectID userInfo:nil];
}

- (void) doShowLikesAndCommentsAction:(id)sender
{
    NSUInteger index = [self currentPageIndex];
    MWRTPhoto* photo = [self photoAtIndex:index];
    if (photo == nil) return;
    
    MMPhotoModel* model = photo.photoModel;
    NSString* objectID = model[@"id"];
    
    [self performSegueWithIdentifier:@"SEGUE_LIKES_AND_COMMENTS" sender:objectID];    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SS_MLOG(self);
    NSString* identifier = segue.identifier;
    if ([@"SEGUE_COMMENT" isEqualToString:identifier]) {
        UINavigationController* navi = (UINavigationController*) segue.destinationViewController;
        VCCommentViewController* controller = navi.viewControllers[0];
        controller.objectID = (NSString*)sender;
    }
    if ([@"SEGUE_LIKES_AND_COMMENTS" isEqualToString:identifier]) {
        UINavigationController* navi = (UINavigationController*) segue.destinationViewController;
        VCLikesAndCommentsViewController* controller = navi.viewControllers[0];
        controller.objectID = (NSString*)sender;
        
        NSUInteger index = [self currentPageIndex];
        MWRTPhoto* photo = [self photoAtIndex:index];
        MMPhotoModel* model = photo.photoModel;
        controller.photoModel = model;
    }
}


#pragma -
#pragma

- (void) updateItemForLike:(MMPhotoModel*)model
{
    NSString* title = nil;
    if (model.isLiked) {
        title = NSLocalizedString(@"Liked (Unlike)", @"");
    } else {
        title = NSLocalizedString(@"Like!", @"");
    }
    self.itemForLike.title = title;
}

- (void) updateItemForLikesAndComments:(MMPhotoModel*)model
{
    NSString* title = [NSString stringWithFormat:@"%d%@ %d%@", model.countForLike, NSLocalizedString(@"Like", @""), model.countForComment, NSLocalizedString(@"Comment", @"")];
    self.itemForLikesAndComments.title = title;
}


// Override
- (void) viewDidLoad
{
    ///////////////////////////////////////////////////////////////////////////////
    // VCProgressViewController
    {
        VCProgressViewController* controller = [[VCProgressViewController alloc] init];
        controller.view.frame = self.view.bounds;
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [controller setNavigationBar:self.navigationController.navigationBar];
        self.progressViewController = controller;
        controller.keyForNotification = NSStringFromClass([self class]);  
        [self.view addSubview:self.progressViewController.view];
        
    }

    [super viewDidLoad];
    
    {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonPressed:)];
        self.navigationItem.leftBarButtonItem = button;
    }
    
    {
        MBProgressHUD* progressHUD = [self performSelector:@selector(progressHUD)];
        [progressHUD show:YES];
    }
    
    [self performLayout];
    
    self.displayActionButton = YES;
    self.delegate = self;
}

// Override
- (IBAction)doneButtonPressed:(id)sender
{
    [super doneButtonPressed:sender];
    
    [self clearPhotoState];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDidCloseMWRTPhotoBrowserViewController object:nil userInfo:nil];
}

// Override
- (void) performLayout
{
    [super performLayout];
    
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[UIToolbar class]]) {
            UIToolbar* toolbar = (UIToolbar*) view;
            [self performSelector:@selector(addButtonsForToolbar:) withObject:toolbar];
            break;
        }
    }
    {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
        self.navigationItem.rightBarButtonItem = button;
    }
    {
        [self.progressViewController setNavigationBar:self.navigationController.navigationBar];
    }
}

// Override
- (void) reloadData
{
    [super reloadData];
    
    {
        MBProgressHUD* progressHUD = [self performSelector:@selector(progressHUD)];
        [progressHUD hide:YES];
    }

}

//Override
- (void)didStartViewingPageAtIndex:(NSUInteger)index;
{
    [super didStartViewingPageAtIndex:index];
    
    MWRTPhoto* photo = [self photoAtIndex:index];
    MMPhotoModel* model = photo.photoModel;
    [self updateItemForLike:model];
    [self updateItemForLikesAndComments:model]; 
}

- (void) addButtonsForToolbar:(UIToolbar*)toolbar
{
    NSUInteger index = [self currentPageIndex];
    MWRTPhoto* photo = [self photoAtIndex:index];
    MMPhotoModel* model = photo.photoModel;
    
    NSMutableArray *items = [NSMutableArray array];
    {
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(doLikeAction:)];
        [items addObject:item];
        self.itemForLike = item;
    }
    {
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [items addObject:flexSpace];
    }
    /*
     {
     UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Comment", @"") style:UIBarButtonItemStyleBordered
     target:self action:@selector(doCommentAction:)];
     [items addObject:item];
     }
     {
     UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
     [items addObject:flexSpace];
     }
     */
    {
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(doShowLikesAndCommentsAction:)];
        [items addObject:item];
        self.itemForLikesAndComments = item;
    }
    [toolbar setItems:items];
    
    [self updateItemForLike:model];
    [self updateItemForLikesAndComments:model];
}

@end

///////////////////////////////////////////////////////////////////////////////

@implementation MWRTPhotoBrowserViewController (Delegate)

#pragma -
#pragma MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
{
    if (self.photoModels && self.photoModels.count) {
        NSUInteger count = self.photoModels.count;
        return count;
    } else {
        return 0;
    }
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
{
    if (self.photoModels && self.photoModels.count > index) {
        MMPhotoModel* model = self.photoModels[index];
        NSString* source = model[@"source"];
        NSURL* URL = [NSURL URLWithString:source];
        
        MWRTPhoto* photo = [[MWRTPhoto alloc] initWithURL:URL];
        NSString* name = model[@"name"];
        photo.caption = [name stringByReplacingRegexPattern:@"[\\n\\r]" withString:@""];
        photo.photoModel = model;
        return photo;
    }
    return nil;
}

//@optional
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    MWPhoto *photo = [self photoBrowser:photoBrowser photoAtIndex:index];
    MWRTCaptionView *captionView = [[MWRTCaptionView alloc] initWithPhoto:photo];
    return captionView;
}

@end

///////////////////////////////////////////////////////////////////////////////

@implementation MWRTPhotoBrowserViewController (Request)

- (void) clearPhotoState
{
    //self.photoBrowser = nil;
    self.photoModels = nil;
    
    [self.requestConnectionForPhoto cancel];
    [self.requestConnectionForAlbum cancel];
    
    self.requestConnectionForPhoto = nil;
    self.requestConnectionForAlbum = nil;
}

// Public
- (void) requestPhoto:(NSString*)objectID;
{
    [self clearPhotoState];
    
    __weak MWRTPhotoBrowserViewController* _self = self;
    [self requestPhoto:objectID completionBlock:^(NSError* error){
        if (error == nil) {
            [_self reloadData];
            [_self _requestAlbumAction:nil];
        }
    }];   
}

// Public
- (void) requestAlbum:(NSString*)objectID;
{
    [self clearPhotoState];
    
    __weak MWRTPhotoBrowserViewController* _self = self;
    [self requestAlbum:objectID completionBlock:^(NSError* error){
        if (error == nil) {
            [_self reloadData];
        }
    } isProgress:YES];
}

- (void) _requestAlbumAction:(id)sender
{
    if (NO == (self.photoModels && self.photoModels.count)) return;

    __weak MWRTPhotoBrowserViewController* _self = self;
    MMPhotoModel* model = self.photoModels[0];
    NSString* albumID = [model albumID];
    
    [self requestAlbum:albumID completionBlock:^(NSError* error){
        if (error == nil) {
            SSLog(@"PhotoBrowser reloadDataAppend");
            [_self reloadDataAppend];
        }
    } isProgress:NO];
}


#pragma -
#pragma

- (void) requestPhoto:(NSString*)graphPath completionBlock:(SSBlockError)completionBlock
{
    SS_MLOG(self);
    __weak MWRTPhotoBrowserViewController * _self = self;
    self.photoModels = [NSMutableArray array];
    
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];
    
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        params[@"locale"] = locale;
        
        FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{                
                if (error == nil) {
                    MMPhotoModel* model = [[MMPhotoModel alloc] initWithData:results];
                    [_self.photoModels addObject:model];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock(error);
                    if (error) {
                        NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
                        [VCProgressViewController requestErrorForProgress:ProgressModeFetch keyNotification:key error:error];
                    } else {
                        NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
                        [VCProgressViewController requestFinishForProgress:ProgressModeFetch keyNotification:key];
                    }
                });
            });
            
        };
        
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block];
    }
    
    NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
    [VCProgressViewController requestStartForProgress:ProgressModeFetch keyNotification:key];
    
    [requestConnection startWithBlockProgress:^(float progress) {
        [VCProgressViewController requestProgressForProgress:ProgressModeFetch keyNotification:key progress:progress];
    }];
    self.requestConnectionForPhoto = requestConnection;
    SSLog(@"    URL [%@]", [requestConnection.urlRequest URL]);
}

// objectID : albumID
- (void) requestAlbum:(NSString*)objectID completionBlock:(SSBlockError)completionBlock isProgress:(BOOL)isProgress
{
    SS_MLOG(self);
    __weak MWRTPhotoBrowserViewController * _self = self;
    
    // [self _requestStart];
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];
    
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        // OFF Locale / Page photo can't get with locale ... z
        params[@"locale"] = locale;
        
        FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                if (error == nil) {
                    NSArray* datas = results[@"data"];
                    if (datas && datas.count) {
                        if (_self.photoModels == nil) {
                            _self.photoModels = [NSMutableArray array];
                        }
                        MMPhotoModel* modelOLD = nil;
                        if (_self.photoModels && _self.photoModels.count) {
                            modelOLD = _self.photoModels[0];
                        }
                        for (NSDictionary* data in datas) {
                            MMPhotoModel* model = [[MMPhotoModel alloc] initWithData:data];
                            if (modelOLD && [modelOLD[@"id"] isEqualToString:model[@"id"]]) continue;
                            [_self.photoModels addObject:model];
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock(error);
                    if (isProgress) {
                        if (error) {
                            NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
                            [VCProgressViewController requestErrorForProgress:ProgressModeFetch keyNotification:key error:error];
                        } else {
                            NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
                            [VCProgressViewController requestFinishForProgress:ProgressModeFetch keyNotification:key];
                        }
                    }
                });
            });
            
        };
        
        NSString* graphPath = [NSString stringWithFormat:@"%@/photos", objectID];
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block];
    }

    if (isProgress) {
        NSString* key = NSStringFromClass([MWRTPhotoBrowserViewController class]);
        [VCProgressViewController requestStartForProgress:ProgressModeFetch keyNotification:key];
        [requestConnection startWithBlockProgress:^(float progress) {
            [VCProgressViewController requestProgressForProgress:ProgressModeFetch keyNotification:key progress:progress];
        }];
    } else {
        [requestConnection start];
    }
    
    self.requestConnectionForAlbum = requestConnection;
    SSLog(@"    URL [%@]", [requestConnection.urlRequest URL]);
}

@end