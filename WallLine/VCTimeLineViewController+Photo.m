//
//  VCTimeLineViewController+Photo.m
//  Wallline
//
//  Created by Youhei Sugigami on 12/08/21.
//
//

#import "VCTimeLineViewController+Photo.h"

#import "MWRTPhotoBrowserViewController.h"
#import "MWPhotoBrowser.h"

@implementation VCTimeLineViewController (Photo)
/*
- (void) clearPhotoState
{
    self.photoBrowser = nil;
    self.photoModels = nil;
    
    [self.requestConnectionForPhoto cancel];
    [self.requestConnectionForAlbum cancel];
    
    self.requestConnectionForPhoto = nil;
    self.requestConnectionForAlbum = nil;
}

- (void) _didCloseMWRTPhotoBrowserViewController:(NSNotification*)notification
{
    [self clearPhotoState];
}

- (void) viewDidLoadForPhoto
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didCloseMWRTPhotoBrowserViewController:) name:NFDidCloseMWRTPhotoBrowserViewController object:nil];
}
*/

- (void) showPhotoBrowserAsPhoto:(NSString*)objectID
{
    SS_MLOG(self);
    /*
    [self clearPhotoState];
    
    __weak VCTimeLineViewController* _self = self;
    [self requestPhoto:objectID completionBlock:^(NSError* error){
        if (error == nil) {
            [_self reloadPhotoBrowser];
            [_self _requestAlbumAction:nil];
        }
    }];
    */
 
    [self performSegueWithIdentifier:@"SEGUE_PHOTO" sender:objectID];
}

- (void) showPhotoBrowserAsAlbum:(NSString*)objectID
{
    SS_MLOG(self);
    /*
    [self clearPhotoState];
    
    __weak VCTimeLineViewController* _self = self;
    [self requestAlbum:objectID completionBlock:^(NSError* error){
        if (error == nil) {
            [_self reloadPhotoBrowser];
        }
    }];
    */
    
    [self performSegueWithIdentifier:@"SEGUE_PHOTO" sender:objectID];
}
/*
- (void) reloadPhotoBrowser
{
    SS_MLOG(self);
    [self.photoBrowser reloadData];
}

- (void) _requestAlbumAction:(id)sender
{
    if (NO == (self.photoModels && self.photoModels.count)) return;
    __weak VCTimeLineViewController* _self = self;
    MMPhotoModel* model = self.photoModels[0];
    NSString* albumID = [model albumID];
    
    [self requestAlbum:albumID completionBlock:^(NSError* error){
        if (error == nil) {
            SSLog(@"PhotoBrowser reloadDataAppend");
            [_self.photoBrowser reloadDataAppend];
        }
    }];
}

#pragma -
#pragma MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
{
    if (self.photoModels && self.photoModels.count) {
        NSUInteger count = self.photoModels.count;
        return count;
    } else {
        return 0;
    }
}

- (id<MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
{
    if (self.photoModels && self.photoModels.count > index) {
        MMPhotoModel* model = self.photoModels[index];
        NSString* source = model[@"source"];
        NSURL* URL = [NSURL URLWithString:source];
        
        MWRTPhoto* photo = [[MWRTPhoto alloc] initWithURL:URL];
        NSString* name = model[@"name"];
        photo.caption = [name stringByReplacingRegexPattern:@"[\\n\\r]" withString:@""];
        photo.photoModel = model;
        return photo;
    }
    return nil;
}

//@optional
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
    MWPhoto *photo = [self photoBrowser:photoBrowser photoAtIndex:index];
    MWRTCaptionView *captionView = [[MWRTCaptionView alloc] initWithPhoto:photo];
    return captionView;
}
*/

@end
