//
//  XIFTableCellView.h
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XIFImage.h"

@interface XIFTableCellView : NSTableCellView
@property(retain) XIFImage *image;
@property(assign) IBOutlet NSTextField *titleField;
@property(assign) IBOutlet NSProgressIndicator *loadingGear;

@end
