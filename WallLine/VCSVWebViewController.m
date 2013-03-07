//
//  VCSVWebViewController.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/24.
//
//

#import "VCSVWebViewController.h"
#import "ECSlidingViewController.h"
#import "UIViewController+KNSemiModal.h"
#import "MTStatusBarOverlay.h"

#import "VCWebHistoryViewController.h"

#import "MMWebHistoryManager.h"

#define kRevealAmount 260.0f

static NSString * const NFDoShowAllWeb = @"NFDoShowAllWeb";











@interface UUWebView : UIWebView

@end

@implementation UUWebView

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;   
{
//    [super scrollViewWillBeginDecelerating:scrollView];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoShowAllWeb object:nil userInfo:nil];
}

@end


@interface VCSVWebViewController () <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *forwardBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *refreshBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *stopBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *actionBarButtonItem;
@property (nonatomic, strong) UIActionSheet *pageActionSheet;

@property (nonatomic, strong) UUWebView *mainWebView;
@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, weak) UIView* viewForLoading;
@property (nonatomic) BOOL isLoadingAnimation;

@property (nonatomic, strong) NSTimer* timerForFinishLoad;
@property (nonatomic, strong) VCWebHistoryViewController* webHistoryViewController;
@property (nonatomic, strong) MMWebHistoryManager* webHistoryManager;

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

- (void)updateToolbarItems;

- (void)goBackClicked:(UIBarButtonItem *)sender;
- (void)goForwardClicked:(UIBarButtonItem *)sender;
- (void)reloadClicked:(UIBarButtonItem *)sender;
- (void)stopClicked:(UIBarButtonItem *)sender;
- (void)actionButtonClicked:(UIBarButtonItem *)sender;

@end


@implementation VCSVWebViewController



#pragma mark - setters and getters

- (UIBarButtonItem *)backBarButtonItem {
    
    if (_backBarButtonItem == nil) {
        self.backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/back"] style:UIBarButtonItemStylePlain target:self action:@selector(goBackClicked:)];
        self.backBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		self.backBarButtonItem.width = 18.0f;
    }
    return _backBarButtonItem;
}

- (UIBarButtonItem *)forwardBarButtonItem {
    
    if (_forwardBarButtonItem == nil) {
        self.forwardBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/forward"] style:UIBarButtonItemStylePlain target:self action:@selector(goForwardClicked:)];
        self.forwardBarButtonItem.imageInsets = UIEdgeInsetsMake(2.0f, 0.0f, -2.0f, 0.0f);
		self.forwardBarButtonItem.width = 18.0f;
    }
    return _forwardBarButtonItem;
}

- (UIBarButtonItem *)refreshBarButtonItem {
    
    if (_refreshBarButtonItem == nil) {
        self.refreshBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadClicked:)];
    }
    
    return _refreshBarButtonItem;
}

- (UIBarButtonItem *)stopBarButtonItem {
    
    if (_stopBarButtonItem == nil) {
        self.stopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopClicked:)];
    }
    return _stopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    
    if (_actionBarButtonItem == nil) {
        self.actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClicked:)];
    }
    return _actionBarButtonItem;
}

