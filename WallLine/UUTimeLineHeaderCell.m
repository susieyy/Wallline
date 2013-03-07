//
//  UUTimeLineHeaderCell.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/16.
//
//

#import "UUTimeLineHeaderCell.h"
#import "UUUserProfileButton.h"
#import "UIButton+TapDownTintImage.h"
#import "SDWebImageManager.h"

#define FONT_NAME @"Helvetica"
#define FONT_NAME_BOLD @"Helvetica-Bold"
#define FONT_SIZE_FOR_TITLE 12
#define LINE_SPACEING 1.0f
#define WIDTH_FOR_TEXT 206
#define MARGIN 4.0f


@interface UUTimeLineHeaderCell () <RTLabelDelegate>
@property (weak, nonatomic) UIView* viewForBackground;
@property (weak, nonatomic) RTLabel* labelForText;
@property (weak, nonatomic) UUUserProfileButton* buttonForUserProfile;
@property (nonatomic) NSUInteger fontSizeLast;
@end

@implementation UUTimeLineHeaderCell

#pragma -
#pragma RTLabelDelegate

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)URL;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];
}

- (void) tapUserProfile:(id)sender
{
    NSString* senderID = self.userID;
    NSString* url = [NSString stringWithFormat:@"friend://%@", senderID];
    NSURL* URL = [NSURL URLWithString:url];

    [[NSNotificationCenter defaultCenter] postNotificationName:NFDoTimeLineURL object:URL userInfo:nil];
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
        // Initialization code
        
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
        [self updateFontSize];
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
    CGFloat height = self.labelForText.optimumSize.height;
    self.labelForText.frame = CGRectMake(left, (self.contentView.height-height)/2, width, height);
}

- (void) setData:(MMStatusModel *)data
{
    _data = data;
    
    [self updateFontSize];
    
    NSString* ID = nil;
    NSString* name = nil;
    
    NSArray* datas = self.data[@"to"][@"data"];
    if (datas && datas.count) {
        name = datas[0][@"name"];
        ID = datas[0][@"id"];
    } else {
        name = self.data[@"from"][@"name"];
        ID = self.data[@"from"][@"id"];
    }

    self.labelForText.text = [NSString stringWithFormat:@"<a href='friend://%@'>%@</a>", ID, name];
    
    {
        [self.buttonForUserProfile setUserID:ID blockImageProcessor:^UIImage *(UIImage *_image) {
            return [MMImageManager imageForUserProfile:_image];
        }];
    }

    [self layoutSubviews];
}

- (NSString*) userID
{
    return self.data[@"id" ];
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

+ (UUTimeLineHeaderCell*) cell:(UITableView*)tableView
{
    static NSString* Identifier = @"UUTimeLineHeaderCell";
    UUTimeLineHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UUTimeLineHeaderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}

+ (CGFloat) heightFromData:(NSDictionary*)data
{
    return 44.0f;
}

@end
