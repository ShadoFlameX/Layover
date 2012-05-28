//
//  LOVPhoto.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVPhoto.h"

@implementation LOVPhoto

@synthesize image = m_image;
@synthesize blendMode = m_blendMode;
@synthesize alpha = m_alpha;

+ (LOVPhoto *)photoWithImage:(UIImage *)image
{
    return [self photoWithImage:image blendMode:kCGBlendModeNormal alpha:1.0f];
}

+ (LOVPhoto *)photoWithImage:(UIImage *)image blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
    LOVPhoto *photo = [[LOVPhoto alloc] init];
    photo.image = image;
    photo.blendMode = blendMode;
    photo.alpha = alpha;
    
    return photo;
}

@end
