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
    if (self.photos.count == 0)
        return nil;
    
    if (!m_previewImage) {
        m_previewImage = [self outputImageForSize:[UIScreen mainScreen].bounds.size];
    }
    
    return m_previewImage;
}

- (UIImage *)fullsizeImage
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

- (void)dealloc
{
    // this will de-register all observers
    [self removeAllPhotos];
}

#pragma mark - Image Processing

- (UIImage *)outputImageForSize:(CGSize)size
{
    CGRect contextRect = CGRectMake(0, 0, MIN(size.width, size.height), MIN(size.width, size.height));
    contextRect.size.width *= [UIScreen mainScreen].scale;
    contextRect.size.height *= [UIScreen mainScreen].scale;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * contextRect.size.width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(NULL, contextRect.size.width, contextRect.size.height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    __block CGFloat photoScale = 1.0f;
    
    [self.photos enumerateObjectsUsingBlock:^(LOVPhoto *photo, NSUInteger idx, BOOL *stop) {
        
//        CGContextSetRGBFillColor(context, 0.5f, 0.0f, 0.0f, 1.0f);
//        CGContextFillRect(context, contextRect);
        
        if (idx == 0) {
            CGFloat minDimension = MIN(CGImageGetWidth(photo.previewImage.CGImage), CGImageGetHeight(photo.previewImage.CGImage));
            photoScale = contextRect.size.width / minDimension;
        }
        
        CGImageRef imageRef = photo.previewImage.CGImage;
        CGRect photoRect = CGRectMake(0, 0, CGImageGetWidth(photo.previewImage.CGImage) * photoScale, CGImageGetHeight(photo.previewImage.CGImage) * photoScale);
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
    self.previewImage = nil;
    
    if (self.mutablePhotos.count == 2) {
        [self.mutablePhotos removeObjectAtIndex:0];
    }
    
    [self.mutablePhotos addObject:photo];
    
    [photo addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
    [photo addObserver:self forKeyPath:@"transform" options:NSKeyValueObservingOptionNew context:NULL];
    [photo addObserver:self forKeyPath:@"blendMode" options:NSKeyValueObservingOptionNew context:NULL];
    [photo addObserver:self forKeyPath:@"alpha" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeAllPhotos
{
    self.previewImage = nil;
    
    [self.mutablePhotos enumerateObjectsUsingBlock:^(LOVPhoto *photo, NSUInteger idx, BOOL *stop) {
        [photo removeObserver:self forKeyPath:@"image"];
        [photo removeObserver:self forKeyPath:@"transform"];
        [photo removeObserver:self forKeyPath:@"blendMode"];
        [photo removeObserver:self forKeyPath:@"alpha"];
    }];
    
    [self.mutablePhotos removeAllObjects];
}

#pragma mark - Key Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isKindOfClass:[LOVPhoto class]]) {
        self.previewImage = nil;
    }
}

@end
