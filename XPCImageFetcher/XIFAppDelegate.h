//
//  XIFAppDelegate.h
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XIFTableCellView.h"
#import "XIFTableRowView.h"

@interface XIFAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableView;

@end
