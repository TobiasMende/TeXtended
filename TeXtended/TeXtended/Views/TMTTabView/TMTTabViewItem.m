//
//  TMTTabViewItem.m
//  TeXtended
//
//  Created by Max Bannach on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabViewItem.h"

@implementation TMTTabViewItem

- (void) drawLabel:(BOOL)shouldTruncateLabel inRect:(NSRect)labelRect {
    
    [super drawLabel:shouldTruncateLabel inRect:labelRect];
}

- (void) drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    //[super drawLayer:layer inContext:ctx];
}


@end
