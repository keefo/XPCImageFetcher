//
//  main.m
//  ImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#include <xpc/xpc.h>
#include <Foundation/Foundation.h>
#import "XIFImageFetcherProtocol.h"
#import "ImageDownloadOperation.h"

@interface XIFImageFetcherService : NSObject <NSXPCListenerDelegate, XIFImageFetcherProtocol>
{
@private
    NSOperationQueue *downloadQueue;
    NSMutableDictionary *operationDict;
}
@end

@implementation XIFImageFetcherService

- (id)init
{
    if (self=[super init]) {
        if(downloadQueue==nil){
            NSUInteger count=100;
            downloadQueue = [[NSOperationQueue alloc] init];
            [downloadQueue setMaxConcurrentOperationCount:count];
        }
        operationDict = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    return self;
}

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // This method will be called by the NSXPCListener. It gives the delegate an opportunity to configure and accept (or reject) a new incoming connection.
    
    // The connection is created, but unconfigured and suspended. We will finish configuring it here, resume it, and return YES.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(XIFImageFetcherProtocol)];
    
    // This object instance is both the delegate and the singleton implementation of the Agent protocol. Another common pattern may be to create a new object to serve as the exportedObject for each new connection.
    newConnection.exportedObject = self;
    
    // Allow messages to be received.
    [newConnection resume];
    return YES;
}


- (void)cancelDownloadImageWithUUID:(NSString*)uuid;
{
    ImageDownloadOperation *op = [operationDict objectForKey:uuid];
    if (op) {
        [op cancel];
        [operationDict removeObjectForKey:uuid];
    }
}

- (void)downloadImage:(NSURL*)url
             withUUID:(NSString*)uuid
          cachePolicy:(NSURLRequestCachePolicy)policy
             withSize:(NSSize)targetSize
           resizeMode:(PicResizeMode)targetResizeMode
            imageType:(NSBitmapImageFileType)type
           properties:(NSDictionary *)properties
             callback:(void(^)(XIFImage *image))block;
{
    if (url==nil || [url isKindOfClass:[NSURL class]]==NO) {
        block(nil);
        return;
    }
    
    if (targetSize.width<=0 || targetSize.height<=0) {
        NSLog(@"wrong image size %@", NSStringFromSize(targetSize));
        block(nil);
        return;
    }
    
    ImageDownloadOperation *operation=nil;
    if (targetResizeMode==PicResizeNone) {
        operation = [[ImageDownloadOperation alloc] initWithURL:url andUUID:uuid cachePolicy:policy callBack:block];
    }
    else{
        operation = [[ImageDownloadOperation alloc] initWithURL:url andUUID:uuid cachePolicy:policy callBack:^(XIFImage *xifimage) {
            if (xifimage) {
                XIFImage *resizeMOImage = [xifimage reiszeImage:targetResizeMode
                                                       withSize:targetSize
                                                       withType:type
                                                 withProperties:properties];
                if (resizeMOImage) {
                    block(resizeMOImage);
                    return ;
                }
            }
            block(nil);
        }];
    }
    
    [operationDict setObject:operation forKey:uuid];
    [operation startOnDelegateQueue:downloadQueue];
}

@end




int main(int argc, const char *argv[])
{
    NSXPCListener *listener = [NSXPCListener serviceListener];
    XIFImageFetcherService *service = [XIFImageFetcherService new];
    listener.delegate = service;
    [listener resume];
    return 0;
}
