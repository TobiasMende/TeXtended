//
//  ExtendedPdfControlls.h
//  TeXtended
//
//  Created by Max Bannach on 22.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

/**
 * This class handles the controlls in the ExtendedPdfView.
 *
 * @author Max Bannach
 */
@interface ExtendedPdfControlls : NSViewController

/** The PdfView were this controlls depend on */
@property (assign) PDFView *pdfView;
@property (assign) IBOutlet NSSlider *gridHSpacingSlider;
@property (assign) IBOutlet NSSlider *gridHOffsetSlider;
@property (assign) IBOutlet NSSlider *gridVSpacingSlider;
@property (assign) IBOutlet NSSlider *gridVOffsetSlider;

/** 
 * Called if the controlls have changed.
 * Will redraw the controlls and the PDFView.
 */
- (IBAction)update:(id)sender;

/**
 * The box of the controlls.
 * Needed for costum adjustments. 
 */
@property (assign) IBOutlet NSBox *theBox;

@end
