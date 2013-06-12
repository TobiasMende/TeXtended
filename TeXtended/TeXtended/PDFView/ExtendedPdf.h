//
//  ExtendedPdf.h
//  DocumentBasedEditor
//
//  Created by Max Bannach on 12.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

@class ExtendedPdfControlls;

/**
 * This class the PDFView from cocoas PDFKit by functionalitys
 * to support typhography work.
 *
 * @author Max Bannach
 */
@interface ExtendedPdf : PDFView {
    ExtendedPdfControlls *controllsView;
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
 * Color of the grid, default is gray.
 */
@property (strong) NSColor *gridColor;

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
@end
