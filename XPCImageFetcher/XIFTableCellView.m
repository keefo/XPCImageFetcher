//
//  XIFTableCellView.m
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import "XIFTableCellView.h"

@implementation XIFTableCellView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    if (self.image) {
        [self.image.nsimage drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }
}

@end
