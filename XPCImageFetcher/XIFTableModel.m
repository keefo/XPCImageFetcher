//
//  XIFTableModel.m
//  XPCImageFetcher
//
//  Created by liam on 2014-08-04.
//  Copyright (c) 2014 Beyondcow. All rights reserved.
//

#import "XIFTableModel.h"
#import "NSString+UUID.h"

@implementation XIFTableModel

+ (XIFTableModel*)newModel:(NSString*)url;
{
    XIFTableModel *model=[[XIFTableModel alloc] init];
    model.url = [NSURL URLWithString:url];
    return model;
}

- (id)initWithFileURL:(NSURL *)u
{
    self = [super init];
    self.url = u;
    return self;
}

- (id)init
{
    if (self=[super init]) {
        self.uuid = [NSString stringWithNewUUID];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    XIFTableModel *result = [[[self class] alloc] initWithFileURL:self.url];
    result.image = self.image;
    result.url = self.url;
    result.uuid = self.uuid;
    result.thumbnailUrl = self.thumbnailUrl;
    result.photoid = self.photoid;
    result.title = self.title;
    return result;
}


@end
