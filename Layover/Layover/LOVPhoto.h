//
//  LOVPhoto.h
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreImage/CoreImage.h>

@interface LOVPhoto : NSObject <NSCopying>

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong,readonly) UIImage *previewImage;
@property (nonatomic,assign) CGAffineTransform transform;
@property (nonatomic,assign) CGBlendMode blendMode;
@property (nonatomic,assign) CGFloat alpha;

+ (LOVPhoto *)photoWithImage:(UIImage *)image;
+ (LOVPhoto *)photoWithImage:(UIImage *)image blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

@end
