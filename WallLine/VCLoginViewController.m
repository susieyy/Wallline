//
//  VCLoginViewController.m
//  Pickupps
//
//  Created by 杉上 洋平 on 12/05/27.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCLoginViewController.h"


@interface VCLoginViewController ()
@property (weak, nonatomic) UIButton* buttonForLogin;
@end

@implementation VCLoginViewController
@synthesize buttonForLogin = _buttonForLogin;

- (void) viewDidLoadForHeader
{
    __weak VCLoginViewController* _self = self;        
    
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

    /*
    UIColor* color = COLOR_FOR_BUTTON;
    UIView* viewForTaget = nil;
    ///////////////////////////////////////////////////////////////////////////////
    // Header
    {
        UIImage *image = [UIImage imageNamed:@"header_leather.png"];
        CGRect frame = CGRectMake(0, 0, self.view.width, 44);
        UIImageView* view = [[UIImageView alloc] initWithFrame:frame];
        view.userInteractionEnabled = YES;
        view.image = image;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth;        
        view.backgroundColor = HEXCOLOR(0x000000);
        [self.view addSubview:view];
        viewForTaget = view;
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Higlight
    {
        CGFloat height = 2.0f;
        CGRect frame = CGRectMake(0, 0, self.view.width, height);
        //        CGRect frame = CGRectMake(0, self.viewForHeader.bottom-height, self.view.width, height);        
        UIBlockView* view = [[UIBlockView alloc] initWithFrame:frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
            CGRect bounds = _view.bounds;
            CGContextSetFillColorWithColor(context, COLOR_FOR_HIGHLIGHT.CGColor);
            CGContextFillRect(context, bounds);
        };
        [view setNeedsDisplay];
        [viewForTaget addSubview:view];
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Title
    {
        UILabel* label = [[UILabel alloc] initWithFrame:viewForTaget.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = HEXCOLOR(0xFFFFFF);
        label.font = [UIFont fontWithName:@"American Typewriter" size:20];
        label.text = APP_NAME;
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = HEXCOLOR(0x999999);
        label.shadowOffset = CGSizeMake(0, 0);
        [viewForTaget addSubview:label];
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Header shadow
    {
        CGRect frame = CGRectMake(0, viewForTaget.bottom, self.view.width, 10.0f);
        UIImage *image = [UIImage imageNamed:@"shadow_10x10.png"];
        UIBlockView* view = [[UIBlockView alloc] initWithFrame:frame];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        view.backgroundColor = [UIColor clearColor];
        view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
            SSContextFlip(context, _view.size);
            CGContextDrawTiledImage(context, CGRectOfSize(image.size), image.CGImage);
        };
        [view setNeedsDisplay];
        [viewForTaget addSubview:view];
    }
    */
}

- (void) login:(id)sender
{    
    SS_MLOG(self);
    __weak VCLoginViewController* _self = self;

    // @see https://developers.facebook.com/docs/authentication/permissions/
    NSArray *permissions = [MMPermissionModel permissionsForLogin];
    [FBSession sessionOpenWithPermissions:permissions completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [_self dismissModalViewAction:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:NFDidLogin object:nil userInfo:nil];            
        });
    }];
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
    SS_MLOG(self);
    [[SSStatsBarOverlay sharedManager] postMessage:[NSString stringWithFormat:@"[dealloc] %@", NSStringFromClass([self class])]];    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Login", @"");
    
    {
        UIImage* image = [UIImage imageNamed:@"facebookphone"];
        CGRect frame;
        if ([UIDevice isPad] ){        
            frame = CGRectMake(0, 44.0f, 540, 580);
        } else {
            frame = self.view.bounds;
        }
        UIImageView* view = [[UIImageView alloc] initWithFrame:frame];
        [view setImage:image];
        [self.view addSubview:view];
    }
    
    [self viewDidLoadForHeader];
    
    {
        CGRect frameButton = CGRectMake(0, 380, 260, 36);
        UIButton* button = [[UIButton alloc] initWithFrame:frameButton];
        [self.view addSubview:button]; 
        
        {
            UIImage* image = [UIImage imageWithSize:button.size block:^(CGContextRef context, CGSize size){
                CGRect rect = CGRectOfSize(size);
                {
                    // CGRectInset(rect, 1, 1)
                    SSContextAddRoundedRectToPath(context, rect, 4.0f, SSRoundedCornerPositionAll);
                    CGContextSetFillColorWithColor(context, HEXCOLOR(0x800040).CGColor);
                    CGContextFillPath(context);                    
                    
                    SSContextAddRoundedRectToPath(context, CGRectInset(rect, 2, 2), 4.0f, SSRoundedCornerPositionAll);                    
                    CGContextSetLineWidth(context, 2.0f);
                    CGContextSetStrokeColorWithColor(context, HEXCOLOR(0x111111).CGColor);
                    CGContextStrokePath(context);
                    
                }
                {
                    CGContextTranslateCTM(context, 0, size.height);
                    CGContextScaleCTM(context, 1.0, -1.0);                
                    CGContextSetFillColorWithColor(context, HEXCOLOR(0xFFFFFF).CGColor); 
                    UIFont* font = [UIFont systemFontOfSize:20];
                    [NSLocalizedString(@"Login", @"") drawInRect:CGRectOffset(rect, 0, 6) withFont:font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
                }
            }];
            [button setImage:image forState:UIControlStateNormal];
        }
        
        button.centerX = self.view.width/2;
        
        [button addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
        self.buttonForLogin = button;
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewDidAppear:(BOOL)animated   
{
    [super viewDidAppear:animated];

}


- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.buttonForLogin.centerX = self.view.width/2;
    self.buttonForLogin.centerY = self.view.height - 100;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([UIDevice isPad] ){
        return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

@end
