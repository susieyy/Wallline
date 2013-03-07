//
//  UUNotificationCell.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/07/23.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "UUNotificationCell.h"
#import "UUUserProfileButton.h"
#import "UIButton+TapDownTintImage.h"
#import "SDWebImageManager.h"

#define FONT_NAME @"Helvetica"
#define FONT_NAME_BOLD @"Helvetica-Bold"
#define FONT_SIZE_FOR_TITLE 10
#define LINE_SPACEING 1.0f
#define WIDTH_FOR_TEXT 200
#define MARGIN 4.0f

@interface UUNotificationCell () <RTLabelDelegate>
@property (strong, nonatomic) MMNotificationModel* notificationModel;
@property (weak, nonatomic) RTLabel* labelForTitle;
@property (weak, nonatomic) UIView* viewForColor;
@property (weak, nonatomic) UILabel* labelForUnread;
@property (weak, nonatomic) UUUserProfileButton* buttonForUserProfile;
@end

@implementation UUNotificationCell

- (void) tapUserProfile:(id)sender
{
    NSString* senderID =[self.notificationModel senderID];    
    NSString* url = [NSString stringWithFormat:@"friend://%@", senderID];
    NSURL* URL = [NSURL URLWithString:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:NFCloseVCNotificationViewController object:nil userInfo:nil];
    
    double delayInSeconds = 0.7f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];
    });
}


#pragma -
#pragma 

+ (RTLabel*) rtlabel
{
    UIColor* colorForBack = [UIColor clearColor];
    RTLabel* view = [[RTLabel alloc] initWithFrame:CGRectZero];    
    view.backgroundColor = colorForBack;
    view.textColor = HEXCOLOR(0xCCCCCC);
    [view setLineSpacing:LINE_SPACEING];
    view.font = [UIFont fontWithName:FONT_NAME size:FONT_SIZE_FOR_TITLE];             
    
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
        
        // Unread
        {
            CGRect frame = CGRectMake(0, 2, 14, 14);
            UILabel* label = [[UILabel alloc] initWithFrame:frame];
            label.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
            label.textAlignment = UITextAlignmentRight;
            label.text = @"●";
            label.font = [UIFont boldSystemFontOfSize:12];
            [self.contentView addSubview:label];
            self.labelForUnread = label;
        }

        // Color
        {
            UIView* view = [[UIView alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:view];
            self.viewForColor = view;
        }
        // Title
        {
            RTLabel* view = [[self class] rtlabel];
            [view setLineSpacing:1.0f];
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
    }
    return self;
}


- (void) layoutSubviews
{
    [super layoutSubviews];

    self.viewForColor.frame = CGRectMake(0.0f, 1.0f, 6.0f, self.height-1.0f);

    self.buttonForUserProfile.frame = CGRectMake(OFFSET_MARGIN*2, OFFSET_MARGIN, 30, 30);

    CGFloat left = self.buttonForUserProfile.right+OFFSET_MARGIN;
    CGFloat width = WIDTH_FOR_TEXT;
    self.labelForTitle.frame = CGRectMake(left, MARGIN, width, self.contentView.height - MARGIN*2);

    self.labelForUnread.right = self.width - 2.0f;
    //self.labelForUnread.bottom = self.height;
}

- (void) setData:(MMNotificationModel*)notificationModel
{
    _notificationModel = notificationModel;
    SSLog([notificationModel description]);
        
#ifdef DEBUG        
    // [s appendFormat:@"--- %@", [data objectForKey:@"href"]];        
#endif        
    self.labelForTitle.text = self.notificationModel[@"title_html"];
    self.viewForColor.backgroundColor = [self color];
 
    {
        NSString* senderID =[self.notificationModel senderID];
        [self.buttonForUserProfile setUserID:senderID blockImageProcessor:nil];
    }
    
    BOOL isUnread = [self.notificationModel isUnread];
    if (isUnread) {
        self.labelForUnread.textColor = HEXCOLOR(0x0088FF);
    } else {
        self.labelForUnread.textColor = HEXCOLOR(0x666666);
    }
}


- (UIColor*) color
{
    MMNotificationType type = [self.notificationModel type];
    if (type == MMNotificationTypeEvent) return HEXCOLOR(0xF1A395);
    if (type == MMNotificationTypeCheckin) return HEXCOLOR(0xF9C8D8);    
    if (type == MMNotificationTypeAlbum) return HEXCOLOR(0xDACCFF);
    if (type == MMNotificationTypePhoto) return HEXCOLOR(0xA5C3F4);
    if (type == MMNotificationTypeStream) return HEXCOLOR(0x538AED);
    if (type == MMNotificationTypeFriend) return HEXCOLOR(0xA395F1);
    if (type == MMNotificationTypePage) return HEXCOLOR(0xC8F9D8);    
    if (type == MMNotificationTypeGroup) return HEXCOLOR(0xCCFF66);
    
    return [UIColor clearColor];

}

+ (UUNotificationCell*) cell:(UITableView*)tableView
{
    static NSString* Identifier = @"UUNotificationCell";
    UUNotificationCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UUNotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
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


+ (CGFloat) heightFromData:(MMNotificationModel*)notificationModel
{
    CGFloat height = MARGIN * 2;
    RTLabel* label = [self rtlabelForHeight];
    label.frame = CGRectMake(0, 0, WIDTH_FOR_TEXT, INT_MAX);
   
    label.text = [notificationModel objectForKey:@"title_html"];   
    height += label.optimumSize.height;    
    
    if (height < 66.0f) height = 66.0f;
    return height;
}
@end
