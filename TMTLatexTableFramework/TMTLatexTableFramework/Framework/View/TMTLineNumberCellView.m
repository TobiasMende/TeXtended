//
//  TMTLineNumberCellView.m
//  TMTLatexTableFramework
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTLineNumberCellView.h"

@implementation TMTLineNumberCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSGradient *gradient = [[NSGradient alloc] initWithColors:@[
                                                                [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1],
                                                                [NSColor colorWithCalibratedRed:0.96 green:0.96 blue:0.96 alpha:1],
                                                                [NSColor colorWithCalibratedRed:0.93 green:0.93 blue:0.93 alpha:1],
                                                                [NSColor colorWithCalibratedRed:0.96 green:0.96 blue:0.96 alpha:1]]];
    [gradient drawInRect:self.bounds angle:0];
    [[NSColor headerColor] set];
    [NSBezierPath strokeLineFromPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds)) toPoint:NSMakePoint(NSMaxX(self.bounds), 0)];
}

@end
