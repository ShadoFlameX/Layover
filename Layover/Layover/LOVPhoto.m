//
//  LOVPhoto.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVPhoto.h"
#import "UIImage+Resize.h"

@interface LOVPhoto ()

@property (nonatomic,strong,readwrite) UIImage *previewImage;

@end

@implementation LOVPhoto

#pragma mark - Properties

@synthesize image = m_image;
@synthesize previewImage = m_previewImage;
@synthesize transform = m_transform;
@synthesize blendMode = m_blendMode;
@synthesize alpha = m_alpha;

- (UIImage *)previewImage
{
    if (!m_previewImage) {
        CGFloat screenScale = [UIScreen mainScreen].scale;
        
        CGSize pixelSize = CGSizeApplyAffineTransform(self.image.size, CGAffineTransformMakeScale(self.image.scale, self.image.scale));
        
        CGFloat maxScreenDimension = MAX([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
        maxScreenDimension *= screenScale;
                
        CGFloat scaleFactorX = maxScreenDimension / pixelSize.width;
        CGFloat scaleFactorY = maxScreenDimension / pixelSize.height;
        CGFloat imageScaleFactor = MIN(scaleFactorX, scaleFactorY);
        imageScaleFactor = MIN(imageScaleFactor, 1.0f);
        
        CGSize newSize = CGSizeApplyAffineTransform(pixelSize, CGAffineTransformMakeScale(imageScaleFactor, imageScaleFactor));
        
        m_previewImage = [self.image resizedImage:newSize interpolationQuality:kCGInterpolationMedium];
    }
    
    return m_previewImage;
}

#pragma mark - Lifecycle

+ (LOVPhoto *)photoWithImage:(UIImage *)image
{
    return [self photoWithImage:image blendMode:kCGBlendModeNormal alpha:1.0f];
}

+ (LOVPhoto *)photoWithImage:(UIImage *)image blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    LOVPhoto *photo = [[self alloc] init];
    photo.image = image;
    photo.blendMode = blendMode;
    photo.alpha = alpha;
    photo.transform = CGAffineTransformIdentity;
    
    return photo;
}

- (id)copyWithZone:(NSZone *)zone
{
    LOVPhoto *photo = [[LOVPhoto alloc] init];
    
    photo.image = self.image;
    photo.previewImage = self.previewImage;
    photo.blendMode = self.blendMode;
    photo.alpha = self.alpha;
    photo.transform = self.transform;
    
    return photo;
}

#pragma mark - Logging

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, image: %@, blendMode: %d, alpha: %f",[super description], self.image, self.blendMode, self.alpha]; 
}


@end
