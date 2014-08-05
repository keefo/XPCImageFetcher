//
//  XIFImage.h
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum : NSInteger {
	PicResizeCover    = 1,
	PicResizeFit      = 2,
    PicResizeNone     = 3,
} PicResizeMode;


@interface XIFImage : NSObject <NSSecureCoding>
@property (copy, nonatomic) NSData *data;
@property (copy) NSURL *url;
@property (copy) NSString *uuid;

- (id)initWithData:(NSData*)d;

- (NSImage*)nsimage;
- (XIFImage*)reiszeImage:(PicResizeMode)resizeMode
                withSize:(NSSize)targetSize
                withType:(NSBitmapImageFileType)type
          withProperties:(NSDictionary*)properties;


@end
