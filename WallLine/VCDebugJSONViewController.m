//
//  VCDebugJSONViewController.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/21.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCDebugJSONViewController.h"

@interface NSString (HOGE)
+ (NSString*) stringByWhiteSpace:(NSUInteger)count;
@end

@implementation NSString (HOGE)

+ (NSString*) stringByWhiteSpace:(NSUInteger)count;
{
    NSMutableString* s = [NSMutableString string];
    for (NSUInteger i = 0; i < count; i++) {
        [s appendString:@"    "];
    }
    return s;
}

@end

@interface VCDebugJSONViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray* items;
@property (weak, nonatomic) UITableView* tableView;
@end

@implementation VCDebugJSONViewController
/*
@synthesize statusModel = _statusModel;
@synthesize tableView = _tableView;
@synthesize items = _items;
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) prase:(id)obj key:(NSString*)key items:(NSMutableArray*)items indent:(NSUInteger)indent
{
    if ([obj isKindOfClass:[NSString class]]) {

        NSString* s = [NSString stringWithFormat:@"%@[%@] = [%@]", [NSString stringByWhiteSpace:indent], key, obj];
        [items addObject:s];

    } else if ([obj isKindOfClass:[NSNumber class]]) {
        NSNumber* n = obj;
        NSString* s = [NSString stringWithFormat:@"%@[%@] = [%@]", [NSString stringByWhiteSpace:indent], key, [n description]];
        [items addObject:s];

    } else if ([obj isKindOfClass:[NSDate class]]) {
        NSDate* n = obj;
        NSString* s = [NSString stringWithFormat:@"%@[%@] = [%@]", [NSString stringByWhiteSpace:indent], key, [n description]];
        [items addObject:s];

    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        if (key) {
            NSString* s = [NSString stringWithFormat:@"%@[%@] {}", [NSString stringByWhiteSpace:indent], key];
            [items addObject:s];
        }
        NSDictionary* d = obj;        
        for (NSString* _key in d.allKeys) {
            id _obj = [d objectForKey:_key];
            [self prase:_obj key:_key items:items indent:indent+1];
        }
    } else if ([obj isKindOfClass:[NSArray class]]) {
        if (key) {
            NSString* s = [NSString stringWithFormat:@"%@[%@] []", [NSString stringByWhiteSpace:indent], key];
            [items addObject:s];
        }
        NSArray* a = obj;
        for (id _obj in a) {
            [self prase:_obj key:key items:items indent:indent+1];
        }

    } else if ([obj isKindOfClass:[NSValue class]]) {
        // CGSize For Photo
        
    } else {
        SSLog(@"%@ %@", NSStringFromClass([obj class]), [obj description]);
    
    }
}

- (void) setStatusModel:(MMStatusModel *)statusModel
{
    _statusModel = statusModel;
    self.items = [NSMutableArray array];
    [self prase:statusModel.data key:nil items:self.items indent:-1];    
}
    

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //self.view.frame = CGRectMake(0, 0, self.view.width, 320); 
}
    
- (void) viewWillAppear:(BOOL)animated  
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
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
    return 22.0f;
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
        cell.textLabel.font = [UIFont systemFontOfSize:11];
    }
    
    NSString* s = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = s;
    return cell;
}

@end
