//
//  VCProgressViewController.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/22.
//
//

#import "VCProgressViewController.h"


@interface VCProgressViewController ()
@property (strong, nonatomic) CALayer* layerForTriangleFetch;
@property (strong, nonatomic) CALayer* layerForTriangleSend;
@property (strong, nonatomic) UIView *viewForProgressFetch; // Need strong !
@property (strong, nonatomic) UIView *viewForProgressSend; // Need strong !

@property (weak, nonatomic) WBErrorNoticeView *notice;
@end

@implementation VCProgressViewController

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
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doStartRequest:) name:NFDoStartRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doProgressRequest:) name:NFDoProgressRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doFinishRequest:) name:NFDoFinishRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doErrorRequest:) name:NFDoErrorRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doCancelRequest:) name:NFDoCancelRequest object:nil];
    
    ///////////////////////////////////////////////////////////////////////////////
    // Progres Fetch
    {
        UIView* viewForIndicator = nil;
        {
            CGRect frame = CGRectMake(0, 0, 320, 2.0f);
            UIView* view = [[UIView alloc] initWithFrame:frame];
            view.backgroundColor = HEXCOLOR(0x0088FF);
            view.hidden = YES;
            self.viewForProgressFetch = view;
        }
        {
            CGRect frame = CGRectMake(0, 0, 18, 18);
            UIView* view = [[UIView alloc] initWithFrame:frame];
            view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            view.backgroundColor = [UIColor clearColor];
            view.centerX = self.viewForProgressFetch.width;
            view.centerY = 1.0f;
            [self.viewForProgressFetch addSubview:view];
            viewForIndicator = view;
        }
        {
            UIImage *image = [[[UIImage imageNamed:@"triangle.png"] imageAsResizeTo:CGSizeMake(18, 18)] imageAsMaskedColor:HEXCOLOR(0x0088FF)];
            CALayer *layer = [CALayer layer];
            layer.contents = (id)image.CGImage;
            layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
            layer.position = CGPointMake(viewForIndicator.width/2, viewForIndicator.height/2);
            
            // Shrink down to 90% of its original value
            layer.transform = CATransform3DMakeScale(0.50, 0.50, 1);
            
            [viewForIndicator.layer addSublayer:layer];
            self.layerForTriangleFetch = layer;
        }
    }
    ///////////////////////////////////////////////////////////////////////////////
    // Progres Send
    {
        UIView* viewForIndicator = nil;
        {
            CGRect frame = CGRectMake(0, 0, 320, 2.0f);
            UIView* view = [[UIView alloc] initWithFrame:frame];
            view.backgroundColor = HEXCOLOR(0xFF8800);
            view.hidden = YES;
            self.viewForProgressSend = view;
        }
        {
            CGRect frame = CGRectMake(0, 0, 18, 18);
            UIView* view = [[UIView alloc] initWithFrame:frame];
            view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            view.backgroundColor = [UIColor clearColor];
            view.centerX = self.viewForProgressSend.width;
            view.centerY = 1.0f;
            [self.viewForProgressSend addSubview:view];
            viewForIndicator = view;
        }
        {
            UIImage *image = [[[UIImage imageNamed:@"triangle.png"] imageAsResizeTo:CGSizeMake(18, 18)] imageAsMaskedColor:HEXCOLOR(0xFF8800)];
            CALayer *layer = [CALayer layer];
            layer.contents = (id)image.CGImage;
            layer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
            layer.position = CGPointMake(viewForIndicator.width/2, viewForIndicator.height/2);
            
            // Shrink down to 90% of its original value
            layer.transform = CATransform3DMakeScale(0.50, 0.50, 1);
            
            [viewForIndicator.layer addSublayer:layer];
            self.layerForTriangleSend = layer;
        }
    }
}

- (void) setNavigationBar:(UINavigationBar*)navigationBar
{
    [navigationBar addSubview:self.viewForProgressFetch];
    [navigationBar addSubview:self.viewForProgressSend];
    
    CGRect frame = CGRectMake(0, navigationBar.height-2.0f, navigationBar.width, 2.0f);
    self.viewForProgressFetch.frame = frame;
    self.viewForProgressSend.frame = frame;
}

- (void) dealloc
{
    SS_MLOG(self);
    self.viewForProgressFetch = nil;
    self.viewForProgressSend = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _viewForProgressFetch = nil;
    _viewForProgressSend = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma -
#pragma Progress

- (void) _requestStartForProgress:(ProgressMode)progressMode
{
    SS_MLOG(self);
    UIView* view = nil;
    if (progressMode == ProgressModeFetch) {
        view = self.viewForProgressFetch;
    } else {
        view = self.viewForProgressSend;
    }
    view.alpha = 1.0f;
    view.hidden = NO;
    view.width = self.view.width * 0.05f;
    
    [self hideNoticeView];
    [self _doAnimationTriangleForProgress:progressMode];
}

- (void) _requestProgressForProgress:(CGFloat)_progress progressMode:(ProgressMode)progressMode
{
    CGFloat progress = _progress / 3.8f;
    SSLog(@"    PROGRESS [%f] [%f]", _progress, progress);
    progress = progress - 0.2f;
    if (progress < 0.0f) return;
    if (progress > 0.8f) progress = 0.8f;
    
    UIView* view = nil;
    if (progressMode == ProgressModeFetch) {
        view = self.viewForProgressFetch;
    } else {
        view = self.viewForProgressSend;
    }
    [UIView animateWithDuration:0.3f animations:^(){
        view.width = self.view.width * progress;
    }];
}

- (void) _requestFinishForProgress:(ProgressMode)progressMode
{
    SS_MLOG(self);
    UIView* view = nil;
    if (progressMode == ProgressModeFetch) {
        view = self.viewForProgressFetch;
    } else {
        view = self.viewForProgressSend;
    }
    [UIView animateWithDuration:0.3f animations:^(){
        view.width = self.view.width;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f animations:^(){
            view.alpha = 0.0f;
            
        } completion:^(BOOL finished) {
            view.hidden = YES;
        }];
    }];
    
}

