//
//  ExtendedPdf.h
//  DocumentBasedEditor
//
//  Created by Max Bannach on 12.04.13.
//  Copyright (c) 2013 Max Bannach. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

/**
 * This class the PDFView from cocoas PDFKit by functionalitys
 * to support typhography work.
 *
 * @author Max Bannach
 */
@interface ExtendedPdf : PDFView

/**
 * Describes the distances between to vertical lines in the grid.
 */
@property (assign) int gridVerticalSpacing;

/**
 * Describes the distances between to horizontal lines in the grid.
 */
@property (assign) int gridHorizontalSpacing;

/**
 * 'YES', if the horizontal lines of the grid should be drawn.
 */
@property (assign) bool drawHorizotalLines;

/**
 * 'YES', if the vertical lines of the grid should be drawn.
 */
@property (assign) bool drawVerticalLines;


/**
  * Draws a grid of the given size on the current page.
  * @param size the grid should have.
  * @see [method drawPage]([ExtendedPdf drawPage:])
  */
-(void) drawGrid:(NSSize) size;

/**
  * Overide of PDFKids drawPage.
  * Will draw the given page and add, if requried,
  * thinks like the grid.
  * @param page - the current page of the pdf, that should be drawn
  * @see [method drawGrid]([ExtendedPdf drawGrid:])
  */
- (void) drawPage:(PDFPage *) page;

/**
  * Init required variables. Called from all init methods.
  */
- (void) initVariables;

@end
