//
//  ImageDownloadOperation.h
//  ImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIFImage.h"

@interface ImageDownloadOperation : NSOperation
@property(copy) NSURL *url;
@property(copy) NSString *uuid;
@property(assign) NSURLRequestCachePolicy policy;
@property (nonatomic, copy) void (^callback)(XIFImage*);

- (id)initWithURL:(NSURL*)url andUUID:(NSString*)uuid cachePolicy:(NSURLRequestCachePolicy)policy callBack:(void(^)(XIFImage *img))block;

- (void)startOnDelegateQueue:(NSOperationQueue*)queue;

@end
