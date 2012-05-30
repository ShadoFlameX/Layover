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
#import "NSFileManager+LayoverExtensions.h"

static const NSUInteger FileNotFoundErrorCode = 2;

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

- (void)dealloc
{
    m_imagePicker.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    [picker dismissModalViewControllerAnimated:YES];
    
    NSData *imgData = UIImagePNGRepresentation([info objectForKey:@"UIImagePickerControllerOriginalImage"]);
    
    if (!imgData) {
        NSAssert(imgData, @"Error, UIImagePickerController returned no image data.");
        return;
    }

    NSURL *fileURL = nil;
    NSUInteger i = 0;
    NSError *error = nil;
    do {
        fileURL = [[[NSFileManager defaultManager] URLForImagesDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"image-%d.png",i]];
        i++;
    } while ([fileURL checkResourceIsReachableAndReturnError:&error]);
        
    if (error && [((NSError *)[[error userInfo] objectForKey:NSUnderlyingErrorKey]) code] != FileNotFoundErrorCode) {
        NSLog(@"%@",error);
        return;
    }
    
    BOOL success = [imgData writeToURL:fileURL atomically:YES];
    
    if (!success) {
        NSLog(@"Failed writing image to URL: %@",fileURL);
        return;
    }
        
    LOVPhoto *photo = [LOVPhoto photoWithImage:[CIImage imageWithContentsOfURL:fileURL]];
    
    [self.collageView addPhoto:photo];
}

@end
