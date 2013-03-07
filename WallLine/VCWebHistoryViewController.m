//
//  VCWebHistoryViewController.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/24.
//
//

#import "VCWebHistoryViewController.h"




@interface VCWebHistoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView* tableView;
@end

@implementation VCWebHistoryViewController

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
   
    
    ///////////////////////////////////////////////////////////////////////////////
    // TableView
    {
        CGRect frame = CGRectMake(0, 44.0f, self.view.width, self.view.height-44.0f);
        UITableView* view = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        view.delegate = self;
        view.dataSource = self;
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:view];
        self.tableView = view;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Title
    {
        CGRect frame = CGRectMake(0.0f, 0.0f, self.view.width, 44.0f);
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = HEXCOLOR(0xFFFFFF);
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
        label.backgroundColor = HEXCOLOR(0x1D232C);
        label.shadowColor = HEXCOLOR(0x999999);
        label.shadowOffset = CGSizeMake(0, 0);
        label.text = NSLocalizedString(@"Web History", @"");
        label.userInteractionEnabled = YES;
        [self.view addSubview:label];
        
        ///////////////////////////////////////////////////////////////////////////////
        // Header shadow
        {
            CGRect frame = CGRectMake(0, label.bottom, label.width, 10.0f);
            UIImage *image = [UIImage imageNamed:@"shadow_10x10.png"];
            UIBlockView* view = [[UIBlockView alloc] initWithFrame:frame];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            view.backgroundColor = [UIColor clearColor];
            view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
                SSContextFlip(context, _view.size);
                CGContextDrawTiledImage(context, CGRectOfSize(image.size), image.CGImage);
            };
            [view setNeedsDisplay];
            [label addSubview:view];
        }
        
    }


}

- (void) dealloc
{
    [[SSStatsBarOverlay sharedManager] postMessage:[NSString stringWithFormat:@"[dealloc] %@", NSStringFromClass([self class])]];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.delegate viewDidDisappear];
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 44.0f, self.view.width, self.view.height-44.0f);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 44.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    UITableViewCell *cell = [UITableViewCell cellSubtitle:tableView blockDefaultCell:^(UITableViewCell *cell) {
        cell.textLabel.textColor = HEXCOLOR(0xCCCCCC);
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:9];
        
        cell.backgroundColor = self.tableView.backgroundColor;
        cell.contentView.backgroundColor = self.tableView.backgroundColor;
        
        CGRect frame = CGRectMake(0, cell.height-1.0f, cell.width, 1.0f);
        UIView* view = [[UIView alloc] initWithFrame:frame];
        view.backgroundColor = COLOR_FOR_BACKGROUND_DARK_TABLE;
        [cell.contentView addSubview:view];
        
    }];
    
    
    NSDictionary* userInfo = self.items[indexPath.row];
    cell.textLabel.text = userInfo[@"title"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", [userInfo[@"date"] stringRelativeDate], NSLocalizedString(@"ago", @"")];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary* userInfo = self.items[indexPath.row];
    [self.delegate doURLInfo:userInfo];
}


@end
