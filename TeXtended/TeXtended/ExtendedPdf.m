//
//  ExtendedPdf.m
//  DocumentBasedEditor
//
//  Created by Max Bannach on 12.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import "ExtendedPdf.h"

@implementation ExtendedPdf

- (id)init {
    self = [super init];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initVariables];
    }
    
    return self;
}

- (void) initVariables {
    // init variables
    [self setGridHorizontalSpacing:1];
    [self setGridVerticalSpacing:1];
}


- (void) drawPage:(PDFPage *) page
{
    /* get the size of the current page */
    NSSize size = [page boundsForBox:kPDFDisplayBoxMediaBox].size;
    
    /* eventualy draw a grid */
    if (self.drawHorizotalLines || self.drawVerticalLines) {
        [self drawGrid:size];
    }
    
    /* draw pdf content */
    [page drawWithBox:[self displayBox]];
    
}

- (void) drawGrid:(NSSize) size {
    int width = size.width;
    int height = size.height;
    int i = 0 ;
    
    
    // Set the color in the current graphics context for future draw operations
    [[NSColor grayColor] setStroke];
    
    // Create our drawing path
    NSBezierPath* drawingPath = [NSBezierPath bezierPath];
    
    // Draw a grid
    
    // first the vertical lines
    if (self.drawVerticalLines) {
        for( i = 0 ; i <= width ; i=i+[self gridVerticalSpacing] ) { [drawingPath moveToPoint:NSMakePoint(i, 0)]; [drawingPath lineToPoint:NSMakePoint(i, height)]; }
    }
    
    // then the horizontal lines
    if (self.drawHorizotalLines) {
        for( i = 0 ; i <= height ; i=i+[self gridHorizontalSpacing] ) { [drawingPath moveToPoint:NSMakePoint(0,i)]; [drawingPath lineToPoint:NSMakePoint(width, i)]; } // actually draw the grid
    }
    
    /* actual draw it */
    [drawingPath stroke];
}


@end
