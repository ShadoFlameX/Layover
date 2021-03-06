//
//  LOVEffectsPickerViewController.h
//  Layover
//
//  Created by Bryan Hansen on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LOVCollage;

typedef void (^LOVEffectsPickerCompletionBlock)(CGRect effectsRect);

@interface LOVEffectsPickerViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic,strong) LOVCollage *collage;
@property (nonatomic,assign) CGRect finalRect;
@property (nonatomic,copy) LOVEffectsPickerCompletionBlock completionBlock;

- (CGRect)scrollToEffect:(CGBlendMode)blendMode;

@end
