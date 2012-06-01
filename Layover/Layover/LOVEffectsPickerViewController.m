//
//  LOVEffectsPickerViewController.m
//  Layover
//
//  Created by Bryan Hansen on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVEffectsPickerViewController.h"

@interface LOVEffectsPickerViewController ()

@property (nonatomic,strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) NSArray *effects;
@property (nonatomic,strong) NSMutableArray *imageViews;

- (void)setup;
- (void)reloadContent;

@end

@implementation LOVEffectsPickerViewController

#pragma mark - Properties

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

- (void)setup
{
    self.effects = [NSArray arrayWithObjects:@"Normal", @"Multiply", @"Darken", @"Screen", @"Overlay", @"Darken", @"Lighten", @"Color Dodge", @"Color Burn", @"Soft Light", @"Hard Light", @"Difference", @"Exclusion", @"Hue", @"Saturation", @"Color", @"Luminosity", nil];
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
    
    CGRect containerRect;
    __block CGRect leftRect, rightRect;
    
    containerRect = CGRectInset(self.view.bounds, 10.0f, 10.0f);
    containerRect.size.height = 144.0f;
    
    CGRectDivide(containerRect, &leftRect, &rightRect, floorf(containerRect.size.width/2.0f), CGRectMinXEdge);
    leftRect.size.width -= 6.0f;
    rightRect.origin.x += 6.0f;
    rightRect.size.width -= 6.0f;
    
    [self.effects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect rect = (idx % 2 == 0) ? leftRect : rightRect;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
        imageView.backgroundColor = [UIColor colorWithWhite:arc4random()%75 / 100.0f + 0.25f alpha:1.0f];
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
