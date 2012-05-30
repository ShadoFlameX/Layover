//
//  NSFileManager+LayoverExtensions.m
//  Layover
//
//  Created by Bryan Hansen on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSFileManager+LayoverExtensions.h"

#define ImagesFolderName @"Images"

@implementation NSFileManager (LayoverExtensions)

- (NSURL *)URLForImagesDirectory
{
    NSURL *imagesFolderURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    imagesFolderURL = [imagesFolderURL URLByAppendingPathComponent:ImagesFolderName];
    
    NSError *checkError = nil;
    if (![imagesFolderURL checkResourceIsReachableAndReturnError:&checkError]) {
        NSError *createError = nil;
        [[NSFileManager defaultManager] createDirectoryAtURL:imagesFolderURL withIntermediateDirectories:NO attributes:nil error:&createError];
        if (createError) {
            NSLog(@"%@",checkError);
            return nil;
        }
    }

    return imagesFolderURL;
}

@end
