//
//  VCTimeLineViewController+Progress.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/12.
//
//

#import "VCTimeLineViewController+Progress.h"

@implementation VCTimeLineViewController (Progress)
/*
#pragma -
#pragma Progress

- (void) _requestStartForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoStartRequest object:nil userInfo:userInfo];
}

- (void) _requestProgressForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification progress:(CGFloat)_progress;
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoProgressRequest object:[NSNumber numberWithFloat:_progress] userInfo:userInfo];
}

- (void) _requestFinishForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoFinishRequest object:nil userInfo:userInfo];
}

- (void) _requestCancelForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoCancelRequest object:nil userInfo:userInfo];
}

- (void) _requestErrorForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification error:(NSError*)error
{    
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    userInfo[@"progressMode"] = [NSNumber numberWithInteger:progressMode];
    if (keyNotification) {
        userInfo[@"keyNotification"] = keyNotification;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoErrorRequest object:error userInfo:userInfo];
}
*/


/*
- (void) viewDidLoadForProgress;
{
    SS_MLOG(self);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doSendStart:) name:NFDoStartRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doSendProgress:) name:NFDoProgressRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doSendFinish:) name:NFDoFinishRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_doSendError:) name:NFDoErrorRequest object:nil];
    
    ///////////////////////////////////////////////////////////////////////////////
    // Progres Fetch
    {
        UIView* viewForIndicator = nil;
        {
            CGRect frame = CGRectMake(0, self.navigationController.navigationBar.height-2.0f, self.view.width, 2.0f);
            UIView* view = [[UIView alloc] initWithFrame:frame];
            view.backgroundColor = HEXCOLOR(0x0088FF);
            view.hidden = YES;
            [self.navigationController.navigationBar addSubview:view];
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
            CGRect frame = CGRectMake(0, self.navigationController.navigationBar.height-2.0f, self.view.width, 2.0f);
            UIView* view = [[UIView alloc] initWithFrame:frame];
            view.backgroundColor = HEXCOLOR(0xFF8800);
            view.hidden = YES;
            [self.navigationController.navigationBar addSubview:view];
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

#pragma -
#pragma Progress

- (void) _requestStartForProgress:(ProgressMode)progressMode
{
    {
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        userInfo[@"progressMode"] = [NSNumber numberWithInteger:ProgressModeFetch];
        [[NSNotificationCenter defaultCenter] postNotificationName:NFDoStartRequest object:nil userInfo:userInfo];
    }
    return;
    
    
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
    
    [self.progressViewController hideNoticeView];
    //--- [self doAnimationTriangleForProgress:progressMode];
}

- (void) _requestProgressForProgress:(CGFloat)_progress progressMode:(ProgressMode)progressMode
{
    {
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        userInfo[@"progressMode"] = [NSNumber numberWithInteger:ProgressModeFetch];
        [[NSNotificationCenter defaultCenter] postNotificationName:NFDoProgressRequest object:[NSNumber numberWithFloat:_progress] userInfo:userInfo];
    }
    return;
    
    
    
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
    {
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        userInfo[@"progressMode"] = [NSNumber numberWithInteger:ProgressModeFetch];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NFDoFinishRequest object:nil userInfo:userInfo];
    }
    return;
    
    
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
    {
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        userInfo[@"progressMode"] = [NSNumber numberWithInteger:ProgressModeFetch];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NFDoCancelRequest object:nil userInfo:userInfo];
    }
    return;
    
    SS_MLOG(self);
    UIView* view = nil;
    if (progressMode == ProgressModeFetch) {
        view = self.viewForProgressFetch;
    } else {
        view = self.viewForProgressSend;
    }
    view.hidden = YES;
}

- (void) _requestErrorForProgress:(ProgressMode)progressMode error:(NSError*)error
{
    {
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        userInfo[@"progressMode"] = [NSNumber numberWithInteger:ProgressModeFetch];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NFDoErrorRequest object:error userInfo:userInfo];
    }
    return;

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
#pragma Send

- (void) _doSendStart:(NSNotification*)notification
{
    [self _requestStartForProgress:ProgressModeSend];
}

- (void) _doSendProgress:(NSNotification*)notification
{
    CGFloat progress = [[notification object] floatValue];
    [self _requestProgressForProgress:progress progressMode:ProgressModeSend];
}

- (void) _doSendFinish:(NSNotification*)notification
{
    [self _requestFinishForProgress:ProgressModeSend];
}

- (void) _doSendError:(NSNotification*)notification
{
    NSError* error = [notification object];
    [self _doError:error];
    [self _requestErrorForProgress:ProgressModeSend error:error];
}

#pragma -
#pragma Error

- (void) _doError:(NSError*)error
{
    SS_MLOG(self);
    NSDictionary* userInfo = [error userInfo];
    NSError* innerError = [userInfo objectForKey:FBErrorInnerErrorKey];
    NSLog(@"[ERROR] [REQUEST] %@", [innerError description]);
    WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:self.view title:NSLocalizedString(@"Network Error", @"") message:[innerError localizedDescription]];
    notice.delay = 3.0f;
    [notice show];
    self.notice = notice;
}

- (void) hideNoticeView
{
    if (self.notice == nil) return;
    
    WBErrorNoticeView* notice = [WBErrorNoticeView defaultManager];
    [self.notice performSelector:@selector(dismissStickyNotice:)];
    self.notice = nil;
}

#pragma -
#pragma Helper

- (void) doAnimationTriangleForProgress:(ProgressMode)progressMode
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
*/
@end
