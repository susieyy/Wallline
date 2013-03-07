//
//  UUCommentCell.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/10.
//
//

#import "UUCommentCell.h"
#import "UUUserProfileButton.h"
#import "UIButton+TapDownTintImage.h"
#import "SDWebImageManager.h"

#define FONT_NAME @"Helvetica"
#define FONT_NAME_BOLD @"Helvetica-Bold"
#define FONT_SIZE_FOR_TITLE 12
#define LINE_SPACEING 1.0f
#define WIDTH_FOR_TEXT 212
#define MARGIN 4.0f

#define HEIGHT_FOR_BUTTONS 24.0f

@interface UUCommentCell () <RTLabelDelegate>
@property (weak, nonatomic) UIView* viewForBackground;
@property (weak, nonatomic) RTLabel* labelForText;
@property (weak, nonatomic) UUUserProfileButton* buttonForUserProfile;
@property (weak, nonatomic) UIButton* buttonForLike;
@property (weak, nonatomic) UIView* viewForButtonsOuter;
@property (nonatomic) NSUInteger fontSizeLast;
@end

@implementation UUCommentCell

#pragma -
#pragma RTLabelDelegate

- (BOOL) isLikedAlready
{
    return NO;
    
    NSString* ID = [[MMMeModel sharedManager] objectForKey:@"id"];
    if (ID == nil) return NO;
    
    NSArray* datas = self.data[@"likes"][@"data"];
    if (datas == nil || datas.count == 0) return NO;
    for (NSDictionary* data in datas) {
        if ([ID isEqualToString:data[@"id"]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isLiked
{
    NSNumber* n = self.data[@"_is_liked"];
    BOOL isLike = NO;
    if (n == nil) {
        if ([self isLikedAlready]) {
            isLike = YES;
        } else {
            isLike = NO;
        }
    } else if (n && [n boolValue]) {
        isLike = YES;
    } else {
        isLike = NO;
    }
    return isLike;
}

- (void) tapLike:(id)sender
{
    NSString* objectID = self.data[@"id"];
    BOOL isDoLike = ![self isLiked];
    if (isDoLike) {
        self.data[@"_is_liked"] = @true;
        [[MMRequestManager sharedManager] doLikeObjectID:objectID];
    } else {
        self.data[@"_is_liked"] = @false;
        [[MMRequestManager sharedManager] doUnLikeObjectID:objectID];        
    }
    [self _updateLikeButton];
}

- (void) _updateLikeButton;
{
    NSString* title = nil;
    if (self.isLiked) {
        title = NSLocalizedString(@"Liked (Unlike)", @"");
    } else {
        title = NSLocalizedString(@"Like!", @"");
    }
    [self.buttonForLike setTitle:title forState:UIControlStateNormal];
}

#pragma -
#pragma

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)URL;
{
    NSDictionary* userInfo = [NSMutableDictionary dictionary];
    if (self.keyForNotification) {
        [userInfo setValue:self.keyForNotification forKey:@"keyForNotification"];
    }    
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:userInfo];
}

- (void) tapUserProfile:(id)sender
{
    NSDictionary* userInfo = [NSMutableDictionary dictionary];
    if (self.keyForNotification) {
        [userInfo setValue:self.keyForNotification forKey:@"keyForNotification"];
    }

    NSString* senderID = self.userID;
    NSString* url = [NSString stringWithFormat:@"friend://%@", senderID];
    NSURL* URL = [NSURL URLWithString:url];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:userInfo];
}

+ (RTLabel*) rtlabel
{
    UIColor* colorForBack = [UIColor clearColor];
    RTLabel* view = [[RTLabel alloc] initWithFrame:CGRectZero];
    view.backgroundColor = colorForBack;
    view.textColor = HEXCOLOR(0x666666);
    
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
        // Initialization codea
    
        UIImage* imagepaper = [UIImage imageNamed:@"paper.png"];
        
        // back
        {
            
            UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.contentView.bounds];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
                CGRect bounds = _view.bounds;
                CGContextDrawTiledImage(context, CGRectOfSize(imagepaper.size), imagepaper.CGImage);
                
                UIColor* color = HEXCOLOR(0xE9E6DF);
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                CGContextStrokeRect(context, CGRectMake(0, 0, bounds.size.width, 1.0f));
                
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                CGContextStrokeRect(context, CGRectMake(OFFSET_MARGIN + 30.0f/2, 0, 1.0f, bounds.size.height));
                
            };
            [view setNeedsDisplay];
            self.viewForBackground = view;
            [self.contentView addSubview:view];
        }

        // Title
        {
            RTLabel* view = [[self class] rtlabel];
            [view setLineSpacing:1.0f];
            view.delegate = self;
            [self.contentView addSubview:view];
            self.labelForText = view;
        }
        // UserProfile
        {
            UUUserProfileButton* view = [[UUUserProfileButton alloc] initWithFrame:CGRectZero];
            view.isIconRounded = YES;            
            [view tapDownTintImage];
            [view addTarget:self action:@selector(tapUserProfile:) forControlEvents:UIControlEventTouchUpInside];
            self.buttonForUserProfile = view;
            [self.contentView addSubview:view];
        }

        // Like Button
        {
            CGFloat width = 84.0f;
            CGFloat lineWidth = 2.0f;
            CGRect frame = CGRectMake(0, 0, width + lineWidth * 2, HEIGHT_FOR_BUTTONS);
            UIView* view = [[UIView alloc] initWithFrame:frame];
            view.backgroundColor = HEXCOLOR(0xE9E6DF);
            [self.contentView addSubview:view];
            self.viewForButtonsOuter = view;
            
            UIImage* imageHighlight = [imagepaper tintedImageUsingColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setTitleColor:COLOR_FOR_TEXT_LINK forState:UIControlStateNormal];
            [button setTitleColor:COLOR_FOR_TEXT_LINK_HIGHLIGHTED forState:UIControlStateHighlighted];
            [button setSize:CGSizeMake(width, HEIGHT_FOR_BUTTONS)];
            [button setBackgroundImage:imagepaper forState:UIControlStateNormal];
            [button setBackgroundImage:imageHighlight forState:UIControlStateHighlighted];
            [view addSubview:button];
            
            button.left = lineWidth;
            
            UILabel* label = button.titleLabel;
            label.font = [UIFont fontWithName:FONT_NAME_BOLD size:12];
            
            self.buttonForLike = button;
            
            [button addTarget:self action:@selector(tapLike:) forControlEvents:UIControlEventTouchUpInside];
        }

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.buttonForUserProfile.frame = CGRectMake(OFFSET_MARGIN, OFFSET_MARGIN, 30, 30);
    
    CGFloat left = self.buttonForUserProfile.right+OFFSET_MARGIN;
    CGFloat width = self.contentView.width -left-OFFSET_MARGIN;
    self.labelForText.frame = CGRectMake(left, MARGIN+1, width, self.contentView.height - MARGIN*2);

    self.viewForButtonsOuter.right = self.contentView.width-OFFSET_MARGIN*2;
    self.viewForButtonsOuter.bottom = self.contentView.height - MARGIN;
}


