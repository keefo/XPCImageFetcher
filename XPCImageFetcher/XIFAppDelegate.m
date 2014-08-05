//
//  XIFAppDelegate.m
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import "XIFAppDelegate.h"
#import "XIFImageFetcherProtocol.h"
#import "XIFTableModel.h"

@interface XIFAppDelegate()
{
    id<XIFImageFetcherProtocol> _imageFetcher;
    NSMutableArray *list;
    NSMutableArray *_observedVisibleItems;
}
@end



@implementation XIFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _window.title = @"image table with xpc backend";
    list=[NSMutableArray array];
    
    if (_observedVisibleItems == nil) {
        _observedVisibleItems = [NSMutableArray new];
    }
    
    NSXPCConnection *connection = [[NSXPCConnection alloc] initWithServiceName:@"com.beyondcow.ImageFetcher"];
    connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XIFImageFetcherProtocol)];
    [connection resume];
    
    _imageFetcher = [connection remoteObjectProxyWithErrorHandler:^(NSError *err) {
        // Since we're updating the UI, we must do this work on the main thread
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"erro=%@", [NSString stringWithFormat:@"There was an error: %@", err]);
        }];
    }];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        
        NSData *jsonData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://jsonplaceholder.typicode.com/photos"]];
        
        NSError *error = nil;
        NSMutableArray *array = [NSJSONSerialization
                     JSONObjectWithData:jsonData
                     options:0
                     error:&error];
        
        NSLog(@"%@", array);
        for(NSDictionary *d in array){
            XIFTableModel *model=[XIFTableModel newModel:d[@"thumbnailUrl"]];
            model.url=[NSURL URLWithString:d[@"url"]];
            model.photoid=d[@"id"];
            model.title=d[@"title"];
            [list addObject:model];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [_tableView reloadData];
        }];
        
        
    });


}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"image"] && [object isKindOfClass:[XIFTableModel class]]) {
        NSInteger row = [list indexOfObject:object];
        if (row != NSNotFound) {
            XIFTableModel *item = list[row];
            
            XIFTableCellView *cellView = [_tableView viewAtColumn:0 row:row makeIfNecessary:NO];
            if (cellView) {
                if (item.image) {
                    [NSAnimationContext beginGrouping];
                    [[NSAnimationContext currentContext] setDuration:0.8];
                    [cellView.imageView setAlphaValue:0];
                    [cellView.imageView setImage:item.image.nsimage];
                    [cellView.imageView setHidden:NO];
                    [[cellView.imageView animator] setAlphaValue:1.0];
                    [NSAnimationContext endGrouping];
                    [cellView.loadingGear stopAnimation:nil];
                }
            }
            
            @try {
                [item removeObserver:self forKeyPath:@"image"];
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        }
    }
}



#pragma mark - TableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
{
    return list.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;
{
    return 150.0f;
}

- (void)tableView:(NSTableView *)tableView didRemoveRowView:(XIFTableRowView *)rowView forRow:(NSInteger)row {
    // Stop observing visible things
    //NSLog(@"remove row %d", row);
    XIFTableModel *item=list[row];
    if ([_observedVisibleItems containsObject:item]) {
        [_imageFetcher cancelDownloadImageWithUUID:item.uuid];
        @try {
            [item removeObserver:self forKeyPath:@"image"];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        [_observedVisibleItems removeObject:item];
    }
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
    XIFTableModel *item=list[row];
    
    //NSLog(@"_observedVisibleItems=%lu", _observedVisibleItems.count);
    
    XIFTableCellView *cellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    if (cellView) {
        cellView.textField.stringValue = item.photoid;
        cellView.titleField.stringValue = item.title;
        
        if (item.image) {
            [cellView.imageView setHidden:NO];
            [cellView.imageView setImage:item.image.nsimage];
            [cellView.imageView setNeedsDisplay:YES];
            [cellView.loadingGear stopAnimation:nil];
        }else{
            if (![_observedVisibleItems containsObject:item]) {
                
                [cellView.loadingGear setHidden:NO];
                [cellView.loadingGear startAnimation:nil];
                [_observedVisibleItems addObject:item];
                [cellView.imageView setHidden:YES];
                
                [item addObserver:self forKeyPath:@"image" options:0 context:NULL];
                
                [_imageFetcher downloadImage:item.url
                                    withUUID:item.uuid
                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    withSize:NSMakeSize(150, 150)
                                  resizeMode:PicResizeCover
                                   imageType:NSJPEG2000FileType
                                  properties:nil
                                    callback:^(XIFImage *image) {
                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                            item.image = image;
                                        }];
                                    }];
                
            }
        }
    }
    return cellView;
}

@end
