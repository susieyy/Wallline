//
//  VCTimeLineViewController+Transition.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/03.
//
//

#import "VCTimeLineViewController+Transition.h"
#import "VCTimeLineViewController+Action.h"

#import "MPFoldTransition.h"
#import "MPFlipTransition.h"

#import "UUTimeLineCell.h"

#define DURATION 0.6f

@implementation VCTimeLineViewController (Transition)

- (void) removeViewForLoading;
{
    SS_MLOG(self);
    __weak VCTimeLineViewController* _self = self;    
    if (self.viewForLoading == nil) return;
    
    [self.viewForLoading removeFromSuperview];
    self.viewForLoading = nil;
}

- (void) cancelAllRequest;
{
    SS_MLOG(self);
    [self cancelRequestConnection];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager cancelForDelegate:self.viewForCoverImage];
   
    for (UITableViewCell* _cell in [self.tableView visibleCells]) {
        if ([_cell respondsToSelector:@selector(cancelRequest)]) {
            [_cell performSelector:@selector(cancelRequest)];
        }
    }
}

#pragma -
#pragma Close

- (IBAction) closeAction:(id)sender
{
    SS_MLOG(self);
    
    __weak VCTimeLineViewController* _self = self;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* button = sender;
        [button setEnabled:NO];
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Request
    [self cancelAllRequest];
    [self.progressViewController hideNoticeView];
    
    [self.tableView setScrollEnabled:NO];
    
    UIView* viewForFrom = nil;
    UIView* viewForTo = nil;
    {
        UIImage* image = [UIImage imageFromlayer:self.viewForTableContainer.layer];        
        UIImageView* view = [[UIImageView alloc] initWithFrame:self.viewForTableContainer.bounds];
        view.image = image;
        viewForFrom = view;
        [self.viewForContainer addSubview:view];
        self.viewForLoading = view;
    }
    {
        viewForTo = self.viewForTableContainer;
    }
    
    
    [self _popStackCompletionBlock:^{

        [_self calcCellHeightByFontSizeChange];
        [_self reloadDataNeedCellUpdate:YES];
        [_self.tableView setScrollEnabled:YES];
        
        [_self updateHeaderTitle];
        [_self updateCoverImage];
        
        double delayInSeconds = 0.6f;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [MPFlipTransition transitionFromView:viewForFrom
                                          toView:viewForTo
                                        duration:DURATION
                                           style:MPFlipStyleDirectionBackward
                                transitionAction:MPTransitionActionNone
                                      completion:^(BOOL finished) {
                                          [_self updateHeaderTitle];
                                          [_self updateHeaderButtons];                                          
                                          [_self removeViewForLoading];
                                      }];            
        });
    }];
    
}

#pragma -
#pragma Open

- (IBAction) openWithObjectType:(NSString*)objectType ID:(NSString*)ID SUBID:(NSString*)SUBID;
{
    SS_MLOG(self);
    SSLog(@"    ObjectType [%@] ID [%@] SUBID [%@]", objectType, ID, SUBID);
    
    __weak VCTimeLineViewController* _self = self;    
    
    ///////////////////////////////////////////////////////////////////////////////
    // For Status
    MMStatusModel* __statusModel = [self __statusModelFromID:ID];
    ///////////////////////////////////////////////////////////////////////////////
    
    ///////////////////////////////////////////////////////////////////////////////
    // Request
    [self cancelAllRequest];
    [self.progressViewController hideNoticeView];
    
    [self _pushStackCompletionBlock:^{    
        // Finish Archive
    }];
    
    // status / friend / event / page / application / localtion
    [self.stackModel setObjectType:objectType ID:ID SUBID:SUBID];

    ///////////////////////////////////////////////////////////////////////////////
    // For Status
    if (self.stackModel.timeLineType == VCTimeLineTypeStream && __statusModel) {
        MMStatusModel* statusModel = [[MMStatusModel alloc] init];
        statusModel.data = __statusModel.data;
        statusModel.isStatusMode = YES;
        [statusModel createTextComponents];
        self.stackModel.datas = @[statusModel];
    }
    ///////////////////////////////////////////////////////////////////////////////

    [self updateHeaderTitle];
    [self updateHeaderButtons];

    [self.viewForCoverImage setImage:nil];   
    
    [self _switchToViewTransitionCompletionBlock:^(){
        [_self reloadDataNeedCellUpdate:YES];
        if (_self.stackModel.timeLineType == VCTimeLineTypeStream) {
            [_self.tableView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
        }        
        [_self requestNowAction:nil];
    }];
 

}

- (void) _switchToViewTransitionCompletionBlock:(SSBlockVoid)completionBlock;
{
    __weak VCTimeLineViewController* _self = self;    
    
    UIView* viewForFrom = nil;
    UIView* viewForTo = nil;
    {
        viewForFrom = self.viewForTableContainer;
    }
    {
        UIView* view = [[UIView alloc] initWithFrame:self.viewForContainer.bounds];
        view.backgroundColor = COLOR_FOR_BACKGROUND_TABLE;
        viewForTo = view;
        self.viewForLoading = view;
    }

    [MPFlipTransition transitionFromView:viewForFrom
                                  toView:viewForTo
                                duration:DURATION
                                   style:MPFlipStyleDefault
                        transitionAction:MPTransitionActionNone
                              completion:^(BOOL finished) {
                                  if (finished && completionBlock) completionBlock();
                              }];
}

#pragma -
#pragma Stack

- (void) _pushStackCompletionBlock:(SSBlockVoid)completionBlock;
{
    SS_MLOG(self);
    MMStackModel* stackModelOLD = self.stackModel;
    MMStackModel* stackModel = [[MMStackModel alloc] init];
    self.stackModel = stackModel;
    [self.stackUUIDs addObject:stackModel.UUID];
    SSLog(@"    STACK PUSH %@", [stackModel description]);
    
    stackModelOLD.tableOffset = self.tableView.contentOffset.y;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [stackModelOLD archive];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) completionBlock();
        });
    });
    
}

- (void) _popStackCompletionBlock:(SSBlockVoid)completionBlock;
{
    SS_MLOG(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.stackUUIDs removeLastObject];
        NSString* UUID = [self.stackUUIDs objectAtIndexLast];
        if (UUID) {
            MMStackModel* stackModel = [MMStackModel unarchive:UUID];
            self.stackModel = stackModel;
            SSLog(@"    STACK POP  %@", [stackModel description]);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) completionBlock();
            [self.tableView setContentOffset:CGPointMake(0, self.stackModel.tableOffset) animated:NO];
        });
    });
}


@end
