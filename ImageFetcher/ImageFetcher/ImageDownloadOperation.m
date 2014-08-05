//
//  ImageDownloadOperation.m
//  ImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import "ImageDownloadOperation.h"

@interface ImageDownloadOperation()
{
    NSURLConnection *_ido_connection;
    NSError *_ido_error;
    NSMutableData *_ido_data;
    NSInteger _ido_statusCode;
    NSInteger _ido_flag;
}

@end


@implementation ImageDownloadOperation

- (id)initWithURL:(NSURL*)url andUUID:(NSString*)uuid cachePolicy:(NSURLRequestCachePolicy)policy callBack:(void(^)(XIFImage *img))block;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    self.url = url;
    self.uuid = uuid;
    self.policy = policy;
    self.callback = block;
    _ido_flag = 0;
    
    return self;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _ido_flag==1;
}

- (BOOL)isFinished
{
    return _ido_flag==2;
}

- (void)cancel
{
    _ido_flag = 5;
    [_ido_connection cancel];
}

- (void)startOnDelegateQueue:(NSOperationQueue*)queue
{
    [self willChangeValueForKey:@"isExecuting"];
    _ido_flag = 1;
    [self didChangeValueForKey:@"isExecuting"];
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:self.url];
    [request setCachePolicy:self.policy];
    [request setTimeoutInterval:30];
    
    _ido_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    if (_ido_connection == nil){
        [self finish];
    }
    [_ido_connection setDelegateQueue:queue];
    [_ido_connection start];
}


- (void)finish
{
    
    BOOL canceled = NO;
    if(_ido_flag==5){
        canceled = YES;
    }
    
    _ido_connection = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _ido_flag = 2;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    if (canceled) {
        return;
    }
    
    if (_ido_data) {
        NSImage *image = nil;
        @try {
            image = [[NSImage alloc] initWithData:_ido_data];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        if (image) {
            XIFImage *xifimage=[[XIFImage alloc] initWithData:_ido_data];
            xifimage.url=self.url;
            xifimage.uuid=self.uuid;
            self.callback(xifimage);
            return;
        }
    }
    
    self.callback(nil);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _ido_data = [[NSMutableData alloc] init];
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    _ido_statusCode = [httpResponse statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_ido_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self finish];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _ido_error = [error copy];
    [self finish];
}

@end