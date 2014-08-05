//
//  XIFTableModel.h
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIFImage.h"

@interface XIFTableModel : NSObject
@property(retain) XIFImage *image;
@property(retain) NSString *uuid;
@property (copy) NSURL *url;
@property (copy) NSURL *thumbnailUrl;
@property (copy) NSString *photoid;
@property (copy) NSString *title;


+ (XIFTableModel*)newModel:(NSString*)url;

@end
