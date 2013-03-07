//
//  VCNotificationViewController.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/23.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCNotificationViewController.h"
#import "ECSlidingViewController.h"
#import "UUNotificationCell.h"
#import "UUFriendRequestCell.h"
#import "ODRefreshControl.h"

#import "VCTimeLineViewController.h"


#define kRevealAmount 260.0f
#define SECTION_FRIEND_REQUEST 0
#define SECTION_NOTIFICATION 1
#define LIMIT_SHOW_FRIEND_REQUEST 5
#define HEIGHT_FOR_SECTION 24.0f

@interface VCNotificationViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView* tableView;
@property (weak, nonatomic) UIView* viewForHeader;
@property (weak, nonatomic) ODRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray* itemsForNotification;
@property (strong, nonatomic) NSMutableArray* itemsForFriendRequest;
@property (strong, nonatomic) NSMutableArray* idsForNotNow;
@property (strong, nonatomic) FBRequestConnection* requestConnection;

@property (nonatomic) BOOL isShowAllFriendRequest;
@end

@implementation VCNotificationViewController

#pragma -
#pragma Action

- (void) tapMoreAction:(id)sender
{
    self.isShowAllFriendRequest = YES;
    [self reloadData];
}

- (void) _confirmFriendRequest:(NSNotification*)notification
{
    NSString* userID = [notification object];
    __weak VCNotificationViewController* _self = self;
    [[MMFacebookManager sharedManager] requestFriend:userID completionBlock:^(NSError *error) {
        if (error) {
            [UIAlertView showWithError:error];
            
        } else {
            NSMutableArray* items = [NSMutableArray arrayWithArray:[_self unarchiveDatasForFriendRequest]];
            for (MMFriendRequestModel* model in [items copy]) {
                NSString* ID = model[@"from"][@"id"];
                if ([userID isEqualToString:ID]) {
                    [items removeObject:model];
                }
            }
            _self.itemsForFriendRequest = items;
            [_self reloadData];
        }
    }];
}

- (void) _notNowFriendRequest:(NSNotification*)notification
{
    NSString* userID = [notification object];
    NSMutableArray* ids = [NSMutableArray arrayWithArray:[self unarchiveDatasForNotNow]];
    if ([ids containsObject:userID]) return;
    [ids addObject:userID];
    [self archiveDatasForNotNow:ids];
    
    [self setItemsForFriendRequest:self.itemsForFriendRequest];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}

- (void) cancelAllRequest;
{
    SS_MLOG(self);
    [self.requestConnection cancel];
    
    for (UITableViewCell* _cell in [self.tableView visibleCells]) {
        if ([_cell respondsToSelector:@selector(cancelRequest)]) {
            [_cell performSelector:@selector(cancelRequest)];
        }
    }
}


- (IBAction)close:(id)sender
{
    SS_MLOG(self);
    __weak VCNotificationViewController* _self = self;
    
    [self cancelAllRequest];
    [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:nil onComplete:^{
        [_self.slidingViewController resetTopView];
    }];    
}

- (void) reloadData;
{
    SS_MLOG(self);
    
    /*
    MMFriendRequestModel* model = self.itemsForFriendRequest[0];
    for (NSUInteger i = 0; i< 10; i++) {
        [self.itemsForFriendRequest addObject:model];
    }
    */
    
    [self.tableView reloadData];
}

- (void) setItemsForFriendRequest:(NSMutableArray *)itemsForFriendRequest
{
    NSArray* ids = [self unarchiveDatasForNotNow];
    for (MMFriendRequestModel* model in [itemsForFriendRequest copy]) {
        NSString* ID = model[@"from"][@"id"];
        if ([ids containsObject:ID]) {
            [itemsForFriendRequest removeObject:model];
        }
    }
    _itemsForFriendRequest = itemsForFriendRequest;
}

#pragma -
#pragma Archive Notification

- (void) archiveDatasForNotification:(NSArray*)datas;
{
    SS_MLOG(self);
    if (datas == nil) return;
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"notifications.dat"];
    [NSKeyedArchiver archiveRootObject:datas toFile:path];
}

- (NSArray*) unarchiveDatasForNotification;
{
    SS_MLOG(self);    
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"notifications.dat"];
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (array == nil) array = @[];
    return array;
}

