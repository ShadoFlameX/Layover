//
//  LOVPhoto.h
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface LOVPhoto : NSObject

@property (nonatomic,strong) CIImage *image;
@property (nonatomic,assign) CGBlendMode blendMode;
@property (nonatomic,assign) CGFloat alpha;

+ (LOVPhoto *)photoWithImage:(CIImage *)image;
+ (LOVPhoto *)photoWithImage:(CIImage *)image blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

@end
