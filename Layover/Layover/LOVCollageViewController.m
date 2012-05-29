//
//  LOVViewController.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVCollageViewController.h"
#import "LOVCollageView.h"
#import "LOVPhoto.h"

@interface LOVCollageViewController ()

@end

@implementation LOVCollageViewController

#pragma mark - Properties

@synthesize collageView = m_collageView;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LOVPhoto *photo1 = [LOVPhoto photoWithImage:[UIImage imageNamed:@"photo1.jpg"]];
    LOVPhoto *photo2 = [LOVPhoto photoWithImage:[UIImage imageNamed:@"photo2.jpg"] blendMode:kCGBlendModeScreen alpha:0.5f];
    
    [self.collageView addPhoto:photo1];
    [self.collageView addPhoto:photo2];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