#pragma -
#pragma Archive FriendRequest

- (void) archiveDatasForFriendRequest:(NSArray*)datas;
{
    SS_MLOG(self);
    if (datas == nil) return;
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"friendrequests.dat"];
    [NSKeyedArchiver archiveRootObject:datas toFile:path];
}

- (NSArray*) unarchiveDatasForFriendRequest;
{
    SS_MLOG(self);
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"friendrequests.dat"];
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (array == nil) array = @[];
    return array;
}

#pragma -
#pragma Archive NotNow FriendRequest

- (void) archiveDatasForNotNow:(NSArray*)datas;
{
    SS_MLOG(self);
    if (datas == nil) return;
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"notnows.dat"];
    [NSKeyedArchiver archiveRootObject:datas toFile:path];
}

- (NSArray*) unarchiveDatasForNotNow;
{
    SS_MLOG(self);
    NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"notnows.dat"];
    NSArray* array = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (array == nil) array = @[];
    return array;
}

#pragma -
#pragma

- (void) requestNotificationCompletionBlock:(SSBlockError)completionBlock
{
    SS_MLOG(self);
    __weak VCNotificationViewController* _self = self;
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] initWithTimeout:FACEBOOK_REQUEST_TIMEOUT];

    ///////////////////////////////////////////////////////////////////////////////
    // FriendRequests
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
        params[@"locale"] = locale;
        NSString* graphPath = @"me/friendrequests";        
        FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                SSLog([results description]);
                if (error == nil) {
                    NSDictionary* dict = results;
                    NSArray* datas = dict[@"data"];
                    [_self archiveDatasForFriendRequest:datas];

                    NSMutableArray* items = [NSMutableArray array];
                    for (NSDictionary* data in datas) {
                        MMFriendRequestModel* model = [[MMFriendRequestModel alloc] initWithData:data];
                        [items addObject:model];
                    }
                    _self.itemsForFriendRequest = items;
                }
            });
        };
        
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block];
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Notification
    {
        NSMutableDictionary* params = [NSMutableDictionary dictionary];
        params[@"q"] = @"SELECT notification_id,sender_id,object_type,title_html,body_text,href,is_unread,is_hidden,updated_time FROM notification WHERE recipient_id = me() LIMIT 25";
        NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];    
        params[@"locale"] = locale;
        
        //[params setValue:@"25" forKey:@"limit"];
        //[params setValue:@"1" forKey:@"include_read"];
        
        NSString* graphPath = @"fql";
        //NSString* graphPath = @"me/notifications";
        
        FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                SSLog([results description]);
                if (error) {
                    
                } else {
                    NSDictionary* dict = results;
                    NSArray* datas = dict[@"data"];
                    [_self archiveDatasForNotification:datas];
                    
                    NSMutableArray* items = [NSMutableArray array];
                    for (NSDictionary* data in datas) {
                        MMFQLNotificationModel* model = [[MMFQLNotificationModel alloc] initWithData:data];
                        [items addObject:model];                    
                    }
                    _self.itemsForNotification = items;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completionBlock) completionBlock(error);      
                    _self.requestConnection = nil;
                });           
            });
        };
        
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
        [requestConnection addRequest:request completionHandler:block];
    }
    
    
    [requestConnection start];
    self.requestConnection = requestConnection;
    SSLog(@"    NOTIFICATION/FRIENDREQUESTS URL [%@]", [requestConnection.urlRequest URL]);        
}    


