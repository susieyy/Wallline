//
//  VCProgressViewController.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/22.
//
//

#import <UIKit/UIKit.h>
#import "MMRequestManager.h"

enum {
    ProgressModeFetch = 0,
    ProgressModeSend = 1,
};
typedef NSUInteger ProgressMode;


@interface VCProgressViewController : UIViewController
@property (strong, nonatomic) NSString* keyForNotification;

- (void) setNavigationBar:(UINavigationBar*)navigationBar;
- (void) hideNoticeView;

+ (void) requestStartForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification;
+ (void) requestProgressForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification progress:(CGFloat)_progress;
+ (void) requestFinishForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification;
+ (void) requestCancelForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification;
+ (void) requestErrorForProgress:(ProgressMode)progressMode keyNotification:(NSString*)keyNotification error:(NSError*)error;

@end
