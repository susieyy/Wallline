//
//  VCSettingViewController.m
//  Forever
//
//  Created by 杉上 洋平 on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VCSettingViewController.h"
#import "VCPermissionsViewController.h"

@interface VCSettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) NSUInteger pageIndex;
@property (weak, nonatomic) UIBlockView* headerView;
@property (weak, nonatomic) UITableView* tableView;
@property (weak, nonatomic) UIBlockButton* buttonForSetting;
@property (weak, nonatomic) UIBlockButton* buttonForAbout;
@end

#import "VCLicenseViewController.h"
#import "VCCreditViewController.h"

#import "UUSettingShareCell.h"

#import "SSLicenseManager.h"
#import "SSCreditManager.h"
#import "UUImageLabelButton.h"

#define WIDTH_BUTTON 120

//---------------------------------
#define PAGE_SETTING 0 

#define SECTION_REVIEW 0
#define SECTION_SOCIAL_ACCOUNT 1
#define SECTION_URL_SCHEME 2
//---------------------------------
#define PAGE_ABOUT 1

#define SECTION_ABOUT 0
#define ROW_VERSION 0
#define ROW_BUILD_NUMBER 1
#define ROW_LOCALE 2

#define SECTION_CREDIT 1
#define SECTION_LICENSE 2
//---------------------------------


@implementation VCSettingViewController

- (IBAction)close:(id)sender;
{
    SS_MLOG(self);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}   

- (void) dealloc
{
    SS_MLOG(self);
    [[SSStatsBarOverlay sharedManager] postMessage:[NSString stringWithFormat:@"[dealloc] %@", NSStringFromClass([self class])]];    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of     
}


