//
//  LOVCollageView.m
//  Layover
//
//  Created by Bryan Hansen on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LOVCollageView.h"
#import "LOVPhoto.h"

@interface LOVCollageView ()

@property (nonatomic,strong) NSMutableArray *photos;

- (void)setup;

@end

@implementation LOVCollageView

@synthesize photos = m_photos;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.photos = [NSMutableArray array];
}

- (void)addPhoto:(LOVPhoto *)photo;
{
    [self.photos addObject:photo];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.photos.count == 0)
        return;
    
    [self.photos enumerateObjectsUsingBlock:^(LOVPhoto *photo, NSUInteger idx, BOOL *stop) {
        [photo.image drawInRect:rect blendMode:photo.blendMode alpha:photo.alpha];
    }];
}

@end
