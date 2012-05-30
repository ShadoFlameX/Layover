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

@interface LOVCollageViewController () {
    dispatch_queue_t backgroundQueue;
}

@property (nonatomic,strong,readonly) UIImagePickerController *imagePicker;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;

- (void)addCollageImage:(UIImage *)image;

@end

@implementation LOVCollageViewController

#pragma mark - Properties

@synthesize collageView = m_collageView;
@synthesize imagePicker = m_imagePicker;
@synthesize loadingView = m_loadingView;

- (UIImagePickerController *)imagePicker
{
    if (!m_imagePicker) {
        m_imagePicker = [[UIImagePickerController alloc] init];
        m_imagePicker.delegate = self;
    }
    
    return m_imagePicker;
}

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        backgroundQueue = dispatch_queue_create("com.skeuo.backgroundqueue", DISPATCH_QUEUE_CONCURRENT);        
    }
    return self;
}

- (void)dealloc
{
    m_imagePicker.delegate = nil;
    
    dispatch_release(backgroundQueue);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height/2.0f);
    self.loadingView.frame = CGRectIntegral(self.loadingView.frame);
    self.loadingView.hidesWhenStopped = YES;
    [self.view addSubview:self.loadingView];
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

- (void)addCollageImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    
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
    
    BOOL success = [imageData writeToURL:fileURL atomically:YES];
    
    if (!success) {
        NSLog(@"Failed writing image to URL: %@",fileURL);
        return;
    }
    
    LOVPhoto *photo = [LOVPhoto photoWithImage:[CIImage imageWithContentsOfURL:fileURL]];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        [self.collageView addPhoto:photo];
        [self.loadingView stopAnimating];
    });

}

#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    if (!image) {
        NSAssert(image, @"Error, UIImagePickerController returned no image.");
        return;
    }
    
    [self.loadingView startAnimating];
    
    dispatch_async(backgroundQueue, ^() {
        [self addCollageImage:image];
    });
}

@end
