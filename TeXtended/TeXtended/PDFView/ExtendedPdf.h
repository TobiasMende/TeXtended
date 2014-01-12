//
//  ExtendedPdf.h
//  DocumentBasedEditor
//
//  Created by Max Bannach on 12.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import <Quartz/Quartz.h>
#import "FirstResponderDelegate.h"

@class ExtendedPdfControlls, ExtendedPDFViewController, PageNumberViewController;

/**
 * This class extends the PDFView from cocoas PDFKit by functionalitys
 * to support typhography work.
 *
 * @author Max Bannach
 */
@interface ExtendedPdf : PDFView {
    ExtendedPdfControlls *controllsView;
    PageNumberViewController *pageNumbers;
    BOOL firstDraw;
}

/**
 * Describes the distances between to vertical lines in the grid.
 */
@property int gridVerticalSpacing;

/**
 * Describes the distances between to horizontal lines in the grid.
 */
@property int gridHorizontalSpacing;

/**
 * 'YES', if the horizontal lines of the grid should be drawn.
 */
@property bool drawHorizotalLines;

/**
 * 'YES', if the vertical lines of the grid should be drawn.
 */
@property bool drawVerticalLines;

/**
 * Move the horizontal lines in south direction by the given amount outgoing from (0,0).
 */
@property int gridHorizontalOffset;

/**
 * Move the vertical lines in east direction by the given amount outgoing from (0,0).
 */
@property int gridVerticalOffset;

/**
 * True if page numbers should be drawn.
 */
@property BOOL drawPageNumbers;

/**
 * Color of the grid, default is gray.
 */
@property (strong) NSColor *gridColor;

/** The controller */
@property (assign) ExtendedPDFViewController *controller;

/** Timer which defines how long the page numbers are shown after a scroll event */
@property (strong) NSTimer *displayPageNumbersTimer;

/** Unit used to scale the grid */
@property (strong) NSString* gridUnit;

/** Are the pages of the pdf transparent? */
@property bool pageAlpha;

@property (assign) id<FirstResponderDelegate> firstResponderDelegate;

/** The current scaling factor of the grid. */
- (float) getScalingFactor;

/**
  * Draws a grid of the given size on the current page.
  * @param size the grid should have.
  * @see [method drawPage]([ExtendedPdf drawPage:])
  */
-(void) drawGrid:(NSSize) size;

/**
  * Init required variables. Called from all init methods.
  */
- (void) initVariables;

- (IBAction)showStatistics:(id)sender;
@end
