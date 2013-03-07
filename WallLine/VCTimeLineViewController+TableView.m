//
//  VCTimeLineViewController+TableView.m
//  Wallline
//
//  Created by 杉上 洋平 on 12/06/19.
//  Copyright (c) 2012年 個人事業主. All rights reserved.
//

#import "VCTimeLineViewController+TableView.h"
#import "VCTimeLineViewController+Define.h"

#import "UUTimeLineCell.h"
#import "UUCoverImageCell.h"
#import "UUDetailCell.h"
#import "UULikeCell.h"
#import "UUCommentCell.h"
#import "UUTimeLineHeaderCell.h"
#import "UUDetailButtonCell.h"

#import "ODRefreshControl.h"

#define SECTION_COVER 0 
#define SECTION_ABOUT_HEADER 1
#define SECTION_ABOUT 2
#define SECTION_STATUS_HEADER 3
#define SECTION_STATUS 4
#define SECTION_STATUS_LIKE 5
#define SECTION_STATUS_COMMENT 6
#define SECTION_NO_STATUS 7
#define SECTION_REQUESTING 8

#define HEIGHT_FOR_SECTION 24.0f
#define HEIGHT_FOR_FOOTER_MORE 66.0f

@implementation VCTimeLineViewController (TableView)

- (void) doReHeightTimeLineCell:(NSNotification*)notification
{
    SS_MLOG(self);
    if (self.stackModel.datas == nil || self.stackModel.datas.count == 0) return;
    
    MMStatusModel* statusModel = [notification object];
    NSUInteger index = [self.stackModel.datas indexOfObject:statusModel];
    if (index == NSNotFound) return;
    if (self.stackModel.datas.count <= index) return;
    
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:SECTION_STATUS];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


- (void) reloadDataNeedCellUpdate:(BOOL)isNeedCellUpdate;
{
    SS_ELOG(self);
    
    if (isNeedCellUpdate) {
        for (MMStatusModel* statusModel in self.stackModel.datas) {
            statusModel.isNeedCellUpdate = YES;
        }
    }
    if (self.isStatusMode) {
        for (MMStatusModel* statusModel in self.stackModel.datas) {
            statusModel.isStatusMode = YES;
        }    
    }
    
    [self.tableView reloadData];
    
    NSString* graphPath = [self.stackModel.paging objectForKey:@"next"];
    if (self.stackModel.datas.count && graphPath) {
        self.tableView.tableFooterView = self.buttonForMore;
        self.buttonForMore.height = HEIGHT_FOR_FOOTER_MORE;
    } else {
        self.tableView.tableFooterView = nil;
    }

    [self viewDidLayoutSubviews];
}

- (void) viewDidLoadForTableView;
{
    __weak VCTimeLineViewController* _self = self;
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // TableView
    {
        UITableView* view = [[UITableView alloc] initWithFrame:self.viewForTableContainer.bounds style:UITableViewStylePlain];
        view.delegate = self;
        view.dataSource = self;
        view.separatorStyle = UITableViewCellSeparatorStyleNone;
        view.backgroundColor = [UIColor clearColor]; //HEXCOLOR(0x232937);
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;            
        view.allowsSelection = NO;
        view.scrollsToTop = YES;        
        [self.viewForTableContainer addSubview:view];
        self.tableView = view;
        
        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
        [view addGestureRecognizer:pinch];
    }   
 
    ///////////////////////////////////////////////////////////////////////////////
    // ODRefreshControl
    {
        ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
        //[refreshControl setTintColor:HEXCOLOR(0xEEEEEE)];
        [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
        
        for (UIView* view in refreshControl.subviews) {
            if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
                [view removeFromSuperview];
                break;
            }
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // FooterView
    {
        UIView* viewForFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, HEIGHT_FOR_FOOTER_MORE)];
        viewForFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        viewForFooter.backgroundColor = COLOR_FOR_BACKGROUND;
        UIBlockButton* button = nil;
        {
            button = [UIBlockButton buttonWithType:UIButtonTypeCustom];
            button.frame = viewForFooter.bounds;
            button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [viewForFooter addSubview:button];
            
            [button setTitle:NSLocalizedString(@"More", @"") forState:UIControlStateNormal];                    
            [button addTarget:self action:@selector(requestNextAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
            {
                UIImage* image = [UIImage imageWithSize:CGSizeMake(10, 10) color:COLOR_FOR_BACKGROUND];
                [button setBackgroundImage:image forState:UIControlStateNormal];
                [button setTitleColor:COLOR_FOR_TEXT_BLUE forState:UIControlStateNormal];                
                [button setTitleShadowColor:HEXCOLOR(0xCCCCCC) forState:UIControlStateNormal];                                
                
            }
            {
                UIImage* image = [UIImage imageWithSize:CGSizeMake(10, 10) color:COLOR_FOR_BACKGROUND_SELECT];
                [button setBackgroundImage:image forState:UIControlStateHighlighted];
                [button setTitleColor:COLOR_FOR_TEXT_BLUE_SELECT forState:UIControlStateHighlighted];                
                [button setTitleShadowColor:HEXCOLOR(0xCCCCCC) forState:UIControlStateHighlighted];                
            }
            
            UILabel* label = button.titleLabel;
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];            
            self.buttonForMore = button;
        }
    }
}

#pragma -
#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    if (scrollView.contentOffset.y <= HEIGHT_FOR_SECTION && scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=HEIGHT_FOR_SECTION) {
        scrollView.contentInset = UIEdgeInsetsMake(-HEIGHT_FOR_SECTION, 0, 0, 0);
    }
}


