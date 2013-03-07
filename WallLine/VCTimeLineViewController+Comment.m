//
//  VCTimeLineViewController+Comment.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/09.
//
//

#import "VCTimeLineViewController+Comment.h"

@implementation VCTimeLineViewController (Comment)

- (void) viewDidLoadForComment
{
    CGRect frame = CGRectMake(0, 0, self.viewForTableContainer.width, 40.0f);
    UIView* containerView = [[UIView alloc] initWithFrame:frame];
    containerView.backgroundColor = HEXCOLOR(0x990000);
    containerView.userInteractionEnabled = YES;
    [self.viewForTableContainer addSubview:containerView];
    self.viewForComment = containerView;
  
    {
        UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
        UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        entryImageView.frame = CGRectMake(5, 0, 208, 40);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
        UIImage *_background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImage *background = [UIImage imageWithSize:containerView.size block:^(CGContextRef context, CGSize size) {
            CGContextDrawImage(context, CGRectOfSize(size), _background.CGImage);
            
        }];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        // view hierachy
        [containerView addSubview:imageView];
        [containerView addSubview:entryImageView];
        
        UIImage *sendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"MessageEntrySendButton.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
        
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(containerView.frame.size.width - 109, 8, 103, 27);
        doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
        [doneBtn setTitle:NSLocalizedString(@"Comment", @"") forState:UIControlStateNormal];
        
        [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
        doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
        doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
        [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(doShowCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        [doneBtn setBackgroundImage:sendBtnBackground forState:UIControlStateNormal];
        [doneBtn setBackgroundImage:selectedSendBtnBackground forState:UIControlStateSelected];
        [containerView addSubview:doneBtn];
                
        {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.size = entryImageView.size;
            button.backgroundColor = [UIColor clearColor];
            [button addTarget:self action:@selector(doShowCommentAction:) forControlEvents:UIControlEventTouchUpInside];
            [containerView addSubview:button];
        }
    }
}


@end
