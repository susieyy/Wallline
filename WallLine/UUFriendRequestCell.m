//
//  UUFriendRequestCell.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/17.
//
//

#import "UUFriendRequestCell.h"
#import "UUUserProfileButton.h"
#import "UIButton+TapDownTintImage.h"
#import "SDWebImageManager.h"
#import "UUClearButton.h"

#define FONT_NAME @"Helvetica"
#define FONT_NAME_BOLD @"Helvetica-Bold"
#define FONT_SIZE_FOR_TITLE 10
#define LINE_SPACEING 1.0f
#define WIDTH_FOR_TEXT 200
#define MARGIN 4.0f

@interface UUFriendRequestCell () <RTLabelDelegate>
@property (strong, nonatomic) MMFriendRequestModel* friendRequestModel;
@property (weak, nonatomic) RTLabel* labelForTitle;
@property (weak, nonatomic) UUUserProfileButton* buttonForUserProfile;
@end

@implementation UUFriendRequestCell

- (void) tapUserProfile:(id)sender
{
    NSString* senderID = self.friendRequestModel[@"from"][@"id"];
    NSString* url = [NSString stringWithFormat:@"friend://%@", senderID];
    NSURL* URL = [NSURL URLWithString:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFCloseVCNotificationViewController object:nil userInfo:nil];
    
    double delayInSeconds = 0.7f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];
    });
}

- (void) confirmAction:(id)sender
{
    SS_MLOG(self);
    NSString* userID = self.friendRequestModel[@"from"][@"id"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFConfirmFriendRequest object:userID userInfo:nil];
}

- (void) notnowAction:(id)sender
{
    SS_MLOG(self);
    NSString* userID = self.friendRequestModel[@"from"][@"id"];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFNotNowFriendRequest object:userID userInfo:nil];
}


#pragma -
#pragma

+ (RTLabel*) rtlabel
{
    UIColor* colorForBack = [UIColor clearColor];
    RTLabel* view = [[RTLabel alloc] initWithFrame:CGRectZero];
    view.backgroundColor = colorForBack;
    view.textColor = HEXCOLOR(0xCCCCCC);
    view.font = [UIFont fontWithName:FONT_NAME size:10];
    
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionary];
    [linkAttributes setObject:@"bold" forKey:@"style"];
    [linkAttributes setObject:@"#2B4584" forKey:@"color"];
    [linkAttributes setObject:@"0" forKey:@"underline"];
    
    NSMutableDictionary *selectedLinkAttributes = [NSMutableDictionary dictionary];
    [selectedLinkAttributes setObject:@"bold" forKey:@"style"];
    [selectedLinkAttributes setObject:@"#994584" forKey:@"color"];
    [selectedLinkAttributes setObject:@"0" forKey:@"underline"];
    
    [view setLinkAttributes:linkAttributes];
    [view setSelectedLinkAttributes:selectedLinkAttributes];
    return view;
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        // Back
        {
            UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.contentView.bounds];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
            view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
                CGRect bounds = _view.bounds;
                UIColor* color = HEXCOLOR(0x1B2230);
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                CGContextStrokeRect(context, CGRectMake(0, 0, bounds.size.width, 1.0f));
            };
            [view setNeedsDisplay];
            [self.contentView addSubview:view];
        }
        // Title
        {
            RTLabel* view = [[self class] rtlabel];
            view.delegate = self;
            [self.contentView addSubview:view];
            self.labelForTitle = view;
        }
        // UserProfile
        {
            UUUserProfileButton* view = [[UUUserProfileButton alloc] initWithFrame:CGRectZero];
            [view tapDownTintImage];
            [view addTarget:self action:@selector(tapUserProfile:) forControlEvents:UIControlEventTouchUpInside];
            self.buttonForUserProfile = view;
            [self.contentView addSubview:view];
        }

        // Confirm BUtton
        {
            CGFloat height = 24;
            CGRect frame = CGRectMake(142, (44-height)/2, 52, height);
            UUClearButton* button = [UUClearButton buttonWithFrame:frame title:NSLocalizedString(@"Confirm", @"")];
            [button setTintColorAsBlue];
            [button setHighlighted:NO];
            [self.contentView addSubview:button];
            
            button.titleLabel.font = [UIFont boldSystemFontOfSize:10];
            
            [button addTarget:self action:@selector(confirmAction:) forControlEvents:UIControlEventTouchUpInside];
        }

        // Confirm BUtton
        {
            CGFloat height = 24;
            CGRect frame = CGRectMake(202, (44-height)/2, 52, height);
            UUClearButton* button = [UUClearButton buttonWithFrame:frame title:NSLocalizedString(@"NotNow", @"")];
            [button setTintColorAsRed];
            [button setHighlighted:NO];
            [self.contentView addSubview:button];
            
            button.titleLabel.font = [UIFont boldSystemFontOfSize:10];
            
            [button addTarget:self action:@selector(notnowAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.buttonForUserProfile.frame = CGRectMake(OFFSET_MARGIN*2, 7.0f, 30, 30);
    
    CGFloat left = self.buttonForUserProfile.right+OFFSET_MARGIN;
    CGFloat width = WIDTH_FOR_TEXT;
    CGFloat height = self.labelForTitle.optimumSize.height;
    self.labelForTitle.frame = CGRectMake(left, (self.contentView.height-height)/2, 88, height);
}

- (void) setData:(MMFriendRequestModel*)data
{
    _friendRequestModel = data;
    SSLog([data description]);
    
#ifdef DEBUG
    // [s appendFormat:@"--- %@", [data objectForKey:@"href"]];
#endif
    self.labelForTitle.text = [NSString stringWithFormat:@"<b>%@</b>", data[@"from"][@"name"]];
    
    {
        NSString* senderID = data[@"from"][@"id"];
        [self.buttonForUserProfile setUserID:senderID blockImageProcessor:nil];
    }
}


+ (UUFriendRequestCell*) cell:(UITableView*)tableView
{
    static NSString* Identifier = @"UUFriendRequestCell";
    UUFriendRequestCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UUFriendRequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}

- (void) cancelRequest;
{
    SS_MLOG(self);
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // User Profile
    [manager cancelForDelegate:self.buttonForUserProfile];
}

#pragma -
#pragma

- (void) setSelected:(BOOL)selected
{
    if (selected) {
        self.contentView.backgroundColor = HEXCOLOR(0x334947);
    } else {
        self.contentView.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
    }
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self setSelected:selected];
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:NO];
    [self setSelected:highlighted];
}


#pragma -
#pragma Height

+ (RTLabel*) rtlabelForHeight
{
    static RTLabel* _label = nil;
    if (_label == nil) {
        _label = [self rtlabel];
    }
    return _label;
}


+ (CGFloat) heightFromData:(UUFriendRequestCell*)data
{
    return 44.0f;
}


@end
