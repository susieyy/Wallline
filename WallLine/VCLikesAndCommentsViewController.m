//
//  VCLikesAndCommentsViewController.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/22.
//
//

#import "VCLikesAndCommentsViewController.h"
#import "VCTimeLineViewController+Define.h"
#import "VCCommentViewController.h"


#import "UULikeCell.h"
#import "UUCommentCell.h"
#import "UUCoverImageCell.h"

#import "SDImageCache.h"
//#import "UIImageView+WebCacheCustom.h"
#import "UIImageView+WebCache.h"

#define SECTION_COVER 0
#define SECTION_STATUS_LIKE 1
#define SECTION_STATUS_COMMENT 2
#define SECTION_NO_STATUS 3
#define SECTION_REQUESTING 4

#define HEIGHT_FOR_SECTION 24.0f

@interface VCLikesAndCommentsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) VCProgressViewController* progressViewController;

@property (weak, nonatomic) UIView* viewForTableContainer;
@property (weak, nonatomic) UIView* viewForComment;
@property (weak, nonatomic) UITableView* tableView;

// CoverImage
@property (weak, nonatomic) UIScrollView* scrollerForCoverImage;
@property (weak, nonatomic) UIImageView* viewForCoverImage;
- (void) viewDidLoadForComment;
@end

@implementation VCLikesAndCommentsViewController

- (void) _willCommentRequest:(NSNotification*)notification
{
    SS_MLOG(self);
    NSDictionary* info = [notification object];
    NSString* objectID = info[@"objectID"];
    NSString* comment = info[@"comment"];
    
    if (NO == ([self.photoModel[@"id"] isEqualToString:objectID])) return;
    
    self.photoModel[@"id"];
    
    [self.photoModel addComment:comment];
    [self reloadData];
}


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
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willCommentRequest:) name:NFWillCommentRequest object:nil];
    }
    
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
    //
    {
        UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.view.bounds];
        view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        [self.view addSubview:view];
        self.viewForTableContainer = view;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // Close Button
    {
        UINavigationBar* navigationBar = self.navigationController.navigationBar;
        navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(dismissModalViewAction:)];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Cover Image
    {
        CGRect frame = CGRectMake(0, 0, self.viewForTableContainer.width, self.viewForTableContainer.width); // Dummy
        UIScrollView* view = [[UIScrollView alloc] initWithFrame:frame];
        view.backgroundColor = [UIColor clearColor];
        view.showsHorizontalScrollIndicator = NO;
        view.showsVerticalScrollIndicator = NO;
        view.scrollsToTop = NO;
        
        self.scrollerForCoverImage = view;
        [self.viewForTableContainer addSubview:view];
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
        //imageView.contentMode = UIViewContentModeScaleAspectFill;
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
    // TableView
    {
        UITableView* view = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        view.delegate = self;
        view.dataSource = self;
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        view.backgroundColor = [UIColor clearColor]; //HEXCOLOR(0x232937);
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.allowsSelection = NO;
        view.scrollsToTop = YES;
        [self.viewForTableContainer addSubview:view];
        self.tableView = view;
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        [view addGestureRecognizer:pinch];
    }
    
    
    [self viewDidLoadForComment];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.viewForTableContainer.frame = CGRectMake(0, 0, self.view.width, self.view.height);
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height - 40.0f);
    self.viewForComment.frame = CGRectMake(0, self.viewForTableContainer.height-40.0f, self.viewForTableContainer.width, 40.0f);
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.photoModel[@"from"][@"name"];
    
    [self reloadData];
    [self updateCoverImage];
    [self viewWillAppearForCoverImage];
}

- (UIImage*) imageAsResized:(UIImage*)__image
{
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
    return image;
}

- (void) updateCoverImage
{
    SS_MLOG(self);
    __weak VCLikesAndCommentsViewController* _self = self;
    
    NSString* source = self.photoModel[@"source"];
    NSURL* URL = [NSURL URLWithString:source];
    
    UIImage* imageCache = [[SDImageCache sharedImageCache] imageFromKey:[URL absoluteString] fromDisk:YES];
    if (imageCache) {
        UIImage* image = [self imageAsResized:imageCache];
        [self.viewForCoverImage setImage:image];
        return;
    }

    [self.viewForCoverImage setImageWithURL:URL placeholderImage:nil success:^(UIImage *__image) {
        UIImage* image = [self imageAsResized:__image];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self.viewForCoverImage setImage:image];
        });
    } failure:nil];
     
}

