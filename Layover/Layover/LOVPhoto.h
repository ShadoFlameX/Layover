//
//  LOVPhoto.h
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LOVPhoto : NSObject

@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) CGBlendMode blendMode;
@property (nonatomic,assign) CGFloat alpha;

+ (LOVPhoto *)photoWithImage:(UIImage *)image;
+ (LOVPhoto *)photoWithImage:(UIImage *)image blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

@end
