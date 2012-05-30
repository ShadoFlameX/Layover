//
//  LOVPhoto.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVPhoto.h"

@implementation LOVPhoto

#pragma mark - Properties

@synthesize image = m_image;
@synthesize screenPreview = m_screenPreview;
@synthesize blendMode = m_blendMode;
@synthesize alpha = m_alpha;

- (CIImage *)screenPreview
{
    if (!m_screenPreview) {
        CGFloat screenScale = 1.0f;//[UIScreen mainScreen].scale;
        
        NSLog(@"extend width: %f",self.image.extent.size.width);
        
        CGFloat scaleFactorX = [UIScreen mainScreen].bounds.size.width * screenScale / self.image.extent.size.width;
        CGFloat scaleFactorY = [UIScreen mainScreen].bounds.size.height * screenScale / self.image.extent.size.height;
        CGFloat imageScaleFactor = MIN(scaleFactorX, scaleFactorY);
        imageScaleFactor = MIN(imageScaleFactor, 1.0f);
        
        m_screenPreview = [self.image imageByApplyingTransform:CGAffineTransformMakeScale(imageScaleFactor, imageScaleFactor)];
    }
    
    return m_screenPreview;
}

#pragma mark - Lifecycle

+ (LOVPhoto *)photoWithImage:(CIImage *)image
{
    return [self photoWithImage:image blendMode:kCGBlendModeNormal alpha:1.0f];
}

+ (LOVPhoto *)photoWithImage:(CIImage *)image blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    LOVPhoto *photo = [[LOVPhoto alloc] init];
    photo.image = image;
    photo.blendMode = blendMode;
    photo.alpha = alpha;
    
    return photo;
}

@end
