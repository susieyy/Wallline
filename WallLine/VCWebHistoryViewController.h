//
//  VCWebHistoryViewController.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/24.
//
//

#import <UIKit/UIKit.h>
#import "MMWebHistoryManager.h"

@protocol VCWebHistoryViewControllerDeleagte <NSObject>

- (void) doURLInfo:(NSDictionary*)userInfo;
- (void) viewDidDisappear;
@end

@interface VCWebHistoryViewController : UIViewController
@property (weak, nonatomic) id <VCWebHistoryViewControllerDeleagte> delegate;
@property (strong, nonatomic) NSMutableArray* items;
@end
