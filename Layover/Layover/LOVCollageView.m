//
//  LOVCollageView.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVCollageView.h"
#import "LOVPhoto.h"

@interface LOVCollageView ()

@property (nonatomic,strong) NSMutableArray *photos;
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) CIFilter *filter;

- (void)setup;
- (void)updateFilters;

@end

@implementation LOVCollageView

@synthesize photos = m_photos;
@synthesize panGesture = m_panGesture;
@synthesize imageView = m_imageView;
@synthesize filter;

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
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.panGesture];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self addSubview:self.imageView];
}

- (void)addPhoto:(LOVPhoto *)photo;
{
    [self.photos addObject:photo];
    
    [self updateFilters];
}

- (void)updateFilters
{
    if (self.photos.count < 2)
        return;
        
//    CIContext *context = [CIContext contextWithOptions:nil];
//    
////    NSLog(@"%@",[CIFilter filterNamesInCategory:kCICategoryBuiltIn]);
//    
//    if (!self.filter) {
//        self.filter = [CIFilter filterWithName:@"CIColorBurnBlendMode"];
//    }
//    
////    NSLog(@"%@",[self.filter attributes]);
////    NSLog(@"%@",[self.filter inputKeys]);
//    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"photo1" ofType:@"png"];
//    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
//    CIImage *img1 = [CIImage imageWithContentsOfURL:fileURL];
//
//    filePath = [[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"png"];
//    fileURL = [NSURL fileURLWithPath:filePath];
//    CIImage *img2 = [CIImage imageWithContentsOfURL:fileURL];
//    
//    [self.filter setValue:img1 forKey:@"inputBackgroundImage"];
//    [self.filter setValue:img2 forKey:@"inputImage"];
////    NSNumber *alphaNum = [NSNumber numberWithFloat:((LOVPhoto *)[self.photos objectAtIndex:1]).alpha]; 
//    
//    CIImage *outputImage = [self.filter outputImage];
//    
//    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
//    UIImage *newImg = [UIImage imageWithCGImage:cgimg];
//    
//    self.imageView.image = newImg;
//    
//    CGImageRelease(cgimg);
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.photos.count == 0)
        return;
    
    [self.photos enumerateObjectsUsingBlock:^(LOVPhoto *photo, NSUInteger idx, BOOL *stop) {
        [photo.image drawInRect:rect blendMode:photo.blendMode alpha:photo.alpha];
    }];
}

#pragma mark - Actions

- (void)handlePan:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.photos.count > 1) {
                
        CGFloat newAlpha = [self.panGesture locationInView:self].x/self.frame.size.width;
        
        LOVPhoto *photo = [self.photos objectAtIndex:1];
        photo.alpha = newAlpha;
        
        [self updateFilters];
    }
}

@end
