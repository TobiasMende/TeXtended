//
//  TMTBorderedScrollView.m
//  TMTHelperCollection
//
//  Created by Tobias Mende on 22.10.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTBorderedScrollView.h"

@implementation TMTBorderedScrollView

- (void)drawRect:(NSRect)dirtyRect {
    static NSColor *borderColor = nil;
    if ([[self window] isKeyWindow]) {
        borderColor = [NSColor colorWithCalibratedWhite:0.416 alpha:0.25f];
    } else {
        borderColor = [NSColor colorWithCalibratedWhite:0.651 alpha:0.25f];
    }
    
    [borderColor setStroke];
    
    
    if (self.bottomBorder) {
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 0.5f)];
    }
    if (self.topBorder) {
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) - 0.5f)];
    }
    if (self.leftBorder) {
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds) - 0.5f)];
    }
    
    if (self.rightBorder) {
        [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) - 0.5f)
                                  toPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 0.5f)];
    }
}

@end
