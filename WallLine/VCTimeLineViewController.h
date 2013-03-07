//
//  VCTimeLineViewController.h
//  Wallline
//
//  Created by 杉上 洋平 on 12/06/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VCDebugJSONViewController.h"
#import "VCProgressViewController.h"
#import "VCSVWebViewController.h"

#import "MWPhotoBrowser.h"
#import "ODRefreshControl.h"
#import "SVWebViewController.h"

@interface VCTimeLineViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
// Model
@property (strong, nonatomic) MMStackModel* stackModel;
@property (strong, nonatomic) NSMutableArray* stackUUIDs;
@property (strong, nonatomic) FBRequestConnection* requestConnection;

// ViewController
@property (strong, nonatomic) VCDebugJSONViewController* debugJSONViewController;

// Header / Footer
@property (weak, nonatomic) UIView *viewForFooter;
@property (weak, nonatomic) UILabel *labelForNotificationCount;

// Table
@property (strong, nonatomic) UITableView *tableView;  // Need strong !
@property (strong, nonatomic) UIButton *buttonForMore; // Need strong !
@property (weak, nonatomic) ODRefreshControl *refreshControl;

// Trasition
@property (weak, nonatomic) UIView *viewForContainer; 
@property (strong, nonatomic) UIView *viewForTableContainer; // Need strong !
@property (weak, nonatomic) UIView *viewForLoading;

// CoverImage
@property (weak, nonatomic) UIScrollView* scrollerForCoverImage;
@property (weak, nonatomic) UIImageView* viewForCoverImage;
@property (weak, nonatomic) UILabel* labelForCoverImage;

// Comment
@property (weak, nonatomic) UIView *viewForComment;

// Progress
@property (strong, nonatomic) VCProgressViewController* progressViewController;

// Web
@property (strong, nonatomic) UINavigationController *webNaviViewController;
@property (weak, nonatomic) VCSVWebViewController *webViewController;
// Helper
- (MMStatusModel*) __statusModelFromID:(NSString*)ID;

@end

@interface VCTimeLineViewController (Sliding)
- (IBAction) revealWebViewController:(NSURL*)URL;
@end

@interface VCTimeLineViewController (Header)
- (void) doAnimationTriangle;
- (void) updateHeaderTitle;
- (void) updateHeaderButtons;
@end

@interface VCTimeLineViewController (TableView)
- (void) reloadDataNeedCellUpdate:(BOOL)isNeedCellUpdate;
- (void) doReHeightTimeLineCell:(NSNotification*)notification;
@end

@interface VCTimeLineViewController (Request)
- (void) cancelRequestConnection;
- (void) requestTimeLineCompletionBlock:(SSBlockError)completionBlock;
- (void) requestTimeLineNextCompletionBlock:(SSBlockError)completionBlock;
- (void) requestTimeLinePreviousCompletionBlock:(SSBlockError)completionBlock;

//--- - (void) requestPhoto:(NSString*)graphPath completionBlock:(SSBlockError)completionBlock;
//--- - (void) requestAlbum:(NSString*)graphPath completionBlock:(SSBlockError)completionBlock;

@end


@interface VCTimeLineViewController (Action)
- (void) calcCellHeightByFontSizeChange;

- (void) doTimeLineURL:(NSNotification*)notification;
- (IBAction) doShowFacebookAction:(id)sender;
- (IBAction) doShowWriteAction:(id)sender;
- (IBAction) doShowCommentAction:(id)sender;

- (IBAction) requestNowAction:(id)sender;
- (IBAction) requestNextAction:(UIButton*)button;

@end

@interface VCTimeLineViewController (Progress)
- (void) hideNoticeView;
@end


@interface VCTimeLineViewController (Transition)
- (IBAction) openWithObjectType:(NSString*)objectType ID:(NSString*)ID SUBID:(NSString*)SUBID;
- (IBAction) closeAction:(id)sender;
- (void) removeViewForLoading;
@end

@interface VCTimeLineViewController (CoverImage)
- (void) updateOffsets;
- (void) updateCoverImage;
@end

@interface VCTimeLineViewController (Photo)

@end