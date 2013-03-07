//
//  VCTimeLineViewController.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/06/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCTimeLineViewController.h"
#import "VCTimeLineViewController+Header.h"
#import "VCTimeLineViewController+Footer.h"
#import "VCTimeLineViewController+TableView.h"
#import "VCTimeLineViewController+Request.h"
#import "VCTimeLineViewController+Sliding.h"
#import "VCTimeLineViewController+Action.h"
#import "VCTimeLineViewController+CoverImage.h"
#import "VCTimeLineViewController+Transition.h"
#import "VCTimeLineViewController+Comment.h"
#import "VCTimeLineViewController+Progress.h"
#import "VCTimeLineViewController+DoURL.h"
#import "VCTimeLineViewController+Photo.h"

#import "VCLoginViewController.h"


#import "UUImageLabelButton.h"


#import "FBDialog.h"

@interface VCTimeLineViewController ()

@end

@implementation VCTimeLineViewController

#pragma -
#pragma Notification

- (void) _willCommentRequest:(NSNotification*)notification
{
    SS_MLOG(self);
    NSDictionary* info = [notification object];
    NSString* objectID = info[@"objectID"];
    NSString* comment = info[@"comment"];
    
    if (NO == (self.stackModel.timeLineType == VCTimeLineTypeStream && [self.stackModel.ID isEqualToString:objectID])) return;
    if (self.stackModel.datas.count == 0) return;
    
    MMStatusModel* statusModel = self.stackModel.datas[0];
    [statusModel addComment:comment];
    [self reloadDataNeedCellUpdate:NO];
}

- (void) _didStatusRequest:(NSNotification*)notification
{
    SS_MLOG(self);
    NSDictionary* info = [notification object];
    NSString* objectID = info[@"objectID"];
    NSString* status = info[@"status"];
    
    if (self.stackModel.timeLineType != VCTimeLineTypeNews) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self requestNowAction:nil];
    });
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

- (void) didReceiveMemoryWarning
{
    SS_MLOG(self);
    [self didReceiveMemoryWarningForSliding];
    [super didReceiveMemoryWarning];    
}

- (void) dealloc
{
    SS_MLOG(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.stackUUIDs = [NSMutableArray array];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // strong view
    self.tableView = nil;
    self.viewForTableContainer = nil;
    self.buttonForMore = nil;    
    self.webViewController = nil;
}

- (void)viewDidLoad
{
    SS_MLOG(self); 
    
    __weak VCTimeLineViewController* _self = self;    
    
    [super viewDidLoad];
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // VCProgressViewController
    {
        VCProgressViewController* controller = [[VCProgressViewController alloc] init];
        controller.view.frame = self.view.bounds;
        [self.view addSubview:controller.view];        
        [controller setNavigationBar:self.navigationController.navigationBar];
        self.progressViewController = controller;
        controller.keyForNotification = NSStringFromClass([self class]);
    }

    ///////////////////////////////////////////////////////////////////////////////
    // Trasion Container
    {
        UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.view.bounds];
        view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        [self.view addSubview:view];
        self.viewForContainer = view;
    }
    {
        UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.viewForContainer.bounds];
        view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        [self.viewForContainer addSubview:view];
        self.viewForTableContainer = view;
    }

	// Do any additional setup after loading the view.
    [self viewDidLoadForHeader];
    [self viewDidLoadForFooter];
    [self viewDidLoadForCoverImage];
    [self viewDidLoadForComment];
    [self viewDidLoadForTableView];
    [self viewDidLoadForSliding];
    //--- [self viewDidLoadForProgress];
    //--- [self viewDidLoadForPhoto];
    
    if (self.stackModel == nil) {
        MMStackModel* stackModel = [[MMStackModel alloc] init];
        stackModel.objectType = @"news";
        self.stackModel = stackModel;
        [self.stackUUIDs addObject:stackModel.UUID];
    }

    [self updateHeaderTitle];
    [self updateHeaderButtons];

    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doTimeLineURL:) name:NFDoTimeLineURL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doReHeightTimeLineCell:) name:NFDoReHeightTimeLineCell object:nil]; 
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doShowSettingViewController:) name:NFDoShowSettingViewController object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doShowCommentViewController:) name:NFDoShowCommentViewController object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willCommentRequest:) name:NFWillCommentRequest object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didStatusRequest:) name:NFDidStatusRequest object:nil];
        
    }
    
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect frame = CGRectMake(0, 0, self.view.width, self.view.height-44.0f);
    self.viewForContainer.frame = frame;
    self.viewForTableContainer.frame = frame;    
    self.viewForFooter.top = self.viewForContainer.bottom;
    
    self.viewForComment.frame = CGRectMake(0, self.viewForTableContainer.height-40.0f, self.viewForTableContainer.width, 40.0f);
    
    if (self.stackModel.timeLineType == VCTimeLineTypeStream) {
        self.tableView.height = self.viewForTableContainer.height - self.viewForComment.height;
        self.viewForComment.hidden = NO;
        
    } else {
        self.tableView.height = self.viewForTableContainer.height;
        self.viewForComment.hidden = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    SS_MLOG(self);
    [super viewWillAppear:animated];
    
    ///////////////////////////////////////////////////////////////////////////////
    // Cover Image
    [self viewWillAppearForCoverImage];
    
    ///////////////////////////////////////////////////////////////////////////////
    // Facebook Session
    if (FBSession.activeSession.isOpen && self.stackModel.isRequested == NO) {
        [self requestNowAction:nil];
    }
    
    [self reloadDataNeedCellUpdate:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    SS_MLOG(self);
    [super viewDidAppear:animated];
    
    ///////////////////////////////////////////////////////////////////////////////
    // Facebook Login
    if (FBSession.activeSession.isOpen == NO) {
        [self performSegueWithIdentifier:@"SEGUE_LOGIN" sender:nil];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma -
#pragma UIViewController

- (VCDebugJSONViewController*) debugJSONViewController
{
    if (_debugJSONViewController == nil) {
        VCDebugJSONViewController* controller = [[VCDebugJSONViewController alloc] init];
        controller.view.size = CGSizeMake(self.view.width, 400);   
        self.debugJSONViewController = controller;
    }
    return _debugJSONViewController;    
}


#pragma -
#pragma Helper


// http://www.facebook.com/photo.php?fbid=138769959594743&set=a.135706693234403.25507.135695366568869&type=1
// http://www.facebook.com/events/238762892908354/

- (MMStatusModel*) __statusModelFromID:(NSString*)ID;
{
    if (ID == nil) return nil;
    
    MMStatusModel* statusModel = nil;
    for (MMStatusModel* _statusModel in self.stackModel.datas) {
        if ([_statusModel[@"id"] isEqualToString:ID]) {
            statusModel = _statusModel;
            break;
        }
    }
    return statusModel;
}


@end
