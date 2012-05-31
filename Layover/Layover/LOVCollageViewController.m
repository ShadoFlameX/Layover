//
//  LOVViewController.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVCollageViewController.h"
#import "LOVPhoto.h"
#import "LOVCollage.h"
#import "NSFileManager+LayoverExtensions.h"

static const NSUInteger FileNotFoundErrorCode = 2;
static const CGFloat PanGesturePadding = 24.0f;


@interface LOVCollageViewController () {
    dispatch_queue_t backgroundQueue;
}

@property (nonatomic,strong) LOVCollage *collage;
@property (nonatomic,strong) IBOutlet UIImageView *imageView;
@property (nonatomic,strong,readonly) UIImagePickerController *imagePicker;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;

- (void)addImage:(UIImage *)image;

@end

@implementation LOVCollageViewController

#pragma mark - Properties

@synthesize collage = m_collage;
@synthesize imageView = m_imageView;
@synthesize imagePicker = m_imagePicker;
@synthesize loadingView = m_loadingView;
@synthesize panGesture = m_panGesture;

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
    
    self.collage = [[LOVCollage alloc] init];
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height/2.0f);
    self.loadingView.frame = CGRectIntegral(self.loadingView.frame);
    self.loadingView.hidesWhenStopped = YES;
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:self.panGesture];
    
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

- (IBAction)showEffects:(id)sender
{
    if (self.collage.photos.count < 2)
        return;
    
    UIActionSheet *effectsSheet = [[UIActionSheet alloc] initWithTitle:@"Effects" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Normal", @"Multiply", @"Darken", @"Screen", @"Overlay", @"Darken", @"Lighten", @"Color Dodge", @"Color Burn", @"Soft Light", @"Hard Light", @"Difference", @"Exclusion", @"Hue", @"Saturation", @"Color", @"Luminosity", nil];
    
    [effectsSheet showInView:self.view];
}

- (void)addImage:(UIImage *)image
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
    
    LOVPhoto *photo = [LOVPhoto photoWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:fileURL]]];
    [self.collage addPhoto:photo];
    [self.collage previewImage:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.imageView.image = self.collage.previewImage;
        [self.loadingView stopAnimating];
    });
}

- (void)handlePan:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.collage.photos.count > 1) {
        CGFloat posX = [self.panGesture locationInView:self.view].x;
        posX -= PanGesturePadding;
        
        CGFloat newAlpha = posX/(self.view.frame.size.width - PanGesturePadding*2);
        
        newAlpha = MAX(0.0f, newAlpha);
        newAlpha = MIN(1.0f, newAlpha);
        
        LOVPhoto *photo = [self.collage.photos objectAtIndex:1];
        photo.alpha = newAlpha;
        
        dispatch_async(backgroundQueue, ^() {
            [self.collage previewImage:YES];
            dispatch_async(dispatch_get_main_queue(), ^() {
                self.imageView.image = self.collage.previewImage;
            });
        });
    }
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
        [self addImage:image];
    });
}

#pragma mark - UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    CGBlendMode blendMode = kCGBlendModeNormal;
    
    switch (buttonIndex) {
        case 1:
            blendMode = kCGBlendModeMultiply;
            break;
        case 2:
            blendMode = kCGBlendModeDarken;
            break;
        case 3:
            blendMode = kCGBlendModeScreen;
            break;
        case 4:
            blendMode = kCGBlendModeOverlay;
            break;
        case 5:
            blendMode = kCGBlendModeDarken;
            break;
        case 6:
            blendMode = kCGBlendModeLighten;
            break;
        case 7:
            blendMode = kCGBlendModeColorDodge;
            break;
        case 8:
            blendMode = kCGBlendModeColorBurn;
            break;
        case 9:
            blendMode = kCGBlendModeSoftLight;
            break;
        case 10:
            blendMode = kCGBlendModeHardLight;
            break;
        case 11:
            blendMode = kCGBlendModeDifference;
            break;
        case 12:
            blendMode = kCGBlendModeExclusion;
            break;
        case 13:
            blendMode = kCGBlendModeHue;
            break;
        case 14:
            blendMode = kCGBlendModeSaturation;
            break;
        case 15:
            blendMode = kCGBlendModeColor;
            break;
        case 16:
            blendMode = kCGBlendModeLuminosity;
            break;
        default:
            break;
    }
    
    LOVPhoto *photo = [self.collage.photos objectAtIndex:1];
    photo.blendMode = blendMode;
    
    dispatch_async(backgroundQueue, ^() {
        [self.collage previewImage:YES];
        dispatch_async(dispatch_get_main_queue(), ^() {
            self.imageView.image = self.collage.previewImage;
        });
    });

}


@end