- (UIActionSheet *)pageActionSheet {
    
    if(_pageActionSheet == nil) {
        self.pageActionSheet = [[UIActionSheet alloc]
                           initWithTitle:self.mainWebView.request.URL.absoluteString
                           delegate:self
                           cancelButtonTitle:nil
                           destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        if((self.availableActions & SVWebViewControllerAvailableActionsCopyLink) == SVWebViewControllerAvailableActionsCopyLink)
            [self.pageActionSheet addButtonWithTitle:NSLocalizedString(@"Copy Link", @"")];
        
        if((self.availableActions & SVWebViewControllerAvailableActionsOpenInSafari) == SVWebViewControllerAvailableActionsOpenInSafari)
            [self.pageActionSheet addButtonWithTitle:NSLocalizedString(@"Open in Safari", @"")];
        
        if([MFMailComposeViewController canSendMail] && (self.availableActions & SVWebViewControllerAvailableActionsMailLink) == SVWebViewControllerAvailableActionsMailLink)
            [self.pageActionSheet addButtonWithTitle:NSLocalizedString(@"Mail Link to this Page", @"")];
        
        [self.pageActionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
        self.pageActionSheet.cancelButtonIndex = [self.pageActionSheet numberOfButtons]-1;
    }
    
    return _pageActionSheet;
}

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)urlString
{
    return [self initWithURL:[NSURL URLWithString:urlString]];
}

- (id)initWithURL:(NSURL*)pageURL {
    
    if(self = [super init]) {
        self.URL = pageURL;
        self.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsMailLink;
    }
    
    return self;
}

- (id) init
{
	self = [super init];
	if (self) {
		self.webHistoryManager = [[MMWebHistoryManager alloc] init];
	}
	return self;
}


#pragma mark - View lifecycle

- (void) doShowAllWeb:(NSNotification*)notification
{
    if (self.slidingViewController.topViewIsOffScreen) {
        return;
    }

    [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:nil onComplete:^{
    }];
}

- (void)loadView 
{
    self.mainWebView = [[UUWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mainWebView.delegate = self;
    self.mainWebView.scalesPageToFit = YES;
    [self.mainWebView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    self.view = self.mainWebView;
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
    [self updateToolbarItems];
    
    self.webHistoryManager = [[MMWebHistoryManager alloc] init];    
    self.availableActions = SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsMailLink;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doShowAllWeb:) name:NFDoShowAllWeb object:nil];

    ///////////////////////////////////////////////////////////////////////////////
    // PrettyNavigationBar
    {
        PrettyNavigationBar *navBar = (PrettyNavigationBar *)self.navigationController.navigationBar;
        navBar.topLineColor = [UIColor colorWithHex:0x6975C8];
        navBar.gradientStartColor = [UIColor colorWithHex:0x395598];
        navBar.gradientEndColor = [UIColor colorWithHex:0x193578];
        navBar.bottomLineColor = [UIColor colorWithHex:0x092568];
        navBar.tintColor = navBar.gradientEndColor;
        navBar.roundedCornerRadius = 8;
    }
    {
        PrettyToolbar *view = (PrettyToolbar *)self.navigationController.toolbar;
        view.topLineColor = [UIColor colorWithHex:0x6975C8];
        view.gradientStartColor = [UIColor colorWithHex:0x395598];
        view.gradientEndColor = [UIColor colorWithHex:0x193578];
        view.bottomLineColor = [UIColor colorWithHex:0x092568];
    }
    {
        if (self.navigationItem.titleView == nil) {
            UILabel *navLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0f)];
            navLabel.backgroundColor = HEXCOLORA(0x00000033);
            navLabel.textColor = [UIColor whiteColor];
            navLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
            navLabel.font = [UIFont boldSystemFontOfSize:15];
            navLabel.minimumFontSize = 10;
            navLabel.textAlignment = UITextAlignmentCenter;
            navLabel.userInteractionEnabled = YES;
            self.navigationItem.titleView = navLabel;
            
        }
    }
    ///////////////////////////////////////////////////////////////////////////////
    // SlidingView
    {
        [self.slidingViewController setAnchorLeftRevealAmount:kRevealAmount];
        self.slidingViewController.underRightWidthLayout = ECFullWidth;
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Close Button
    {
        UINavigationBar* navigationBar = self.navigationController.navigationBar;
        /*
        navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"") 
                                                                                   style:UIBarButtonItemStyleBordered target:self.slidingViewController action:@selector(resetTopView)];
        navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"History", @"")
                                                                                   style:UIBarButtonItemStyleBordered target:self action:@selector(showHistory)];

        */
        CGFloat buttonsize = 20.0f;
        {
            UIImage* image = [[[UIImage imageNamed:@"back.png"] imageAsMaskedColor:HEXCOLOR(0xFFFFFF)] imageAsInnerResizeTo:CGSizeMake(60*0.80, 60*0.80)];
            UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonsize, buttonsize)];
            [customView setBackgroundImage:image forState:UIControlStateNormal];
            [customView addTarget:self.slidingViewController action:@selector(resetTopView) forControlEvents:UIControlEventTouchUpInside];
            navigationBar.topItem.leftBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:customView];
        }
        {
            UIImage* image = [[[UIImage imageNamed:@"history.png"] imageAsMaskedColor:HEXCOLOR(0xFFFFFF)] imageAsInnerResizeTo:CGSizeMake(60*0.80, 60*0.80)];
            UIButton *customView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonsize, buttonsize)];
            [customView setBackgroundImage:image forState:UIControlStateNormal];
            [customView addTarget:self action:@selector(showHistory) forControlEvents:UIControlEventTouchUpInside];
            navigationBar.topItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:customView];
        }
    }

    {
        CGRect frame = CGRectMake(0, 44-2, self.view.width, 2.0);
        UIView* view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = HEXCOLOR(0x0088FF);
        view.hidden = YES;
        [self.navigationController.navigationBar addSubview:view];
        self.viewForLoading = view;
    }

}
         
