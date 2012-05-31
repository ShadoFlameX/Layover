//
//  CGGeometry+LayoverExtensions.h
//  Layover
//
//  Created by Bryan Hansen on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline CGRect CGRectWithSize(CGSize size);

static inline CGRect CGRectCenterRectInRect(CGRect insideRect, CGRect outsideRect);

/*** Definitions of inline functions. ***/

static inline CGRect CGRectWithSize(CGSize size)
{
    return CGRectMake(0, 0, size.width, size.height);
}

static inline CGRect CGRectCenterRectInRect(CGRect insideRect, CGRect outsideRect)
{
    CGFloat originX = floorf((outsideRect.size.width - insideRect.size.width)/2);
    CGFloat originY = floorf((outsideRect.size.height - insideRect.size.height)/2);
    
    return CGRectMake(originX, originY, insideRect.size.width, insideRect.size.height);
};
