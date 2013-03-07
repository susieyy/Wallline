//
//  VCSVWebViewController.h
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/24.
//
//

#import "SVWebViewController.h"

@interface VCSVWebViewController :  UIViewController

- (id)initWithAddress:(NSString*)urlString;
- (id)initWithURL:(NSURL*)URL;

- (void) loadURL:(NSURL*)URL;

@property (nonatomic, readwrite) SVWebViewControllerAvailableActions availableActions;

@end
