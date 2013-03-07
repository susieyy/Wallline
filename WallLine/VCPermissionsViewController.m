//
//  VCPermissionsViewController.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/02.
//
//


#import "VCPermissionsViewController.h"

#define SECTION_USER 0
#define SECTION_FRIENDS 1
#define SECTION_EXTENDED 2

@interface VCPermissionsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) FBRequestConnection* requestConnection;
@property (strong, nonatomic) NSMutableArray* items;
@property (weak, nonatomic) UITableView* tableView;
@end

@implementation VCPermissionsViewController

- (void) requestPermissionsCompletionBlock:(SSBlockError)completionBlock
{
    SS_MLOG(self);    
    __weak VCPermissionsViewController* _self = self;
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    NSString* locale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    [params setValue:locale forKey:@"locale"];
    
    FBRequestHandler block = ^(FBRequestConnection *connection, NSMutableDictionary<FBGraphUser> *results, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (error) {
                NSLog(@"[ERROR] [REQUEST] %@", [error localizedDescription]);
            } else {
                SSLog([results description]);
                _self.items = [[[results objectForKey:@"data"] objectAtIndexFirst] allKeys];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) completionBlock(error);
            });
        });
    };
    
    NSString* graphPath = @"me/permissions";
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession graphPath:graphPath parameters:params HTTPMethod:@"GET"];
    FBRequestConnection* requestConnection = [[FBRequestConnection alloc] init];
    [requestConnection addRequest:request completionHandler:block];
    [requestConnection start];
    self.requestConnection = requestConnection;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [self.requestConnection cancel];
    [[SSStatsBarOverlay sharedManager] postMessage:[NSString stringWithFormat:@"[dealloc] %@", NSStringFromClass([self class])]];        
}

- (void) reloadData
{
    //self.items = [self.items sortedArrayUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Permissions", @"");    
    
    ///////////////////////////////////////////////////////////////////////////////
    // Table
    {
        CGRect frame = self.view.bounds;
        UITableView* view = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.delegate = self;
        view.dataSource = self;
        [self.view addSubview:view];
        self.tableView = view;
    }

    [self requestPermissionsCompletionBlock:^(NSError *error) {
        if (error) {          
            return;
        }
        [self reloadData];
    }];
    
    self.items = [FBSession.activeSession permissions];
    [self reloadData];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -
#pragma UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (section == SECTION_USER) return @"User Permissions";
    if (section == SECTION_FRIENDS) return @"Friedns Permissions";
    if (section == SECTION_EXTENDED) return @"Extended Permissions";

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SECTION_USER) return self.permissionsForUser.count;
    if (section == SECTION_FRIENDS) return self.permissionsForFriends.count;
    if (section == SECTION_EXTENDED) return self.permissionsForExtended.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* items = nil;
    if (indexPath.section == SECTION_USER) items = self.permissionsForUser;
    if (indexPath.section == SECTION_FRIENDS) items = self.permissionsForFriends;
    if (indexPath.section == SECTION_EXTENDED) items = self.permissionsForExtended;
    
    NSString* _text = [items objectAtIndex:indexPath.row];
    NSString* text = [[_text stringByReplacingRegexPattern:@"_" withString:@" "] capitalizedString];
    
    NSString* identifier = @"UITableViewCellStyleDefault";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:identifier];
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.text = text;
    cell.detailTextLabel.textColor = HEXCOLOR(0x333333);

    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.textLabel.textColor = HEXCOLOR(0x000066);
    cell.textLabel.text = @"OFF";
    
    if ([self.items containsObject:_text]) {
        cell.textLabel.textColor = HEXCOLOR(0x660000);
        cell.textLabel.text = @"ON";
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma -
#pragma Permissions

- (NSArray*) permissionsForUser
{
    return [MMPermissionModel permissionsForUser];
}

- (NSArray*) permissionsForFriends
{
    return [MMPermissionModel permissionsForFriends];
}

- (NSArray*) permissionsForExtended
{
    return [MMPermissionModel permissionsForExtended];
}

@end
