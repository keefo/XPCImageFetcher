//
//  XIFImageFetcherProtocol.h
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIFImage.h"

@protocol XIFImageFetcherProtocol <NSObject>

- (void)downloadImage:(NSURL*)url
             withUUID:(NSString*)uuid
          cachePolicy:(NSURLRequestCachePolicy)policy
             withSize:(NSSize)targetSize
           resizeMode:(PicResizeMode)targetResizeMode
            imageType:(NSBitmapImageFileType)type
           properties:(NSDictionary *)properties
             callback:(void(^)(XIFImage *image))block;

- (void)cancelDownloadImageWithUUID:(NSString*)uuid;


@end