#pragma -
#pragma ODRefreshControl

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    [self requestNowAction:nil];
}

- (BOOL) isStatusMode
{
    return !!(self.stackModel.timeLineType == VCTimeLineTypeStream);
}

#pragma -
#pragma UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 9;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{

    ///////////////////////////////////////////////////////////////////////////////
    // Requsting
    if (self.stackModel.isRequested == NO && self.isStatusMode == NO) {
        if (section == SECTION_COVER || section == SECTION_REQUESTING) {
            return 1;
        } else {
            return 0;
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // 
    if (section == SECTION_COVER) {
        return 1;
    }
    if (section == SECTION_ABOUT_HEADER) {
        if (self.stackModel.isRequested) {
            if (self.stackModel.timeLineType == VCTimeLineTypePage ||
                self.stackModel.timeLineType == VCTimeLineTypeFriend) {
                return 1;
            }
        }
        return 0;
    }
    if (section == SECTION_ABOUT) {
        MMAbstModel* model = self.stackModel.model;
        NSArray* items = model.items;
        if (items) {
            return items.count;
        }
        return 0;
    }
    
    if (section == SECTION_STATUS_HEADER) {
        if (self.isStatusMode && self.stackModel.datas.count) return 1;
        return 0;
    }

    if (section == SECTION_STATUS) {
        if (self.stackModel.datas == nil) {
            return 0;
        } else {
            return self.stackModel.datas.count;
        }
    }
    
    if (section == SECTION_STATUS_LIKE) {
        if (self.isStatusMode && self.stackModel.datas.count) {
            MMStatusModel* model = self.stackModel.datas[0];
            NSArray* array = model[@"likes"][@"data"];
            if (array) return array.count + 1;
            return 0;
        } else {
            return 0;
        }
    }
    if (section == SECTION_STATUS_COMMENT) {
        if (self.isStatusMode && self.stackModel.datas.count) {
            MMStatusModel* model = self.stackModel.datas[0];            
            NSArray* array = model[@"comments"][@"data"];
            if (array) return array.count + 1;
            return 0;
        } else {
            return 0;
        }   
    }

    if (section == SECTION_NO_STATUS) {
        if (self.isStatusMode) return 0;
        if (self.stackModel.datas && self.stackModel.datas.count == 0) {
            return 1;
        } else {
            return 0;
        }
    }

    if (section == SECTION_REQUESTING) {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == SECTION_COVER) {
        return CoverImageVisibleHeight;
    }
    if (indexPath.section == SECTION_ABOUT_HEADER) {
        return 44.0f;
    }
    if (indexPath.section == SECTION_ABOUT) {
        MMAbstModel* model = self.stackModel.model;
        NSArray* items = model.items;
        if (items) {
            NSDictionary* info = items[indexPath.row];
            return [UUDetailCell heightFromData:info];
        }
        return 0.0f;
    }
    if (indexPath.section == SECTION_STATUS_HEADER) {
        return [UUTimeLineHeaderCell heightFromData:nil];
    }
    if (indexPath.section == SECTION_STATUS) {
        if (self.stackModel.datas.count) {
            MMStatusModel* data = self.stackModel.datas[indexPath.row];
            if (data.height > 0.0f) return data.height;
            data.height = [UUTimeLineCell heightFromData:data];
            return data.height;
        } else {
            return self.tableView.height - CoverImageVisibleHeight;
        }
    }
    if (indexPath.section == SECTION_STATUS_LIKE) {
        if (indexPath.row == 0) return HEIGHT_FOR_SECTION;        
        return [UULikeCell heightFromData:nil];
    }
    if (indexPath.section == SECTION_STATUS_COMMENT) {
        if (indexPath.row == 0) return HEIGHT_FOR_SECTION;        
        MMStatusModel* model = self.stackModel.datas[0];
        NSArray* array = model[@"comments"][@"data"];
        NSUInteger index = indexPath.row-1;
        NSDictionary* data = array[index];
        return [UUCommentCell heightFromData:data];
    }
    if (indexPath.section == SECTION_NO_STATUS || indexPath.section == SECTION_REQUESTING) {
        return self.tableView.height - CoverImageVisibleHeight;
    }
}

#pragma -
#pragma

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ///////////////////////////////////////////////////////////////////////////////
    // Cover
    if (indexPath.section == SECTION_COVER) {
        if (self.stackModel.isRequested == NO) {
            return [self cellForDummyAtIndexPath:indexPath tableView:tableView text:nil];
        }

        UUCoverImageCell* cell = [UUCoverImageCell cell:tableView];
        return cell;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // About Header
    if (indexPath.section == SECTION_ABOUT_HEADER) {
        if (self.stackModel.isRequested == NO) {
            return [self cellForDummyAtIndexPath:indexPath tableView:tableView text:nil];
        }
        UUDetailButtonCell* cell = [UUDetailButtonCell cell:tableView];
        [cell setStackModel:self.stackModel];
        return cell;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // About
    if (indexPath.section == SECTION_ABOUT) {
        if (self.stackModel.isRequested == NO) {
            return [self cellForDummyAtIndexPath:indexPath tableView:tableView text:nil];
        }
        UUDetailCell* cell = [UUDetailCell cell:tableView];
        MMAbstModel* model = self.stackModel.model;
        NSArray* items = model.items;
        if (items) {
            NSDictionary* info = items[indexPath.row];
            [cell setData:info];
        }
        return cell;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // Staus Header
    if (indexPath.section == SECTION_STATUS_HEADER) {
        MMStatusModel* statusModel = self.stackModel.datas[0];        
        UUTimeLineHeaderCell* cell = [UUTimeLineHeaderCell cell:tableView];
        [cell setData:statusModel];
        return cell;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Status
    if (indexPath.section == SECTION_STATUS) {
        MMStatusModel* statusModel = self.stackModel.datas[indexPath.row];
        UUTimeLineCell* cell = [UUTimeLineCell cell:tableView];
        cell.isStatusMode = self.isStatusMode;
        [cell setDataModel:statusModel];
        return cell;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // Header Likes / Comments
    if ((indexPath.section == SECTION_STATUS_LIKE || indexPath.section == SECTION_STATUS_COMMENT) && indexPath.row == 0) {
        static NSString* Identifier = @"HeaderLabelCell";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = HEXCOLOR(0xCCCCCC);
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            cell.contentView.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        }
        
        MMStatusModel* model = self.stackModel.datas[0];        
        if (indexPath.section == SECTION_STATUS_LIKE) {
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@", [model countForLike], NSLocalizedString(@"Likes", @"")];
        }
        if (indexPath.section == SECTION_STATUS_COMMENT) {        
            cell.textLabel.text = [NSString stringWithFormat:@"%d %@", [model countForComment], NSLocalizedString(@"Comments", @"")];
        }
        return cell;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Status Like
    if (indexPath.section == SECTION_STATUS_LIKE) {
        MMStatusModel* model = self.stackModel.datas[0];
        NSArray* array = model[@"likes"][@"data"];
        NSUInteger index = indexPath.row-1;
        NSDictionary* data = array[index];
        
        UULikeCell* cell = [UULikeCell cell:tableView];
        [cell setData:data];
        return cell;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // Status Comment
    if (indexPath.section == SECTION_STATUS_COMMENT) {
        MMStatusModel* model = self.stackModel.datas[0];
        NSArray* array = model[@"comments"][@"data"];
        NSUInteger index = indexPath.row-1;
        NSDictionary* data = array[index];
       
        UUCommentCell* cell = [UUCommentCell cell:tableView];
        [cell setData:data];
        return cell;
    }

    ///////////////////////////////////////////////////////////////////////////////
    // NoStatus
    if (indexPath.section == SECTION_NO_STATUS) {
        return [self cellForDummyAtIndexPath:indexPath tableView:tableView text:NSLocalizedString(@"No status found.", @"")];        
    }
        
    ///////////////////////////////////////////////////////////////////////////////
    // Requesting
    if (indexPath.section == SECTION_REQUESTING) {
        return [self cellForDummyAtIndexPath:indexPath tableView:tableView text:nil];
    }
    
}

- (UITableViewCell *)cellForDummyAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView*)tableView text:(NSString*)text
{
    static NSString* Identifier = @"DummyStatusIdentifier";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = HEXCOLOR(0xCCCCCC);
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
        cell.textLabel.shadowColor = HEXCOLOR(0xFFFFFF);
        cell.textLabel.shadowOffset = CGSizeMake(0.5f, 0.5f);
    }
    
    if (text == nil) text = @"";
    cell.textLabel.text = text;
    
    if (indexPath.section == SECTION_COVER || indexPath.section == SECTION_ABOUT) {
        cell.contentView.backgroundColor = [UIColor clearColor];
    } else {
        cell.contentView.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
    }
    return cell;
}

@end