- (void) _requestCancelForProgress:(ProgressMode)progressMode
{
    SS_MLOG(self);
    UIView* view = nil;
    if (progressMode == ProgressModeFetch) {
        view = self.viewForProgressFetch;
    } else {
        view = self.viewForProgressSend;
    }
    view.hidden = YES;
}

- (void) _requestErrorForProgress:(ProgressMode)progressMode
{
    SS_MLOG(self);
    UIView* view = nil;
    if (progressMode == ProgressModeFetch) {
        view = self.viewForProgressFetch;
    } else {
        view = self.viewForProgressSend;
    }
    view.hidden = YES;
}

#pragma -
#pragma Notification

- (void) _doStartRequest:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    ProgressMode progressMode = [userInfo[@"progressMode"] integerValue];
    NSString* keyNotification = userInfo[@"keyNotification"];
    if (keyNotification && self.keyForNotification) {
        if (NO == [keyNotification isEqualToString:self.keyForNotification]) return;
    }
    [self _requestStartForProgress:progressMode];
}

- (void) _doProgressRequest:(NSNotification*)notification
{
    CGFloat progress = [[notification object] floatValue];
    NSDictionary* userInfo = [notification userInfo];
    ProgressMode progressMode = [userInfo[@"progressMode"] integerValue];
    NSString* keyNotification = userInfo[@"keyNotification"];
    if (keyNotification && self.keyForNotification) {
        if (NO == [keyNotification isEqualToString:self.keyForNotification]) return;
    }
    [self _requestProgressForProgress:progress progressMode:progressMode];
}

- (void) _doFinishRequest:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    ProgressMode progressMode = [userInfo[@"progressMode"] integerValue];
    NSString* keyNotification = userInfo[@"keyNotification"];    
    if (keyNotification && self.keyForNotification) {
        if (NO == [keyNotification isEqualToString:self.keyForNotification]) return;
    }    
    [self _requestFinishForProgress:progressMode];
}

- (void) _doErrorRequest:(NSNotification*)notification
{
    NSError* error = [notification object];
    NSDictionary* userInfo = [notification userInfo];
    ProgressMode progressMode = [userInfo[@"progressMode"] integerValue];
    NSString* keyNotification = userInfo[@"keyNotification"];
    if (keyNotification && self.keyForNotification) {
        if (NO == [keyNotification isEqualToString:self.keyForNotification]) return;
    }

    [self _doErrorNotice:error];
    [self _requestErrorForProgress:progressMode];
}

- (void) _doCancelRequest:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    ProgressMode progressMode = [userInfo[@"progressMode"] integerValue];
    NSString* keyNotification = userInfo[@"keyNotification"];
    if (keyNotification && self.keyForNotification) {
        if (NO == [keyNotification isEqualToString:self.keyForNotification]) return;
    }

    [self _requestCancelForProgress:progressMode];
}

#pragma -
#pragma Error

- (void) _doErrorNotice:(NSError*)error
{
    SS_MLOG(self);
    NSDictionary* userInfo = [error userInfo];
    NSError* innerError = [userInfo objectForKey:FBErrorInnerErrorKey];
    NSLog(@"[ERROR] [REQUEST] %@", [innerError description]);
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view.superview title:NSLocalizedString(@"Network Error", @"") message:[innerError localizedDescription]];
    notice.delay = 3.0f;
    [notice show];
    self.notice = notice;
}

// Public
- (void) hideNoticeView
{
    if (self.notice == nil) return;
    [self.notice performSelector:@selector(dismissStickyNotice:)];
    self.notice = nil;
}

#pragma -
#pragma Helper

- (void) _doAnimationTriangleForProgress:(ProgressMode)progressMode
{
    CALayer *layer = nil;
    if (progressMode == ProgressModeFetch) {
        layer = self.layerForTriangleFetch;
    } else {
        layer = self.layerForTriangleSend;
    }
    
    [layer removeAllAnimations];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.autoreverses = YES;
    animation.duration = 0.35;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.repeatCount = HUGE_VALF;
    [layer addAnimation:animation forKey:@"pulseAnimation"];
    
}

#pragma -
#pragma Progress

+ (void) requestStartForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoStartRequest object:nil userInfo:userInfo];
}

+ (void) requestProgressForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification progress:(CGFloat)_progress;
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoProgressRequest object:[NSNumber numberWithFloat:_progress] userInfo:userInfo];
}

+ (void) requestFinishForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoFinishRequest object:nil userInfo:userInfo];
}

+ (void) requestCancelForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoCancelRequest object:nil userInfo:userInfo];
}

+ (void) requestErrorForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification error:(NSError*)error
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoErrorRequest object:error userInfo:userInfo];
}


@end