- (void) startLoadingAnimation
{
     self.isLoadingAnimation = YES;
     self.viewForLoading.hidden = NO;
     self.viewForLoading.width = 10.0f;
     [UIView animateWithDuration:1.0f animations:^{
         self.viewForLoading.width = self.view.width;
     } completion:^(BOOL finished) {
         if (self.isLoadingAnimation) {
             [self startLoadingAnimation];
         }
     }];
}
             
- (void) stopLoadingAnimation
{
    self.isLoadingAnimation = NO;
    self.viewForLoading.hidden = YES;
}

- (void) finishLoad
{
    [self stopLoadingAnimation];
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    [overlay postFinishMessage:NSLocalizedString(@"Finish web load", @"") duration:0.6f animated:NO];
    
    
}

#pragma -
#pragma

- (VCWebHistoryViewController*) webHistoryViewController
{
    if (_webHistoryViewController == nil) {
        VCWebHistoryViewController* controller = [[VCWebHistoryViewController alloc] init];
        controller.view.size = CGSizeMake(self.view.width, 360);
        controller.delegate = self;
        self.webHistoryViewController = controller;
    }
    return _webHistoryViewController;
}

- (void) showHistory
{
    self.webHistoryViewController.items = [self.webHistoryManager.items arrayWithReversed];
    [self presentSemiViewController:self.webHistoryViewController];
}
 
- (void) dealloc
{
    SS_MLOG(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _mainWebView = nil;
    _backBarButtonItem = nil;
    _forwardBarButtonItem = nil;
    _refreshBarButtonItem = nil;
    _stopBarButtonItem = nil;
    _actionBarButtonItem = nil;
    _pageActionSheet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSAssert(self.navigationController, @"SVWebViewController needs to be contained in a UINavigationController. If you are presenting SVWebViewController modally, use SVModalWebViewController instead.");
    
	[super viewWillAppear:animated];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:NO animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setToolbarHidden:YES animated:animated];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;
    
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Toolbar

- (void)updateToolbarItems
{
    self.backBarButtonItem.enabled = self.mainWebView.canGoBack;
    self.forwardBarButtonItem.enabled = self.mainWebView.canGoForward;
    self.actionBarButtonItem.enabled = YES; // !self.mainWebView.isLoading;
    
    UIBarButtonItem *refreshStopBarButtonItem = self.mainWebView.isLoading ? self.stopBarButtonItem : self.refreshBarButtonItem;
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 5.0f;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        NSArray *items;
        CGFloat toolbarWidth = 250.0f;
        
        if(self.availableActions == 0) {
            toolbarWidth = 200.0f;
            items = [NSArray arrayWithObjects:
                     fixedSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     fixedSpace,
                     nil];
        } else {
            items = [NSArray arrayWithObjects:
                     fixedSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     flexibleSpace,
                     self.actionBarButtonItem,
                     fixedSpace,
                     nil];
        }
        

        UIToolbar *toolbar = nil;
        {
            CGRect frame = CGRectMake(0.0f, 0.0f, toolbarWidth, 44.0f);
            PrettyToolbar* view = [[PrettyToolbar alloc] initWithFrame:frame];
            toolbar = view;
            
            view.topLineColor = [UIColor colorWithHex:0x6975C8];
            view.gradientStartColor = [UIColor colorWithHex:0x395598];
            view.gradientEndColor = [UIColor colorWithHex:0x193578];
            view.bottomLineColor = [UIColor colorWithHex:0x092568];
        }
        toolbar.items = items;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
    }
    
    else {
        NSArray *items;
        
        if(self.availableActions == 0) {
            items = [NSArray arrayWithObjects:
                     flexibleSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     flexibleSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     nil];
        } else {
            items = [NSArray arrayWithObjects:
                     fixedSpace,
                     self.backBarButtonItem,
                     flexibleSpace,
                     self.forwardBarButtonItem,
                     flexibleSpace,
                     refreshStopBarButtonItem,
                     flexibleSpace,
                     self.actionBarButtonItem,
                     fixedSpace,
                     nil];
        }
        
        self.toolbarItems = items;
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self updateToolbarItems];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSString* title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    UILabel* label = (UILabel*) self.navigationItem.titleView;
    label.text = title;
    [self updateToolbarItems];
    
    {
        [self.webHistoryManager saveHistoryTitle:title URL:self.URL];
    }
        
    {    
        [self.timerForFinishLoad invalidate];
        self.timerForFinishLoad = nil;
        self.timerForFinishLoad = [NSTimer scheduledTimerWithTimeInterval:2.6f target:self selector:@selector(finishLoad) userInfo:nil repeats:NO];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateToolbarItems];
        
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    [overlay postFinishMessage:NSLocalizedString(@"Error web load", @"") duration:0.6f animated:NO];

}

