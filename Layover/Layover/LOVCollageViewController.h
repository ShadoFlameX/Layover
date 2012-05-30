//
//  LOVViewController.h
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LOVCollageView;

@interface LOVCollageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic,strong) IBOutlet LOVCollageView *collageView;

- (IBAction)showCamera:(id)sender;
- (IBAction)showPhotoPicker:(id)sender;

@end
