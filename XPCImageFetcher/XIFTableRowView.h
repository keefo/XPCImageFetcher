//
//  XIFTableRowView.h
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XIFTableRowView : NSTableRowView
{
@private
    id _objectValue;
}

@property(retain) id objectValue;
@end
