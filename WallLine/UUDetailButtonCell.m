//
//  UUDetailButton.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/21.
//
//

#import "UUDetailButtonCell.h"
#import "UUClearButton.h"

@interface UUDetailButtonCell ()

@property (weak, nonatomic) UIView* viewForBackground;
@property (weak, nonatomic) UIButton* button;
@end

@implementation UUDetailButtonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage* imagepaper = [UIImage imageNamed:@"paper_gray.png"];
        
        // back
        {
            UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.contentView.bounds];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
                CGContextDrawTiledImage(context, CGRectOfSize(imagepaper.size), imagepaper.CGImage);
            };
            [view setNeedsDisplay];
            self.viewForBackground = view;
            [self.contentView addSubview:view];
        }        
        {
            
            NSString* title = nil;
            if (YES) { // self.stackModel.friendModel.isFriend) {
                title = NSLocalizedString(@"Friend", @"");
            } else {
                title = NSLocalizedString(@"Add Friend", @"");
            }
            UUClearButton* button = [UUClearButton buttonWithType:UIButtonTypeCustom];
            button.size = CGSizeMake(120, 26);
            [button setTitle:title forState:UIControlStateNormal];
            [button setTintColorAsBlue];
            [button setHighlighted:NO];
            
            UILabel* label = button.titleLabel;
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
            
            [self.contentView addSubview:button];
            self.button = button;
        }
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.viewForBackground.frame = self.contentView.bounds;
    self.button.center = self.contentView.center;
}

- (void) setStackModel:(MMStackModel*)stackModel
{
    _stackModel = stackModel;
    
    if (self.stackModel.timeLineType == VCTimeLineTypeFriend) {        
        [self updateButtonTitleForFriend];
        [self.button addTarget:self action:@selector(doRequestFriend:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.stackModel.timeLineType == VCTimeLineTypePage) {
        [self updateButtonTitleForPage];
        [self.button addTarget:self action:@selector(doLikePage:) forControlEvents:UIControlEventTouchUpInside];
    }
}

+ (UUDetailButtonCell*) cell:(UITableView*)tableView
{
    static NSString* Identifier = @"UUDetailButtonCell";
    UUDetailButtonCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UUDetailButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}

#pragma -
#pragma

- (void) updateButtonTitleForFriend
{
    NSString* title = nil;
    if (self.stackModel.friendModel.isFriend) {
        title = NSLocalizedString(@"Friend", @"");
    } else {
        title = NSLocalizedString(@"Add Friend", @"");
    }
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (void) updateButtonTitleForPage
{
    NSString* title = nil;
    if (self.stackModel.pageModel.isLiked) {
        title = NSLocalizedString(@"Liked (Unlike)", @"");
    } else {
        title = NSLocalizedString(@"Like!", @"");
    }
    [self.button setTitle:title forState:UIControlStateNormal];
}


- (void) doRequestFriend:(id)sender
{
    SS_MLOG(self);
    __weak UUDetailButtonCell* _self = self;
    
    if (self.stackModel.friendModel.isFriend) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Sorry, Facebook doesn't provide un friend API.", @"")];
        return;
    }
    
    UIButton* button = sender;
    [[MMFacebookManager sharedManager] requestFriend:self.stackModel.ID completionBlock:^(NSError *error) {
        if (error) {
            [UIAlertView showWithError:error];            
        } else {
            _self.stackModel.friendModel.isFriend = ! _self.stackModel.friendModel.isFriend;
            [_self updateButtonTitleForFriend];
        }
    }];
}

- (void) doLikePage:(id)sender
{
    if (self.stackModel.pageModel.isLiked) {
        [UIAlertView showWithTitle:NSLocalizedString(@"Sorry, Facebook doesn't provide page unlike API.", @"")];
        return;
    }
    
    UIButton* button = sender;
    NSString* title = nil;
    self.stackModel.pageModel.isLiked = !self.stackModel.pageModel.isLiked;
    
    [self updateButtonTitleForPage];
    
    if (self.stackModel.pageModel.isLiked) {
        [[MMRequestManager sharedManager] doLikeObjectID:self.stackModel.ID];
    } else {
        // NO API
        // [[MMRequestManager sharedManager] doUnLikeObjectID:self.stackModel.ID];
    }
}



@end