- (void) layoutImage
{
    CGFloat imageWidth   = self.scrollerForCoverImage.frame.size.width;
    CGFloat imageYOffset = floorf((CoverImageVisibleHeight  - CoverImageHeight) / 2.0);
    CGFloat imageXOffset = 0.0;
    
    self.viewForCoverImage.frame             = CGRectMake(imageXOffset, imageYOffset, imageWidth, CoverImageHeight);
    self.scrollerForCoverImage.contentSize   = CGSizeMake(imageWidth, self.viewForTableContainer.bounds.size.height);
    self.scrollerForCoverImage.contentOffset = CGPointMake(0.0, 0.0);
    
//    self.labelForCoverImage.frame = self.viewForCoverImage.frame;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateOffsets];
}

- (void) viewWillAppearForCoverImage;
{
    CGRect bounds = self.viewForTableContainer.bounds;
    
    self.scrollerForCoverImage.frame        = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
    self.tableView.backgroundView   = nil;
    
    [self layoutImage];
    [self updateOffsets];
}

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

#pragma -
#pragma

- (IBAction)doShowCommentAction:(id)sender
{
    SS_MLOG(self);
    NSString* objectID = self.photoModel[@"id"];    
    [self performSegueWithIdentifier:@"SEGUE_COMMENT" sender:objectID];
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
}

#pragma -
#pragma

- (void) reloadData
{
    [self.tableView reloadData];
}

- (void) cancelAllRequest;
{
    SS_MLOG(self);
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager cancelForDelegate:self.viewForCoverImage];
    
    for (UITableViewCell* _cell in [self.tableView visibleCells]) {
        if ([_cell respondsToSelector:@selector(cancelRequest)]) {
            [_cell performSelector:@selector(cancelRequest)];
        }
    }
}

// Override 
- (void) dismissModalViewAction:(id)sender
{
    [super dismissModalViewAction:sender];
    [self cancelAllRequest];
}

#pragma -
#pragma

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -
#pragma UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    
    ///////////////////////////////////////////////////////////////////////////////
    // Requsting
//    if (self.stackModel.isRequested == NO) {
    /*
    if (YES) {
        if (section == SECTION_COVER || section == SECTION_REQUESTING) {
            return 1;
        } else {
            return 0;
        }
    }
    */
    
    ///////////////////////////////////////////////////////////////////////////////
    //
    if (section == SECTION_COVER) {
        return 1;
    }
        
    if (section == SECTION_STATUS_LIKE) {
        NSUInteger count = self.photoModel.countForLike;
        if (count) {
            return count + 1;
        } else {
            return 0;
        }
    }
    if (section == SECTION_STATUS_COMMENT) {
        NSUInteger count = self.photoModel.countForComment;
        if (count) {
            return count + 1;
        } else {
            return 0;
        }
    }
    
    if (section == SECTION_NO_STATUS) {
        if (self.photoModel.countForLike == 0 && self.photoModel.countForComment == 0) {
            return 1;
        } else {
            return 0;
        }
    }
    
    if (section == SECTION_REQUESTING) {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == SECTION_COVER) {
        return CoverImageVisibleHeight;
    }
    if (indexPath.section == SECTION_STATUS_LIKE) {
        if (indexPath.row == 0) return HEIGHT_FOR_SECTION;
        return [UULikeCell heightFromData:nil];
    }
    if (indexPath.section == SECTION_STATUS_COMMENT) {
        if (indexPath.row == 0) return HEIGHT_FOR_SECTION;
        NSArray* array = self.photoModel[@"comments"][@"data"];
        NSUInteger index = indexPath.row-1;
        NSDictionary* data = array[index];
        return [UUCommentCell heightFromData:data];
    }
    if (indexPath.section == SECTION_NO_STATUS || indexPath.section == SECTION_REQUESTING) {
        return self.tableView.height - CoverImageVisibleHeight;
    }
}