#pragma -
#pragma 


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma -
#pragma MemoryWarning

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    SS_MLOG(self);
    if (self.requestConnection) {
        [self.requestConnection cancel];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
    [self.tableView removeObserver:self.refreshControl forKeyPath:@"contentOffset" context:nil];
    
    [[SSStatsBarOverlay sharedManager] postMessage:[NSString stringWithFormat:@"[dealloc] %@", NSStringFromClass([self class])]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(close:) name:NFCloseVCNotificationViewController object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_confirmFriendRequest:) name:NFConfirmFriendRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_notNowFriendRequest:) name:NFNotNowFriendRequest object:nil];
    
    ///////////////////////////////////////////////////////////////////////////////
    // SlidingView
    {
        [self.slidingViewController setAnchorLeftRevealAmount:kRevealAmount];
        self.slidingViewController.underRightWidthLayout = ECFullWidth;
    }
    
    self.view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
    
    ///////////////////////////////////////////////////////////////////////////////
    // TableView
    {
        UITableView* view = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        view.delegate = self;
        view.dataSource = self;
        view.allowsSelection = YES;
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        view.backgroundColor = self.view.backgroundColor;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;            
        [self.view addSubview:view];
        self.tableView = view;
    }    
    ///////////////////////////////////////////////////////////////////////////////
    // Footer
    {
        CGRect frame = CGRectMake(0, 0, self.view.width, 1.0f);
        UIView* view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = HEXCOLOR(0x1B2230);
        self.tableView.tableFooterView = view;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // ODRefreshControl
    {
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;        
    }
    self.itemsForNotification = [NSMutableArray array];

    
    
    UIView* viewForTarget = nil;        
    ///////////////////////////////////////////////////////////////////////////////
    // Title
    {
        CGRect frame = CGRectMake(0, 0, self.view.width, 44.0f);
        UIView* view = [[UIView alloc] initWithFrame:frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        view.backgroundColor = HEXCOLOR(0x1D232C); 
        [self.view addSubview:view];       
        self.viewForHeader = view;
        viewForTarget = view;
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Title
    {
        CGRect frame = CGRectMake(self.view.width-kRevealAmount, 0.0f, kRevealAmount, 44.0f);
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = HEXCOLOR(0xFFFFFF);
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        label.backgroundColor = HEXCOLOR(0x1D232C); 
        label.shadowColor = HEXCOLOR(0x999999);
        label.shadowOffset = CGSizeMake(0, 0);
        label.text = NSLocalizedString(@"Notification", @"");
        label.userInteractionEnabled = YES;
        [viewForTarget addSubview:label];       
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Header shadow
    {
        CGRect frame = CGRectMake(0, viewForTarget.bottom, viewForTarget.width, 10.0f);
        UIImage *image = [UIImage imageNamed:@"shadow_10x10.png"];
        UIBlockView* view = [[UIBlockView alloc] initWithFrame:frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        view.backgroundColor = [UIColor clearColor];
        view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
            SSContextFlip(context, _view.size);
            CGContextDrawTiledImage(context, CGRectOfSize(image.size), image.CGImage);
        };
        [view setNeedsDisplay];
        [viewForTarget addSubview:view];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    ///////////////////////////////////////////////////////////////////////////////
    // UnArchive Notification
    {
        NSMutableArray* items = [NSMutableArray array];
        NSArray* datas = [self unarchiveDatasForNotification];
        for (NSDictionary* data in datas) {
            MMFQLNotificationModel* model = [[MMFQLNotificationModel alloc] initWithData:data];
            [items addObject:model];                    
        }
        self.itemsForNotification = items;
    }
    ///////////////////////////////////////////////////////////////////////////////
    // UnArchive Notification
    {
        NSMutableArray* items = [NSMutableArray array];
        NSArray* datas = [self unarchiveDatasForFriendRequest];
        for (NSDictionary* data in datas) {
            MMFriendRequestModel* model = [[MMFriendRequestModel alloc] initWithData:data];
            [items addObject:model];
        }
        self.itemsForFriendRequest = items;
    }
    [self reloadData];
}

- (void) viewDidAppear:(BOOL)animated   
{
    [super viewDidAppear:animated];
    if (self.itemsForNotification.count == 0) {
        [self.refreshControl beginRefreshing];
        [self dropViewDidBeginRefreshing:self.refreshControl];    
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    ///////////////////////////////////////////////////////////////////////////////
    // Archive Notification Unread
    {
        NSArray* datas = [self unarchiveDatasForNotification];
        NSMutableArray* newdatas = [NSMutableArray array];
        NSUInteger countForNeedRequest = 0;
        for (NSDictionary* _data in datas) {
            NSMutableDictionary* data = [NSMutableDictionary dictionaryWithDictionary:_data];
            NSUInteger isUnread = [data[@"is_unread"] integerValue];
            if (isUnread == 1) {
                countForNeedRequest++;
                NSString* ID = data[@"notification_id"];
                SSLog([data description]);
                [[MMRequestManager sharedManager] doReadNotification:ID];
            }
            data[@"is_unread"] = @0;
            [newdatas addObject:data];
        }
        [self archiveDatasForNotification:newdatas];
        
        if (countForNeedRequest > 0) {
            [[MMRequestManager sharedManager] doRequestNow];
        }
        
        {
            NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:0 forKey:@"countForUnreadNotification"];
            [userDefaults setInteger:0 forKey:@"countForUnreadFriendRequest"];
            [userDefaults synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:NFDidNotificationOrFriendRequest object:nil userInfo:nil];
        }
    }
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(self.view.width-kRevealAmount, 44.0f, kRevealAmount, self.view.height-44.0f);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -
#pragma ODRefreshControl

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    __weak VCNotificationViewController* _self = self;
    [self requestNotificationCompletionBlock:^(NSError* error) {
        SSLog(@"CompletionBlock");
        [_self.refreshControl endRefreshing];
        
        if (error) {
            // TODO:
        } else {
            [_self reloadData]; // Lock self
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0) return HEIGHT_FOR_SECTION;
    
    if (indexPath.section == SECTION_FRIEND_REQUEST) {
        return [UUFriendRequestCell heightFromData:nil];
        
    } else if (indexPath.section == SECTION_NOTIFICATION) {
        NSUInteger index = indexPath.row-1;
        MMFQLNotificationModel* data = self.itemsForNotification[index];
        return [UUNotificationCell heightFromData:data];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_FRIEND_REQUEST) {
        if (self.itemsForFriendRequest.count > LIMIT_SHOW_FRIEND_REQUEST) {
            if (self.isShowAllFriendRequest) {
                return self.itemsForFriendRequest.count + 1;
            } else {
                return LIMIT_SHOW_FRIEND_REQUEST+1;
            }
        } else {
            return self.itemsForFriendRequest.count + 1;
        }
        
    } else if (section == SECTION_NOTIFICATION) {
        return self.itemsForNotification.count + 1;
    }
}

#pragma -
#pragma Header

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
    if (section == SECTION_FRIEND_REQUEST) {
        return 30.0f;
    }
    return 0.0f;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
{
    if (section == SECTION_FRIEND_REQUEST) {
        CGRect frame = CGRectMake(0, 0, self.view.width, 30.0f);
        UILabel* view = [[UILabel alloc] initWithFrame:frame];
        view.backgroundColor = HEXCOLOR(0x1B2230);
        view.font = [UIFont boldSystemFontOfSize:12];
        view.textColor = HEXCOLOR(0xCCCCCC);
        view.textAlignment = UITextAlignmentCenter;
        
        NSString* path = [[UIApplication pathForDocuments] stringByAppendingPathComponent:@"notifications.dat"];
        NSDictionary* info = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        if (info) {
            NSDate* date = [info fileModificationDate];
            NSDateFormatter* df = [[NSDateFormatter alloc] init];
            [df setDateStyle:NSDateFormatterShortStyle];
            [df setTimeStyle:NSDateFormatterShortStyle];
            view.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Last Updated", @""), [df stringFromDate:date]];
        }
        
        return view;
    }
    return nil;
}

#pragma -
#pragma Footer

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
{
    if (section == SECTION_FRIEND_REQUEST) {
        if (self.itemsForFriendRequest.count > LIMIT_SHOW_FRIEND_REQUEST && self.isShowAllFriendRequest == NO) {
            UIView* viewForFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0f)];
            viewForFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            viewForFooter.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
            UIButton* button = nil;
            {       
                button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = viewForFooter.bounds;
                button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [button addTarget:self action:@selector(tapMoreAction:) forControlEvents:UIControlEventTouchUpInside];
                [viewForFooter addSubview:button];
                
                NSUInteger count = self.itemsForFriendRequest.count - LIMIT_SHOW_FRIEND_REQUEST;
                NSString* title = [NSString stringWithFormat:@"%@ %d %@", NSLocalizedString(@"More", @""), count, NSLocalizedString(@"users", @"")];
                [button setTitle:title forState:UIControlStateNormal];
                
                {
                    UIImage* image = [UIImage imageWithSize:CGSizeMake(10, 10) color:HEXCOLOR(0x333947)];
                    [button setBackgroundImage:image forState:UIControlStateNormal];
                    [button setTitleColor:HEXCOLOR(0xCCCCCC) forState:UIControlStateNormal];
                    
                }
                {
                    UIImage* image = [UIImage imageWithSize:CGSizeMake(10, 10) color:COLOR_FOR_BACKGROUND_SELECT];
                    [button setBackgroundImage:image forState:UIControlStateHighlighted];
                    [button setTitleColor:HEXCOLOR(0x2B4584) forState:UIControlStateHighlighted];
                    [button setTitleShadowColor:HEXCOLOR(0xCCCCCC) forState:UIControlStateHighlighted];
                }
                
                UILabel* label = button.titleLabel;
                label.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
                //self.buttonForMore = button;
            }

            
            // TopLine
            {
                CGRect _frame = CGRectMake(0, 0, viewForFooter.width, 1.0f);
                UIView* view = [[UIView alloc] initWithFrame:_frame];
                view.backgroundColor = HEXCOLOR(0x1B2230);
                [viewForFooter addSubview:view];
            }

            return viewForFooter;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    if (section == SECTION_FRIEND_REQUEST) {
        if (self.itemsForFriendRequest.count > LIMIT_SHOW_FRIEND_REQUEST && self.isShowAllFriendRequest == NO) {
            return 44.0f;
        }
    }
    return 0.0f;
}

#pragma -
#pragma

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{        
    ///////////////////////////////////////////////////////////////////////////////
    // Header 
    if (indexPath.row == 0) {
        static NSString* Identifier = @"HeaderLabelCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = HEXCOLOR(0xCCCCCC);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            cell.contentView.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
            
            // TopLine
            {
                CGRect _frame = CGRectMake(0, 0, cell.contentView.width, 1.0f);
                UIView* view = [[UIView alloc] initWithFrame:_frame];
                view.backgroundColor = HEXCOLOR(0x1B2230);
                [cell.contentView addSubview:view];
            }
        }        
        if (indexPath.section == SECTION_FRIEND_REQUEST) {
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@", self.itemsForFriendRequest.count, NSLocalizedString(@"Friend Requsts", @"")];
        }
        if (indexPath.section == SECTION_NOTIFICATION) {
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@", self.itemsForNotification.count, NSLocalizedString(@"Notifications", @"")];
        }
        return cell;
    }

    if (indexPath.section == SECTION_FRIEND_REQUEST) {
        NSUInteger index = indexPath.row-1;
        MMFriendModel* data = self.itemsForFriendRequest[index];
        UUFriendRequestCell* cell = [UUFriendRequestCell cell:tableView];
        [cell setData:data];
        
        [[MMNameManager sharedManager] setValue:data[@"from"][@"name"] forKey:data[@"from"][@"id"]];
        return cell;
        
    } else if (indexPath.section == SECTION_NOTIFICATION) {
        NSUInteger index = indexPath.row-1;        
        MMFQLNotificationModel* data = self.itemsForNotification[index];
        UUNotificationCell* cell = [UUNotificationCell cell:tableView];
        [cell setData:data];
        SSLog(@"    TYPE [%@] HREF [%@]", data[@"object_type"], data[@"href"]);
        
        // Can't set value
        // [[MMNameManager sharedManager] setValue:data[@"sender_name"] forKey:data[@"sender_id"]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) return;
        
    __weak VCNotificationViewController* _self = self;        
    [self cancelAllRequest];

    NSURL* URL = nil;
    NSMutableDictionary* userInfo = nil;
    if (indexPath.section == SECTION_FRIEND_REQUEST) {
        NSUInteger index = indexPath.row-1;
        MMFriendRequestModel* data = self.itemsForFriendRequest[index];
        NSString* url = [NSString stringWithFormat:@"friend://%@", data[@"from"][@"id"]];
        URL = [NSURL URLWithString:url];        
        
    } else if (indexPath.section == SECTION_NOTIFICATION) {
        NSUInteger index = indexPath.row-1;
        MMFQLNotificationModel* data = self.itemsForNotification[index];
        NSString* url = data[@"href"];
        URL = [NSURL URLWithString:url];        
        SSLog(@"    HREF [%@]", data[@"href"]);  
        userInfo = @{ @"type":data[@"object_type"] };
    }
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:nil onComplete:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:userInfo];        
        [_self.slidingViewController resetTopView];
    }];

}

@end
