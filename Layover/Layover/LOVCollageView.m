//
//  LOVCollageView.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVCollageView.h"
#import "LOVPhoto.h"

static const CGFloat PanGesturePadding = 24.0f;

@interface LOVCollageView ()

@property (nonatomic,strong) NSMutableArray *photos;
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) CIImage *outputImage;
@property (nonatomic,strong) CIContext *context;
@property (nonatomic,strong) CIFilter *filter;
@property (nonatomic,strong) CIFilter *matrixFilter;

- (void)setup;
- (void)updateFilters;
- (void)logCoreImage;

@end

@implementation LOVCollageView

@synthesize photos = m_photos;
@synthesize panGesture = m_panGesture;
@synthesize imageView = m_imageView;
@synthesize outputImage = m_outputImage;
@synthesize context = m_context;
@synthesize filter = m_filter;
@synthesize matrixFilter = m_matrixFilter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.photos = [NSMutableArray array];
    
    NSDictionary *contextInfo = nil;//[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], kCIContextUseSoftwareRenderer, nil]; 
    self.context = [CIContext contextWithOptions:contextInfo];
    
    self.matrixFilter = [CIFilter filterWithName:@"CIColorMatrix"];
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.panGesture];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:self.imageView];
    
//    [self logCoreImage];
}

- (void)addPhoto:(LOVPhoto *)photo;
{
    if (self.photos.count == 2) {
        [self.photos removeObjectAtIndex:0];
    }
    [self.photos addObject:photo];
    
    [self updateFilters];
}

- (void)updateFilters
{
    if (self.photos.count < 2)
        return;
    
    if (!self.filter) {
        self.filter = [CIFilter filterWithName:@"CIScreenBlendMode"];
    }
    
    [self.matrixFilter setValue:((LOVPhoto *)[self.photos objectAtIndex:1]).screenPreview forKey:kCIInputImageKey];
    [self.matrixFilter setValue:[CIVector vectorWithX:0 Y:0 Z:0 W:((LOVPhoto *)[self.photos objectAtIndex:1]).alpha] forKey:@"inputAVector"];
            
    [self.filter setValue:((LOVPhoto *)[self.photos objectAtIndex:0]).screenPreview forKey:kCIInputBackgroundImageKey];
    [self.filter setValue:[self.matrixFilter outputImage] forKey:kCIInputImageKey];
    
    self.outputImage = [self.filter outputImage];
    
    CGImageRef cgimg = [self.context createCGImage:self.outputImage fromRect:[self.outputImage extent]];
    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
    
    self.imageView.image = newImg;
    
    CGImageRelease(cgimg);    
}

#pragma mark - Actions

- (void)handlePan:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.photos.count > 1) {
        CGFloat posX = [self.panGesture locationInView:self].x;
        posX -= PanGesturePadding;
        
        CGFloat newAlpha = posX/(self.frame.size.width - PanGesturePadding*2);
        
        newAlpha = MAX(0.0f, newAlpha);
        newAlpha = MIN(1.0f, newAlpha);

        LOVPhoto *photo = [self.photos objectAtIndex:1];
        photo.alpha = newAlpha;
                
        [self updateFilters];
    }
}

#pragma mark -

- (void)logCoreImage
{
    for (NSString *name in [CIFilter filterNamesInCategory:kCICategoryBuiltIn]) {
        NSLog(@"%@ -------------------------------------------------------------",name);
        CIFilter *filter = [CIFilter filterWithName:name];
        
//        NSLog(@"%@",[filter attributes]);
        NSLog(@"%@",[filter inputKeys]);

    }
}


@end
