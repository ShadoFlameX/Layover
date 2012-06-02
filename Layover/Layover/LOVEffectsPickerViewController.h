//
//  LOVEffectsPickerViewController.h
//  Layover
//
//  Created by Bryan Hansen on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LOVCollage;

typedef void (^LOVEffectsPickerSaveBlock)(CGBlendMode);

@interface LOVEffectsPickerViewController : UIViewController

@property (nonatomic,strong) LOVCollage *collage;
@property (nonatomic,copy) LOVEffectsPickerSaveBlock saveBlock;

- (CGRect)rectForViewWithEffect:(CGBlendMode)blendMode;

@end
