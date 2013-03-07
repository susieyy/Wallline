//
//  VCCommentViewController.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/09.
//
//

#import "VCCommentViewController.h"

@interface VCCommentViewController ()
@property (weak, nonatomic) UITextView* viewForTextView;
@end

@implementation VCCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Comment", @"");
    
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
    
    ///////////////////////////////////////////////////////////////////////////////
    // Close Button
    {
        UINavigationBar* navigationBar = self.navigationController.navigationBar;
        navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(dismissModalViewAction:)];
        navigationBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(sendAction:)];
    }

    ///////////////////////////////////////////////////////////////////////////////
    // TextView
    {
        CGFloat top = 4.0f;
        CGRect frame =CGRectMake(0, top, self.view.width, self.view.width - top);
        UITextView* view = [[UITextView alloc] initWithFrame:frame];
        view.font = [UIFont systemFontOfSize:16];
        view.autocapitalizationType = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:view];
        self.viewForTextView = view;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
}

- (void) dealloc
{
    SS_MLOG(self);
    [[SSStatsBarOverlay sharedManager] postMessage:[NSString stringWithFormat:@"[dealloc] %@", NSStringFromClass([self class])]];    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated  
{
    [super viewWillAppear:animated];
    [self.viewForTextView becomeFirstResponder];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)sendAction:(id)sender
{
    SS_MLOG(self);
    NSString* comment = self.viewForTextView.text;
    [[MMRequestManager sharedManager] doCommentObjectID:self.objectID comment:comment];
    
    [self dismissModalViewAction:self];
}

#pragma -
#pragma

- (void)keyboardWillShow:(NSNotification *)notification
{
    
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect keyboardRect = [[self class] keyboardRectByNotification:notification userInfoKey:UIKeyboardFrameEndUserInfoKey orientation:self.interfaceOrientation];

    CGFloat overlap;
    CGRect keyboardFrame;
    CGRect textViewFrame;
    UIScrollView* scrollView = self.viewForTextView;
    keyboardFrame = keyboardRect;
    keyboardFrame = [scrollView.superview convertRect:keyboardFrame fromView:nil];
    textViewFrame = scrollView.frame;
    overlap = MAX(0.0f, CGRectGetMaxY(textViewFrame) - CGRectGetMinY(keyboardFrame));
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, overlap, 0);
}

@end
