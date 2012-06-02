//
//  LOVViewController.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LOVCollageViewController.h"
#import "LOVPhoto.h"
#import "LOVCollage.h"
#import "LOVGridView.h"
#import "LOVEffectsPickerViewController.h"
#import "NSFileManager+LayoverExtensions.h"

enum  {
    LOVCollageViewControllerActionSheetAddPhoto = 0,
    LOVCollageViewControllerActionSheetEffects,
    LOVCollageViewControllerActionSheetUseLastPhoto,
    LOVCollageViewControllerActionSheetClearPhotos
};

static const NSUInteger FileNotFoundErrorCode = 2;
static const CGFloat PanGesturePadding = 24.0f;


@interface LOVCollageViewController () {
    dispatch_queue_t backgroundQueue;
    CGAffineTransform initialTransform;
}

@property (nonatomic,strong) LOVPhoto *selectedPhoto;
@property (nonatomic,strong) LOVCollage *collage;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic,strong) IBOutlet LOVGridView *gridView;
@property (nonatomic,strong) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic,strong,readonly) UIImagePickerController *imagePicker;
@property (nonatomic,strong) UIActivityIndicatorView *loadingView;
@property (nonatomic,strong) UITapGestureRecognizer *selectPhotoGesture;
@property (nonatomic,strong) UIPanGestureRecognizer *alphaGesture;
@property (nonatomic,strong) UIRotationGestureRecognizer *rotationGesture;

- (void)addImage:(UIImage *)image;

@end

@implementation LOVCollageViewController

#pragma mark - Properties

@synthesize selectedPhoto = m_selectedPhoto;
@synthesize collage = m_collage;
@synthesize assetsLibrary = m_assetsLibrary;
@synthesize gridView = m_gridView;
@synthesize imageView = m_imageView;
@synthesize toolbar = m_toolbar;
@synthesize imagePicker = m_imagePicker;
@synthesize loadingView = m_loadingView;
@synthesize selectPhotoGesture = m_selectPhotoGesture;
@synthesize alphaGesture = m_panGesture;
@synthesize rotationGesture = m_rotationGesture;

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
        backgroundQueue = dispatch_queue_create("com.skeuo.LOVCollageViewController.backgroundqueue", DISPATCH_QUEUE_SERIAL);        
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
    
    self.imageView.transform = CGAffineTransformIdentity;
    self.imageView.alpha = 0.0f;
        
    self.gridView.hidden = YES;
    
    self.loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    self.loadingView.center = CGPointMake(self.view.bounds.size.width/2.0f, self.view.bounds.size.height/2.0f);
    self.loadingView.frame = CGRectIntegral(self.loadingView.frame);
    self.loadingView.hidesWhenStopped = YES;

    self.selectPhotoGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectNextPhoto:)];
    [self.imageView addGestureRecognizer:self.selectPhotoGesture];
    
    self.alphaGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.imageView addGestureRecognizer:self.alphaGesture];
    
    [self.view addSubview:self.loadingView];
    
    [self addImage:[UIImage imageNamed:@"photo1.png"]];
    [self addImage:[UIImage imageNamed:@"photo2.png"]];
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

- (IBAction)showAddPhoto:(id)sender
{
    UIActionSheet *addPhotoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo Library", @"Last Photo Taken", @"Clear Photos", nil];
    addPhotoSheet.tag = LOVCollageViewControllerActionSheetAddPhoto;
    
    [addPhotoSheet showInView:self.view];
}

- (IBAction)beginRotationMode:(id)sender
{
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton addTarget:self action:@selector(endRotationMode:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton sizeToFit];
    doneButton.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    CGRect rect = doneButton.frame;
    rect.origin.y = 20;
    doneButton.frame = rect;
    
    [self.view addSubview:doneButton];
     
    self.imageView.gestureRecognizers = nil;
    
    if (!self.rotationGesture) {
        self.rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    }
    
    [self.imageView addGestureRecognizer:self.rotationGesture];
    [self.imageView addGestureRecognizer:self.selectPhotoGesture];
    
    [self.gridView setHidden:NO animated:YES];
}

- (void)endRotationMode:(id)sender
{
    UIButton *btn = sender;
    [btn removeFromSuperview];
    
    self.imageView.gestureRecognizers = nil;
    [self.imageView addGestureRecognizer:self.alphaGesture];
    [self.imageView addGestureRecognizer:self.selectPhotoGesture];
    
    [self.gridView setHidden:YES animated:YES];
}