- (void) setData:(NSDictionary *)data
{
    _data = data;
    
    [self updateFontSize];
    
    self.labelForText.text = [[self class] messageFromData:data];
    
    {
        [self.buttonForUserProfile setUserID:self.userID blockImageProcessor:^UIImage *(UIImage *_image) {
            return [MMImageManager imageForUserProfile:_image];
        }];
    }
    
    [self _updateLikeButton];
}

+ (NSString*) messageFromData:(NSDictionary*)data
{
    NSString* text = [NSString stringWithFormat:@"<a href='friend://%@'>%@</a> %@", data[@"from"][@"id"], data[@"from"][@"name"], data[@"message"]];
    return text;
}

- (NSString*) userID
{
    return self.data[@"from"][@"id" ];
}

- (void) cancelRequest;
{
    SS_MLOG(self);
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    // User Profile
    [manager cancelForDelegate:self.buttonForUserProfile];
}

- (void) updateFontSize
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger fontSize = [userDefaults integerForKey:@"FontSizeForTimeLine"];
    if (self.fontSizeLast == fontSize) return;
    
    self.labelForText.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    self.fontSizeLast = fontSize;
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

+ (UUCommentCell*) cell:(UITableView*)tableView
{
    static NSString* Identifier = @"UUCommentCell";
    UUCommentCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UUCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}

+ (CGFloat) heightFromData:(NSDictionary*)data
{
    NSUInteger fontSize;
    {
        NSString* key = @"FontSizeForTimeLine";
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        fontSize = [userDefaults integerForKey:key];
    }
    
    CGFloat height = MARGIN * 2;
    RTLabel* label = [self rtlabelForHeight];
    label.frame = CGRectMake(0, 0, WIDTH_FOR_TEXT, INT_MAX);
    label.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    
    label.text = [self messageFromData:data];
    height += label.optimumSize.height;
    
    height += HEIGHT_FOR_BUTTONS;
    
    if (height < 42.0f) height = 42.0f;
    return height;
}

@end
