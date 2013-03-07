//
//  UUDetailCell.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/06.
//
//

#import "UUDetailCell.h"
#import "RTLabel.h"

#define FONT_NAME @"Helvetica"

#define LEFT_SIZE 70
#define DEFAULT_HEIGHT 24.0f
#define WIDTH_FOR_TEXT 236

#define MARGIN 4.0f

@interface UUDetailCell () <RTLabelDelegate>
@property (weak, nonatomic) UIView* viewForBackground;
@property (nonatomic) NSUInteger fontSizeLast;
@end

@implementation UUDetailCell

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)URL;
{
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
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImage* imagepaper = [UIImage imageNamed:@"paper_gray.png"];
        
        // back
        {            
            UIBlockView* view = [[UIBlockView alloc] initWithFrame:self.contentView.bounds];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            view.blockDrawRect = ^(CGContextRef context, UIView* _view, CGRect dirtyRect) {
                CGRect bounds = _view.bounds;
                CGContextDrawTiledImage(context, CGRectOfSize(imagepaper.size), imagepaper.CGImage);                
            };
            [view setNeedsDisplay];
            self.viewForBackground = view;
            [self.contentView addSubview:view];
        }

        ///////////////////////////////////////////////////////////////////////////////
        // Name
        {
            self.textLabel.textColor = HEXCOLOR(0x666666);
            self.textLabel.textAlignment = UITextAlignmentRight;
            self.textLabel.backgroundColor = self.contentView.backgroundColor;
        }
        
        ///////////////////////////////////////////////////////////////////////////////
        // Detail
        {            
            RTLabel* view = [[self class] rtlabel];
            self.labelForDetail = view;
            
            view.backgroundColor = self.contentView.backgroundColor;
            view.delegate = self;
            [self.contentView addSubview:view];            
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
    
    self.textLabel.frame = CGRectMake(0, 1 + MARGIN, LEFT_SIZE, 12);
    self.viewForBackground.frame = self.contentView.bounds;
    
    self.labelForDetail.frame = CGRectMake(LEFT_SIZE+OFFSET_MARGIN, MARGIN, WIDTH_FOR_TEXT, self.contentView.height - MARGIN*2);
}

- (void) updateFontSize
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSUInteger fontSize = [userDefaults integerForKey:@"FontSizeForTimeLine"];
    fontSize = fontSize - 2;
    if (fontSize < 9) fontSize = 9;

    if (self.fontSizeLast == fontSize) return;
    
    self.textLabel.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    self.labelForDetail.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    self.fontSizeLast = fontSize;
}

- (void) setData:(NSDictionary*)data
{
    self.textLabel.text = data[@"name"];
    self.labelForDetail.text = data[@"detail"];
    
    [self updateFontSize];
    [self layoutSubviews];
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

+ (UUDetailCell*) cell:(UITableView*)tableView
{
    static NSString* Identifier = @"UUDetailCell";
    UUDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UUDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
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
    fontSize = fontSize - 2;
    if (fontSize < 9) fontSize = 9;
    
    CGFloat height = MARGIN * 2;
    RTLabel* label = [self rtlabelForHeight];
    label.frame = CGRectMake(0, 0, WIDTH_FOR_TEXT, INT_MAX);
    label.font = [UIFont fontWithName:FONT_NAME size:fontSize];
    
    label.text = data[@"detail"];
    height += label.optimumSize.height;
    
    if (height < DEFAULT_HEIGHT) height = DEFAULT_HEIGHT;
    return height;
}

@end
