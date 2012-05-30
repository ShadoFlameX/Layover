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

@property (nonatomic,strong,readonly) UIImagePickerController *imagePicker;

@end

@implementation LOVCollageViewController

#pragma mark - Properties

@synthesize collageView = m_collageView;
@synthesize imagePicker = m_imagePicker;

- (UIImagePickerController *)imagePicker
{
    if (!m_imagePicker) {
        m_imagePicker = [[UIImagePickerController alloc] init];
        m_imagePicker.delegate = self;
    }
    
    return m_imagePicker;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"photo1" ofType:@"png"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    LOVPhoto *photo1 = [LOVPhoto photoWithImage:[CIImage imageWithContentsOfURL:fileURL]];
    
    filePath = [[NSBundle mainBundle] pathForResource:@"photo2" ofType:@"png"];
    fileURL = [NSURL fileURLWithPath:filePath];

    LOVPhoto *photo2 = [LOVPhoto photoWithImage:[CIImage imageWithContentsOfURL:fileURL] blendMode:kCGBlendModeScreen alpha:0.5f];
    
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

#pragma mark - Actions

- (IBAction)showCamera:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Camera Not Available", @"error title") message:NSLocalizedString(@"Your device does not have a camera available for use.", @"error message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    [self presentModalViewController:self.imagePicker animated:YES];
}

- (IBAction)showPhotoPicker:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSLog(@"Error! Photo Library not available!");
        return;
    }
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentModalViewController:self.imagePicker animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"%@",[info objectForKey:@"UIImagePickerControllerOriginalImage"]);
    [picker dismissModalViewControllerAnimated:YES];
}



@end
