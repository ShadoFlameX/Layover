//
//  LOVCollage.h
//  Layover
//
//  Created by Bryan Hansen on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LOVPhoto;

typedef void (^LOVCollageRenderCompletionBlock)(UIImage *image);

@interface LOVCollage : NSObject

@property (nonatomic,readonly) NSArray *photos;
@property (nonatomic,strong,readonly) UIImage *previewImage;
@property (nonatomic,readonly) UIImage *fullsizeImage;

- (void)addPhoto:(LOVPhoto *)photo;
- (void)removeAllPhotos;

- (UIImage *)outputImageForSize:(CGSize)size;
- (void)renderPreview:(LOVCollageRenderCompletionBlock)completionBlock;
- (void)renderOutputImageForSize:(CGSize)size completion:(LOVCollageRenderCompletionBlock)completionBlock;

@end
