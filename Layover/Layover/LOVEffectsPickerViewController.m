//
//  LOVEffectsPickerViewController.m
//  Layover
//
//  Created by Bryan Hansen on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVEffectsPickerViewController.h"
#import "LOVPhoto.h"
#import "LOVCollage.h"

@interface LOVEffectsPickerViewController () {
    dispatch_queue_t backgroundQueue;
}

@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) NSArray *effects;
@property (nonatomic,strong) NSMutableArray *imageViews;

- (void)setup;
- (void)reloadContent;

@end

@implementation LOVEffectsPickerViewController

#pragma mark - Properties

@synthesize collage = m_collage;
@synthesize scrollView = m_scrollView;
@synthesize effects = m_effects;
@synthesize imageViews = m_imageViews;

- (void)setEffects:(NSArray *)effects
{
    if (m_effects == effects)
        return;
    
    m_effects = effects;
    
    [self reloadContent];
}

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    dispatch_release(backgroundQueue);
}

- (void)setup
{
    backgroundQueue = dispatch_queue_create("com.skeuo.LOVEffectsPickerViewController.backgroundqueue", DISPATCH_QUEUE_SERIAL);        

    self.effects = [NSArray arrayWithObjects:
        [NSNumber numberWithInt:kCGBlendModeNormal],
        [NSNumber numberWithInt:kCGBlendModeMultiply],
        [NSNumber numberWithInt:kCGBlendModeScreen],
        [NSNumber numberWithInt:kCGBlendModeOverlay],
        [NSNumber numberWithInt:kCGBlendModeDarken],
        [NSNumber numberWithInt:kCGBlendModeLighten],
        [NSNumber numberWithInt:kCGBlendModeColorDodge],
        [NSNumber numberWithInt:kCGBlendModeColorBurn],
        [NSNumber numberWithInt:kCGBlendModeSoftLight],
        [NSNumber numberWithInt:kCGBlendModeHardLight],
        [NSNumber numberWithInt:kCGBlendModeDifference],
        [NSNumber numberWithInt:kCGBlendModeExclusion],
        [NSNumber numberWithInt:kCGBlendModeHue],
        [NSNumber numberWithInt:kCGBlendModeSaturation],
        [NSNumber numberWithInt:kCGBlendModeColor],
        [NSNumber numberWithInt:kCGBlendModeLuminosity],
        nil];
    
    self.imageViews = [NSMutableArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self reloadContent];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)reloadContent
{
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
        [imageView removeFromSuperview];
    }];
    [self.imageViews removeAllObjects];
    
    if (!self.collage.photos.count)
        return;
    
    CGRect containerRect;
    __block CGRect leftRect, rightRect;
    
    containerRect = CGRectInset(self.view.bounds, 10.0f, 10.0f);
    containerRect.size.height = 144.0f;
    
    CGRectDivide(containerRect, &leftRect, &rightRect, floorf(containerRect.size.width/2.0f), CGRectMinXEdge);
    leftRect.size.width -= 6.0f;
    rightRect.origin.x += 6.0f;
    rightRect.size.width -= 6.0f;
    
    [self.effects enumerateObjectsUsingBlock:^(NSNumber *blendNum, NSUInteger idx, BOOL *stop) {
        CGRect rect = (idx % 2 == 0) ? leftRect : rightRect;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        
        LOVCollage *previewCollage = [[LOVCollage alloc] init];
        for (LOVPhoto *photo in self.collage.photos) {
            [previewCollage addPhoto:[photo copy]];
        }
        
        LOVPhoto *topPhoto = [previewCollage.photos objectAtIndex:previewCollage.photos.count - 1];
        topPhoto.blendMode = [blendNum intValue];
        
        dispatch_async(backgroundQueue, ^() {
            UIImage *image = [previewCollage outputImageForSize:rect.size];
            dispatch_async(dispatch_get_main_queue(), ^() {
                imageView.image = image;
            });
        });
        
        [self.scrollView addSubview:imageView];
        [self.imageViews addObject:imageView];
        
        if (idx % 2 == 0) leftRect.origin.y += leftRect.size.height + 12.0f;
        else rightRect.origin.y += rightRect.size.height + 12.0f;
    }];
    
    NSUInteger rows = ceilf((CGFloat)self.effects.count / 2.0f);
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 20.0f + rows * leftRect.size.height + (rows - 1) * 12.0f);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (void)close:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
