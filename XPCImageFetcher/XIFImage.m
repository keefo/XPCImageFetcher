//
//  XIFImage.m
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import "XIFImage.h"

@interface XIFImage()
{
    NSImage *cachedImage;
}
@end

@implementation XIFImage

- (id)initWithData:(NSData*)d;
{
    if (self=[super init]) {
        self.data = d;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        // NSSecureCoding requires that we specify the class of the object while decoding it, using the decodeObjectOfClass:forKey: method.
        _data = [aDecoder decodeObjectOfClass:[NSData class] forKey:@"data"];
        _url = [aDecoder decodeObjectOfClass:[NSURL class] forKey:@"url"];
        _uuid = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"uuid"];
        
    }
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_data forKey:@"data"];
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_uuid forKey:@"uuid"];
}

- (void)setData:(NSData *)data
{
    _data=data;
    if (cachedImage) {
        cachedImage=nil;
    }
}

- (NSImage*)nsimage
{
    if (cachedImage==nil) {
        cachedImage=[[NSImage alloc] initWithData:_data];
    }
    return cachedImage;
}

- (XIFImage*)reiszeImage:(PicResizeMode)resizeMode
                withSize:(NSSize)targetSize
                withType:(NSBitmapImageFileType)type
          withProperties:(NSDictionary*)properties
{
    NSImage *image=self.nsimage;
    if (!image) {
        return nil;
    }
    
    NSImage *resizedImage=nil;
    if(resizeMode==PicResizeCover){
        
        resizedImage=[[NSImage alloc] initWithSize:targetSize];
        [resizedImage lockFocus];
        
        if (image.size.width>image.size.height) {
            [image drawInRect:NSMakeRect(0, 0, targetSize.width, targetSize.height) fromRect:NSMakeRect((image.size.width-image.size.height)/2.0, 0, image.size.height, image.size.height) operation:NSCompositeSourceOver fraction:1];
        }
        else if(image.size.width<image.size.height){
            [image drawInRect:NSMakeRect(0, 0, targetSize.width, targetSize.height) fromRect:NSMakeRect(0, (image.size.height-image.size.width), image.size.width, image.size.width) operation:NSCompositeSourceOver fraction:1];
        }else{
            [image drawInRect:NSMakeRect(0, 0, targetSize.width, targetSize.height) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
        }
        
        [resizedImage unlockFocus];
    }
    else{
        
        if (image.size.width<targetSize.width && image.size.height<targetSize.height) {
            resizedImage=image;
        }
        else{
            NSSize finalSize;
            float r1=targetSize.width/image.size.width;
            float r2=targetSize.height/image.size.height;
            if (r1<r2) {
                finalSize=NSMakeSize((NSInteger)image.size.width*r1, (NSInteger)image.size.height*r1);
            }else{
                finalSize=NSMakeSize((NSInteger)image.size.width*r2, (NSInteger)image.size.height*r2);
            }
            
            [image setSize:targetSize];
            resizedImage=[[NSImage alloc] initWithSize:finalSize];
            [resizedImage lockFocus];
            NSRect rect=NSMakeRect(0, 0, finalSize.width, finalSize.height);
            [image drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
            [resizedImage unlockFocus];
        }
    }
    
    if (!resizedImage) {
        return nil;
    }
    
    [resizedImage lockFocus];
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, resizedImage.size.width, resizedImage.size.height)];
    [resizedImage unlockFocus];
    
    NSData *resizeData = nil;
    
    if (type==NSPNGFileType) {
        resizeData = [bitmapRep representationUsingType:NSPNGFileType properties:properties];
    }
    else if (type==NSJPEGFileType) {
        resizeData = [bitmapRep representationUsingType:NSJPEGFileType properties:properties];
    }
    else if (type==NSGIFFileType) {
        resizeData = [bitmapRep representationUsingType:NSGIFFileType properties:properties];
    }
    else if (type==NSBMPFileType) {
        resizeData = [bitmapRep representationUsingType:NSBMPFileType properties:properties];
    }
    else if (type==NSTIFFFileType) {
        resizeData = [bitmapRep representationUsingType:NSTIFFFileType properties:properties];
    }
    else if (type==NSJPEG2000FileType) {
        resizeData = [bitmapRep representationUsingType:NSJPEG2000FileType properties:properties];
    }
    else{
        resizeData = [bitmapRep representationUsingType:NSPNGFileType properties:properties];
    }
    
    XIFImage *resizeXIFImage = [[XIFImage alloc] initWithData:resizeData];
    resizeXIFImage.url=self.url;
    resizeXIFImage.uuid=self.uuid;
    return resizeXIFImage;
}


@end
