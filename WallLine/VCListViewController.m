//
//  VCListViewController.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/20.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCListViewController.h"

#import "VCListViewController+Footer.h"
#import "ECSlidingViewController.h"


#define kRevealAmount 260.0f

#define SECTION_LIST 0
#define SECTION_  1


@interface VCListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray* items;
@end

@implementation VCListViewController
/*
@synthesize tableView = _tableView;
@synthesize items = _items;
*/

- (void) reloadData;
{
    SS_MLOG(self);

    [CATransaction begin];
    [self.tableView reloadData];
    [CATransaction commit];        
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
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
    SS_MLOG(self);
    
    ///////////////////////////////////////////////////////////////////////////////
    // SlidingView
    {
        [self.slidingViewController setAnchorRightRevealAmount:kRevealAmount];
        self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // TableView
    {
        UITableView* view = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        view.delegate = self;
        view.dataSource = self;
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;            
        [self.view addSubview:view];
        self.tableView = view;
    }    
    
    self.items = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {            
        NSString* s = [NSString stringWithFormat:@"hoge %d", i];
        [self.items addObject:s];
    }
    
    [self viewDidLoadForFooter];
}


- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, self.view.width, self.view.height-44.0f);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadData];        
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString* title = nil;    
    if (section == SECTION_LIST) title = NSLocalizedString(@"List", @"");
    
    UIFont* font = [UIFont systemFontOfSize:14]; 
    CGRect frame = CGRectMake(0, 0, self.view.width, 22);
    UIBlockView* view = [[UIBlockView alloc] initWithFrame:frame];
    view.blockDrawRect = ^(CGContextRef context, UIView* view, CGRect rect){
        CGContextSetFillColorWithColor(context, HEXCOLOR(0x2F3547).CGColor);
        CGContextFillRect(context, rect);            
        
        CGContextSetLineWidth(context, 1.0f);            
        
        // Top Line            
        CGContextSetStrokeColorWithColor(context, HEXCOLOR(0x303544).CGColor);            
        CGContextMoveToPoint(context, 0.0f, 0.0f);
        CGContextAddLineToPoint(context, rect.size.width, 0.0f);
        CGContextStrokePath(context);         
        
        // Bottom Line
        CGContextSetStrokeColorWithColor(context, HEXCOLOR(0x19202A).CGColor);            
        CGContextMoveToPoint(context, 0.0f, rect.size.height);
        CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
        CGContextStrokePath(context);   
        
        // Text
        //        CGContextTranslateCTM(context, 0, rect.size.height);
        //      CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetFillColorWithColor(context, HEXCOLOR(0x777777).CGColor); 
        //        CGContextSetShadowWithColor(context, CGSizeMake(1.0, 1.0), 1.0, HEXCOLOR(0xFFFFFF).CGColor); 
        [title drawAtPoint:CGPointMake(8.0f, 2.0f) withFont:font];
        
    };
    [view setNeedsDisplay];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    static NSString *Identifier = @"UITableViewCellStyleDefault";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.textLabel.textColor = HEXCOLOR(0xCCCCCC);
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    NSString* s = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = s;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak VCListViewController* _self = self;    
    

    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        [self.slidingViewController resetTopView];
    }];
    

}


@end