- (void) viewDidLoad
{
    SS_MLOG(self);
    
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Setting", @"");
    self.view.backgroundColor = HEXCOLOR(0x333333);
    
    __weak VCSettingViewController* _self = self;
        
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
    // Header
    {
        CGRect frame = CGRectMake(0, 0, self.view.width, 44.0f);
        UIView* view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = HEXCOLOR(0x333333);
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:view];
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Table
    {
        CGRect frame = CGRectMake(0, 44.0f, self.view.width, self.view.height-44.0f);
        UITableView* view = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.delegate = self;
        view.dataSource = self;
        [self.view addSubview:view];
        self.tableView = view;
    }
    ///////////////////////////////////////////////////////////////////////////////
    //
    {
        UIFont* font = [UIFont fontWithName:@"Verdana-Bold" size:16];
        UIImage* image = [[UIImage imageNamed:@"setting.png"] imageAsResizeTo:CGSizeMake(18, 18)];
        CGRect frame = CGRectMake(0, 0, WIDTH_BUTTON, 44);
        UIBlockButton* button = [UIBlockButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        button.showsTouchWhenHighlighted = YES;
        button.selected = YES;
        button.blockAction = ^(UIButton* _button) {
            _self.pageIndex = PAGE_SETTING;
            [_self.tableView reloadData];
            [_button setSelected:YES];
            [_self.buttonForAbout setSelected:NO];            
        };
        button.blockDrawRect = ^(CGContextRef context, UIView* view, CGRect rect) {
            UIColor* color = nil;
            if (button.selected) {
                color = COLOR_FOR_SELECT;
            } else {
                color = HEXCOLOR(0x999999);                    
            }
            //CGContextSetShadowWithColor(context, CGSizeMake(0.5, 0.5), 1.0, HEXCOLOR(0xFFFFFF).CGColor);             
            {
                CGRect frame = CGRectMake(6, (rect.size.height - image.size.height)/2, image.size.width, image.size.height);
                CGContextDrawImage(context, frame, [image imageAsMaskedColor:color].CGImage);
            }
            {
                CGContextSetFillColorWithColor(context, color.CGColor); 
                [NSLocalizedString(@"Setting", @"") drawAtPoint:CGPointMake(28, 12.0f) withFont:font];   
            }
        };
        [self.view addSubview:button];        
        self.buttonForSetting = button;        
    }
    ///////////////////////////////////////////////////////////////////////////////
    //
    {
        UIFont* font = [UIFont fontWithName:@"Verdana-Bold" size:16];
        UIImage* image = [[UIImage imageNamed:@"setting.png"] imageAsResizeTo:CGSizeMake(18, 18)];
        CGRect frame = CGRectMake(WIDTH_BUTTON, 0, WIDTH_BUTTON, 44);
        UIBlockButton* button = [UIBlockButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        button.showsTouchWhenHighlighted = YES;        
        button.blockAction = ^(UIButton* _button) {
            _self.pageIndex = PAGE_ABOUT;
            [_self.tableView reloadData];
            [_button setSelected:YES];
            [_self.buttonForSetting setSelected:NO];
        };
        button.blockDrawRect = ^(CGContextRef context, UIView* view, CGRect rect) {
            UIColor* color = nil;
            if (button.selected) {
                color = COLOR_FOR_SELECT;
            } else {
                color = HEXCOLOR(0x999999);                    
            }
            //CGContextSetShadowWithColor(context, CGSizeMake(0.5, 0.5), 1.0, HEXCOLOR(0xFFFFFF).CGColor);             
            {
                CGRect frame = CGRectMake(6, (rect.size.height - image.size.height)/2, image.size.width, image.size.height);
                CGContextDrawImage(context, frame, [image imageAsMaskedColor:color].CGImage);
            }
            {
                CGContextSetFillColorWithColor(context, color.CGColor); 
                [NSLocalizedString(@"About", @"") drawAtPoint:CGPointMake(28, 12.0f) withFont:font];   
            }
        };
        
        [self.view addSubview:button];        
        self.buttonForAbout = button;        
    }
        
    ///////////////////////////////////////////////////////////////////////////////
    // Close Button
    {
        UINavigationBar* navigationBar = self.navigationController.navigationBar;
        navigationBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction) dismissModalViewAction:(id)sender
{
    [self.view removeAllSubviews];
    [super dismissModalViewAction:sender];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.pageIndex == PAGE_SETTING) return 3;
    if (self.pageIndex == PAGE_ABOUT) return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.pageIndex == PAGE_SETTING) {
        if (section == SECTION_REVIEW) return 1;            
        if (section == SECTION_SOCIAL_ACCOUNT) return 2;
        if (section == SECTION_URL_SCHEME) return 2;
    }
    if (self.pageIndex == PAGE_ABOUT) {
        if (section == SECTION_ABOUT) return 3;    
        if (section == SECTION_CREDIT)  return [[[SSCreditManager sharedManager] credits] count];         
        if (section == SECTION_LICENSE) return [[[SSLicenseManager sharedManager] licenses] count]; 
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.pageIndex == PAGE_SETTING) {    
        if (section == SECTION_REVIEW) return NSLocalizedString(@"iTunesStroe", @"");
        if (section == SECTION_SOCIAL_ACCOUNT) return NSLocalizedString(@"Social Account", @"");
        if (section == SECTION_URL_SCHEME) return NSLocalizedString(@"URL Scheme", @"");         
    }
    if (self.pageIndex == PAGE_ABOUT) { 
        if (section == SECTION_ABOUT) return NSLocalizedString(@"App", @"");  
        if (section == SECTION_CREDIT) return NSLocalizedString(@"Credit", @"");          
        if (section == SECTION_LICENSE) return NSLocalizedString(@"License", @"");  
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.pageIndex == PAGE_SETTING) {        
        if (indexPath.section == SECTION_REVIEW) {
            NSString* identifier = @"UITableViewCellStyleDefault";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.imageView.image = [[UIImage imageNamed:@"app_store_icon"] imageAsResizeTo:CGSizeMake(28, 28)];
            cell.textLabel.font = [UIFont systemFontOfSize:14];            
            cell.textLabel.text = NSLocalizedString(@"Please review us on iTunes", @"");            
            cell.textLabel.textColor = HEXCOLOR(0x333333);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        if (indexPath.section == SECTION_SOCIAL_ACCOUNT) {   
            if (indexPath.row == 0) {
                FBSession* session = FBSession.activeSession;
                
                UUSettingShareCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UUCaptionViewCell"];
                if (cell == nil) {
                    cell = [[UUSettingShareCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UUCaptionViewCell"];            
                }      
                
                cell.labelForTitle.text = @"";
                BOOL flg = [session isOpen];
                [cell setEnable:flg];
                if (flg) {
                    cell.labelForUserName.text = [[MMMeModel sharedManager] objectForKey:@"name"];
                } else {
                    cell.labelForUserName.text = @"";
                }
                
                return cell;
            } else if (indexPath.row == 1) {
                NSString* identifier = @"UITableViewCellStyleDefaultPermissions";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
                }
                cell.textLabel.text = [NSString stringWithFormat:@"    %@", NSLocalizedString(@"Permissions", @"")];
                cell.textLabel.font = [UIFont systemFontOfSize:13];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
        }
        if (indexPath.section == SECTION_URL_SCHEME) {        
            NSString* identifier = @"UITableViewCellStyleSubtitle";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            }

            cell.textLabel.font = [UIFont systemFontOfSize:14];    
            cell.detailTextLabel.font = [UIFont systemFontOfSize:10];                
            cell.textLabel.textColor = HEXCOLOR(0x333333);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (indexPath.row == 0) {       
                UIImage* image = [[UIImage imageNamed:@"Icon"] imageAsResizeTo:CGSizeMake(28, 28)];
                cell.imageView.image = image;
                cell.imageView.layer.masksToBounds = YES;
                cell.imageView.layer.cornerRadius = 6.0f;
                
                cell.textLabel.text = NSLocalizedString(@"Save Icon to PhotoAlbum", @"");
                cell.detailTextLabel.text = nil;
                
            } else if (indexPath.row == 1) {            
                UIImage* image = [[UIImage imageNamed:@"url"] imageAsResizeTo:CGSizeMake(28, 28)];                
                cell.imageView.image = image;
                
                cell.textLabel.text = @"wallline://";
                cell.detailTextLabel.text = NSLocalizedString(@"Open the Wallline", @"");
                
            }
            return cell;

        }
    }
    ///////////////////////////////////////////////////////////////////////////////
    
    if (self.pageIndex == PAGE_ABOUT) {
        UITableViewCell *cell = nil;
        if (indexPath.section == SECTION_ABOUT) {        
            NSString* identifier = @"UITableViewCellStyleValue1";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];            
            }
        } else {
            NSString* identifier = @"UITableViewCellStyleDefault";
            cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];            
            }            
        }
        
        cell.textLabel.textColor = HEXCOLOR(0x333333);
        cell.textLabel.font = [UIFont systemFontOfSize:14];        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.imageView.image = nil;
        cell.accessoryView = nil;
        
        if (indexPath.section == SECTION_ABOUT) {
            cell.accessoryType = UITableViewCellAccessoryNone;        
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (indexPath.row == ROW_VERSION) {
                NSString *version = [[UIApplication sharedApplication] version];            
                cell.textLabel.text = NSLocalizedString(@"Version", @"");                   
                cell.detailTextLabel.text = version;
            }
            if (indexPath.row == ROW_BUILD_NUMBER) {
                NSString *version = [[UIApplication sharedApplication] buildNumber];            
                cell.textLabel.text = NSLocalizedString(@"Build Number", @"");                   
                cell.detailTextLabel.text = version;
            }            
            if (indexPath.row == ROW_LOCALE) {
                NSString* lang = [[NSLocale localeCurrentProfile] valueForKey:@"displayName"];
                cell.textLabel.text = NSLocalizedString(@"Locale", @"");                   
                cell.detailTextLabel.text = lang;
            }
        }
        
        if (indexPath.section == SECTION_CREDIT) {
            NSString* text = [[[SSCreditManager sharedManager] credits] objectAtIndex:indexPath.row];
            text = [text stringByReplacingRegexPattern:@".Credit$" withString:@""];
            cell.textLabel.text = text;        
            
        }
        
        if (indexPath.section == SECTION_LICENSE) {
            NSString* text = [[[SSLicenseManager sharedManager] licenses] objectAtIndex:indexPath.row];
            text = [text stringByReplacingRegexPattern:@".License$" withString:@""];
            cell.textLabel.text = text;        
            
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak VCSettingViewController* _self = self;
    
    if (self.pageIndex == PAGE_SETTING) { 
        if (indexPath.section == SECTION_REVIEW) {
            // TODO:
            // [Appirater rateApp];  
        }
        
        if (indexPath.section == SECTION_SOCIAL_ACCOUNT)  {   
            if (indexPath.row == 0) {
                // Logout
                FBSession* session = FBSession.activeSession;
                /*
                [service actionInView:self.view completionBlock:^(){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [_self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }];	
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        if ([[SVFacebookService service] isEnable] == NO) {
                            // Did Logout
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NFDidLogout object:nil userInfo:nil];                        
                        } else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:NFDidLogin object:nil userInfo:nil];   
                        }
                    }];	
                }];
                */
            } else if (indexPath.row == 1) {
                VCPermissionsViewController* contoller = [[VCPermissionsViewController alloc] init];
                [self.navigationController pushViewController:contoller animated:YES];
            }

        }
        
        if (indexPath.section == SECTION_URL_SCHEME)  {   
            if (indexPath.row == 0) {
                UIImage* image = [UIImage imageNamed:@"Icon.png"];
                [image writeToSavedPhotosAlbum];
                
                [UIAlertView showWithTitle:NSLocalizedString(@"Finish save to album", @"")];
                
            } else if (indexPath.row == 1) {
                UIPasteboard* board = [UIPasteboard generalPasteboard];
                [board setString:@"wallline://"];
                
                [UIAlertView showWithTitle:NSLocalizedString(@"Finish copy to pasteboard", @"")];                
                
            }
        }
    }
    if (self.pageIndex == PAGE_ABOUT) {        
        if (indexPath.section == SECTION_ABOUT) return;
        
        if (indexPath.section == SECTION_CREDIT) {
            VCCreditViewController* controller = [[VCCreditViewController alloc] init];
            controller.creditFileName = [[[SSCreditManager sharedManager] credits] objectAtIndex:indexPath.row];
            controller.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
            [self.navigationController pushViewController:controller animated:YES];
        }
        
        if (indexPath.section == SECTION_LICENSE) {
            VCLicenseViewController* controller = [[VCLicenseViewController alloc] init];
            controller.liceseFileName = [[[SSLicenseManager sharedManager] licenses] objectAtIndex:indexPath.row];
            controller.contentSizeForViewInPopover = self.contentSizeForViewInPopover;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
