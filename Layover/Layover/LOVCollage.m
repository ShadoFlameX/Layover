//
//  LOVCollage.m
//  Layover
//
//  Created by Bryan Hansen on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVCollage.h"
#import "LOVPhoto.h"
#import "CGGeometry+LayoverExtensions.h"

@interface LOVCollage ()

@property (nonatomic,strong) NSMutableArray *mutablePhotos;
@property (nonatomic,strong,readwrite) UIImage *previewImage;

@end

@implementation LOVCollage

#pragma mark - Properties

@synthesize mutablePhotos = m_mutablePhotos;
@synthesize previewImage = m_previewImage;

- (NSArray *)photos
{
    return [NSArray arrayWithArray:self.mutablePhotos];
}

- (UIImage *)previewImage
{
    return [self previewImage:NO];
}

- (UIImage *)outputImage
{
    if (self.photos.count == 0)
        return nil;
    
    LOVPhoto *firstPhoto = [self.photos objectAtIndex:0];
    
    CGSize size = CGSizeMake(CGImageGetWidth(firstPhoto.image.CGImage), CGImageGetHeight(firstPhoto.image.CGImage));
    
    return [self outputImageForSize:size];
}

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.mutablePhotos = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Image Processing

- (UIImage *)previewImage:(BOOL)forceUpdate
{
    if (self.photos.count == 0)
        return nil;
    
    if (!forceUpdate && m_previewImage)
    {
        return m_previewImage;
    }
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    size.width *= [UIScreen mainScreen].scale;
    size.height *= [UIScreen mainScreen].scale;
    
    m_previewImage = [self outputImageForSize:size];
    
    return m_previewImage;
}

- (UIImage *)outputImageForSize:(CGSize)size
{
    CGRect contextRect = CGRectWithSize(size);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * contextRect.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(NULL, contextRect.size.width, contextRect.size.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    [self.photos enumerateObjectsUsingBlock:^(LOVPhoto *photo, NSUInteger idx, BOOL *stop) {
        
//        CGContextSetRGBFillColor(context, 0.5f, 0.0f, 0.0f, 1.0f);
//        CGContextFillRect(context, contextRect);
        
        CGImageRef imageRef = photo.previewImage.CGImage;
        CGRect photoRect = CGRectMake(0, 0, CGImageGetWidth(photo.previewImage.CGImage), CGImageGetHeight(photo.previewImage.CGImage));
        CGContextSetAlpha(context, photo.alpha);
        
        CGContextSetBlendMode(context, photo.blendMode);
        
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, contextRect.size.width/2, contextRect.size.height/2);
        CGContextConcatCTM(context, photo.transform);
        CGContextTranslateCTM(context, -contextRect.size.width/2, -contextRect.size.height/2);

        CGContextDrawImage(context, CGRectCenterRectInRect(photoRect, contextRect), imageRef);
        
        CGContextRestoreGState(context);
    }];
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
    CGContextRelease(context);
    CGImageRelease(newImageRef);
    
    return newImage;
}

#pragma mark - Actions

- (void)addPhoto:(LOVPhoto *)photo
{
    if (self.mutablePhotos.count > 0) {
        photo.blendMode = kCGBlendModeScreen;
        photo.alpha = 0.5f;
    }
    
    if (self.mutablePhotos.count == 2) {
        [self.mutablePhotos removeObjectAtIndex:0];
    }
    
    [self.mutablePhotos addObject:photo];
    
    self.previewImage = nil;
}

- (void)removeAllPhotos
{
    [self.mutablePhotos removeAllObjects];
    self.previewImage = nil;
}

@end