- (IBAction)showEffects:(id)sender
{
    if (self.collage.photos.count < 2)
        return;
    
    self.toolbar.userInteractionEnabled = NO;
    
    LOVEffectsPickerViewController *effectsPicker = [[LOVEffectsPickerViewController alloc] initWithNibName:@"LOVEffectsPickerViewController" bundle:nil];
    effectsPicker.collage = self.collage;
    
    void (^saveBlock)(CGBlendMode) = ^(CGBlendMode blendMode) {
        self.selectedPhoto.blendMode = blendMode;
        
        [self.loadingView startAnimating];
        dispatch_async(backgroundQueue, ^() {
            [self.collage previewImage];
            dispatch_async(dispatch_get_main_queue(), ^() {
                self.imageView.image = self.collage.previewImage;
                [self.loadingView stopAnimating];
            });
        });
    };
    effectsPicker.saveBlock = saveBlock;
    
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:effectsPicker];
    navCon.navigationBar.barStyle = UIBarStyleBlack;
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:self.imageView.image];
    tempImageView.frame = [self.view convertRect:self.imageView.frame toView:[UIApplication sharedApplication].keyWindow];
    tempImageView.contentMode = self.imageView.contentMode;
    tempImageView.clipsToBounds = self.imageView.clipsToBounds;
    
    [[UIApplication sharedApplication].keyWindow addSubview:tempImageView];

    self.imageView.hidden = YES;
    
    [UIView animateWithDuration:0.5f animations:^{
        tempImageView.frame = [effectsPicker rectForViewWithEffect:((LOVPhoto *)[self.collage.photos objectAtIndex:self.collage.photos.count - 1]).blendMode];
        tempImageView.layer.cornerRadius = 8.0f;
        
    } completion:^(BOOL finished) {
        self.toolbar.userInteractionEnabled = YES;
    }];
    
    [self presentViewController:navCon animated:YES completion:^{
        self.imageView.hidden = NO;
        [tempImageView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.75];
    }];
}

- (void)useLastPhotoTaken
{
    if (!self.assetsLibrary) {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    __weak LOVCollageViewController *weakSelf = self; 
    
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {        
        
        // TODO: why is this block running twice?!?!
        __block BOOL photoAdded = NO;
        
        if (group) {
            [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (!photoAdded && result) {
                    ALAssetRepresentation *rep = [result defaultRepresentation];
                    CGImageRef imageRef = [rep fullResolutionImage];
                    UIImage *lastPhoto = [UIImage imageWithCGImage:imageRef scale:rep.scale orientation:rep.orientation];
                    
                    if (lastPhoto) {
                        [weakSelf.loadingView startAnimating];
                        
                        dispatch_async(backgroundQueue, ^() {
                            [weakSelf addImage:lastPhoto];
                        });
                    }
                    
                    photoAdded = YES;
                }
                
                *stop = YES;
            }];
        }
        *stop = YES;
    
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];    
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
    
    if (self.collage.photos.count > 0) {
        photo.blendMode = kCGBlendModeScreen;
        photo.alpha = 0.5f;
    }
    
    [self.collage addPhoto:photo];
    
    dispatch_async(dispatch_get_main_queue(), ^() {
        self.selectedPhoto = photo;
        self.imageView.image = self.collage.previewImage;
        [self.loadingView stopAnimating];
        
        if (self.imageView.alpha != 1.0f) {
            self.imageView.transform = CGAffineTransformMakeScale(1.15f, 1.15f);
        
            [UIView animateWithDuration:0.5f animations:^{
                self.imageView.alpha = 1.0f;
                self.imageView.transform = CGAffineTransformIdentity;
            }];
        }
    });
}

- (void)selectNextPhoto:(UITapGestureRecognizer *)gestureRecognizer
{
    NSUInteger index = [self.collage.photos indexOfObject:self.selectedPhoto];
    
    switch (index) {
        case 0:
            index = self.collage.photos.count - 1;
            break;
        case NSNotFound:
            index = self.collage.photos.count - 1;
            break;
        default:
            --index;
            break;
    }
    
    self.selectedPhoto = [self.collage.photos objectAtIndex:index];
}

- (void)clearPhotos:(id)sender
{
    UIActionSheet *clearPhotosActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to clear all photos?",@"action sheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:NSLocalizedString(@"Clear Photos", @"") otherButtonTitles:nil];
    clearPhotosActionSheet.tag = LOVCollageViewControllerActionSheetClearPhotos;
    
    [clearPhotosActionSheet showInView:self.view];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (self.collage.photos.count > 1) {
        CGFloat posX = [self.alphaGesture locationInView:self.view].x;
        posX -= PanGesturePadding;
        
        CGFloat newAlpha = posX/(self.view.frame.size.width - PanGesturePadding*2);
        
        newAlpha = MAX(0.0f, newAlpha);
        newAlpha = MIN(1.0f, newAlpha);
        
        self.selectedPhoto.alpha = newAlpha;
        
        [self.collage previewImage];
        self.imageView.image = self.collage.previewImage;
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer
{    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        initialTransform = self.selectedPhoto.transform;
    }
    
    self.selectedPhoto.transform = CGAffineTransformRotate(initialTransform, -gestureRecognizer.rotation);
    
    [self.collage previewImage];
    self.imageView.image = self.collage.previewImage;
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
    if (actionSheet.tag == LOVCollageViewControllerActionSheetAddPhoto) {
        if (buttonIndex == 0) {
            [self showCamera:nil];
        
        } else if (buttonIndex == 1) {
            [self showPhotoPicker:nil];
        
        } else if (buttonIndex == 2) {
            [self useLastPhotoTaken];
            
        } else if (buttonIndex == 3) {
            [self clearPhotos:nil];
        }
    
    } else if (actionSheet.tag == LOVCollageViewControllerActionSheetClearPhotos) {
        if (buttonIndex == 0) {
            [UIView animateWithDuration:0.5f animations:^{
                self.imageView.alpha = 0.0f;
                self.imageView.transform = CGAffineTransformMakeScale(1.15f, 1.15f);
            
            } completion:^(BOOL finished) {
                [self.collage removeAllPhotos];
                self.imageView.image = nil;
                self.imageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}


@end
