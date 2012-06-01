//
//  LOVGridView.m
//  Layover
//
//  Created by Bryan Hansen on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVGridView.h"

static const CGFloat LOVGridViewSpacing = 64.0f;

@interface LOVGridView ()
- (void)setup;
@end

@implementation LOVGridView

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
}

- (void)drawRect:(CGRect)rect
{    
    int vertCount = ceilf(self.bounds.size.width/LOVGridViewSpacing) - 1;
    int horzCount = ceilf(self.bounds.size.height/LOVGridViewSpacing) - 1;
    CGRect rects[vertCount + horzCount];
    
    for (int i = 0; i < vertCount; ++i) {
        rects[i] = CGRectMake((i + 1) * LOVGridViewSpacing, 0.0f, 1.0f, self.bounds.size.height);
    }
    
    for (int i = 0; i < horzCount; ++i) {
        rects[i + vertCount] = CGRectMake(0.0f, (i + 1) * LOVGridViewSpacing, self.bounds.size.width, 1.0f);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.5f alpha:0.5f].CGColor);
    CGContextFillRects(context, rects, vertCount + horzCount);
}

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (hidden) {
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
        
    } else {
        self.alpha = 0.0f;
        self.hidden = NO;
        
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1.0f;
        }];
    }
}

@end