#pragma -
#pragma

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///////////////////////////////////////////////////////////////////////////////
    // Cover
    if (indexPath.section == SECTION_COVER) {
//        if (self.stackModel.isRequested == NO) {
            return [self cellForDummyAtIndexPath:indexPath tableView:tableView text:nil];
//        }
        
        UUCoverImageCell* cell = [UUCoverImageCell cell:tableView];
        return cell;
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // Header Likes / Comments
    if ((indexPath.section == SECTION_STATUS_LIKE || indexPath.section == SECTION_STATUS_COMMENT) && indexPath.row == 0) {
        static NSString* Identifier = @"HeaderLabelCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = HEXCOLOR(0xCCCCCC);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            cell.contentView.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        }
        
        if (indexPath.section == SECTION_STATUS_LIKE) {
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@", self.photoModel.countForLike, NSLocalizedString(@"Likes", @"")];
        }
        if (indexPath.section == SECTION_STATUS_COMMENT) {
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@", self.photoModel.countForComment, NSLocalizedString(@"Comments", @"")];
        }
        return cell;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Status Like
    if (indexPath.section == SECTION_STATUS_LIKE) {
        NSArray* array = self.photoModel[@"likes"][@"data"];
        NSUInteger index = indexPath.row-1;
        NSDictionary* data = array[index];
        
        UULikeCell* cell = [UULikeCell cell:tableView];
        cell.keyForNotification = NSStringFromClass([self class]);
        [cell setData:data];
        return cell;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Status Comment
    if (indexPath.section == SECTION_STATUS_COMMENT) {
        NSArray* array = self.photoModel[@"comments"][@"data"];
        NSUInteger index = indexPath.row-1;
        NSDictionary* data = array[index];
        
        UUCommentCell* cell = [UUCommentCell cell:tableView];
        cell.keyForNotification = NSStringFromClass([self class]);        
        [cell setData:data];
        return cell;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // NoStatus
    if (indexPath.section == SECTION_NO_STATUS) {
        return [self cellForDummyAtIndexPath:indexPath tableView:tableView text:NSLocalizedString(@"No status found.", @"")];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Requesting
    if (indexPath.section == SECTION_REQUESTING) {
        return [self cellForDummyAtIndexPath:indexPath tableView:tableView text:nil];
    }
    
}

- (UITableViewCell *)cellForDummyAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)tableView text:(NSString*)text
{
    static NSString* Identifier = @"DummyStatusIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = HEXCOLOR(0xCCCCCC);
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.shadowColor = HEXCOLOR(0xFFFFFF);
        cell.textLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);
    }
    
    if (text == nil) text = @"";
    cell.textLabel.text = text;
    
    if (indexPath.section == SECTION_COVER) {
        cell.contentView.backgroundColor = [UIColor clearColor];
    } else {
        cell.contentView.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
    }
    return cell;
}

@end


@implementation VCLikesAndCommentsViewController (Comment)

- (void) viewDidLoadForComment
{
    CGRect frame = CGRectMake(0, 0, self.viewForTableContainer.width, 40.0f);
    UIView* containerView = [[UIView alloc] initWithFrame:frame];
    containerView.backgroundColor = HEXCOLOR(0x990000);
    containerView.userInteractionEnabled = YES;
    [self.viewForTableContainer addSubview:containerView];
    self.viewForComment = containerView;
    
    {
        UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
        UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        entryImageView.frame = CGRectMake(5, 0, 208, 40);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
        UIImage *_background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImage *background = [UIImage imageWithSize:containerView.size block:^(CGContextRef context, CGSize size) {
            CGContextDrawImage(context, CGRectOfSize(size), _background.CGImage);
            
        }];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        // view hierachy
        [containerView addSubview:imageView];
        [containerView addSubview:entryImageView];
        
        UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(containerView.frame.size.width - 109, 8, 103, 27);
        doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [doneBtn setTitle:NSLocalizedString(@"Comment", @"") forState:UIControlStateNormal];
        
        [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(doShowCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
        [containerView addSubview:doneBtn];
        
        {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.size = entryImageView.size;
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self action:@selector(doShowCommentAction:) forControlEvents:UIControlEventTouchUpInside];
            [containerView addSubview:button];
        }
    }
}

@end
