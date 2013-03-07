//
//  MADismissiveTextView.h
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/23.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "HPGrowingTextView.h"

#import "HPTextViewInternal.h"

@protocol MADismissiveKeyboardDelegate <NSObject>

@optional
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidScroll:(CGPoint)keyboardOrigin;
- (void)keyboardWillBeDismissed;
- (void)keyboardWillSnapBack;

@end

@interface MADismissiveTextView : HPTextViewInternal
@property (nonatomic, weak) id <MADismissiveKeyboardDelegate> keyboardDelegate;
@property (nonatomic, strong) UIPanGestureRecognizer *dismissivePanGestureRecognizer;
- (void)panning:(UIPanGestureRecognizer *)pan;
@end