#pragma mark - Target actions

- (void)goBackClicked:(UIBarButtonItem *)sender
{
    [self.mainWebView goBack];
}

- (void)goForwardClicked:(UIBarButtonItem *)sender
{
    [self.mainWebView goForward];
}

- (void)reloadClicked:(UIBarButtonItem *)sender
{
    [self.mainWebView reload];
}

- (void)stopClicked:(UIBarButtonItem *)sender
{
    [self.mainWebView stopLoading];
	[self updateToolbarItems];
}

- (void)actionButtonClicked:(id)sender
{
    
    if(self.pageActionSheet == nil)
        return;
	
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.pageActionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
    else
        [self.pageActionSheet showFromToolbar:self.navigationController.toolbar];
    
}

- (void)doneButtonClicked:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
	if([title isEqualToString:NSLocalizedString(@"Open in Safari", @"")])
        [[UIApplication sharedApplication] openURL:self.mainWebView.request.URL];
    
    if([title isEqualToString:NSLocalizedString(@"Copy Link", @"")]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.mainWebView.request.URL.absoluteString;
    }
    
    else if([title isEqualToString:NSLocalizedString(@"Mail Link to this Page", @"")]) {
        
		MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        
		mailViewController.mailComposeDelegate = self;
        [mailViewController setSubject:[self.mainWebView stringByEvaluatingJavaScriptFromString:@"document.title"]];
  		[mailViewController setMessageBody:self.mainWebView.request.URL.absoluteString isHTML:NO];
		mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        
		[self presentModalViewController:mailViewController animated:YES];
	}
    
    self.pageActionSheet = nil;
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
}


- (void) loadURL:(NSURL*)URL;
{
    [self.timerForFinishLoad invalidate];
    self.timerForFinishLoad = nil;

    self.URL = URL;
    UILabel* label = (UILabel*) self.navigationItem.titleView;
    label.text = NSLocalizedString(@"Loading", @"");
    [self startLoadingAnimation];
    [self.mainWebView loadRequest:[NSURLRequest requestWithURL:self.URL]];
    
}

#pragma -
#pragma VCWebHistoryViewControllerDeleagte

- (void) doURLInfo:(NSDictionary*)userInfo;
{
    NSURL* title = userInfo[@"title"];
    NSURL* URL = userInfo[@"URL"];
    [self loadURL:URL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissSemiModalView];        
    });
}

- (void) viewDidDisappear;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_webHistoryViewController) {
            self.webHistoryViewController = nil;
        }
    });
}
@end
