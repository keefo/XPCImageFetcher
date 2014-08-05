//
//  NSString+MD5.m
//  iYY
//
//  Created by xu lian on 12-02-09.
//  Copyright (c) 2012 Beyondcow. All rights reserved.
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString*)stringWithNewUUID
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *newUUID = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
#if  __has_feature(objc_arc)
    return newUUID;
#else
    return [newUUID autorelease];
#endif
}

@end
