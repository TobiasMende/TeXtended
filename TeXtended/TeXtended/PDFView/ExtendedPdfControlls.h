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
@property (weak) PDFView *pdfView;
@property (weak) IBOutlet NSSlider *gridHSpacingSlider;
@property (weak) IBOutlet NSSlider *gridHOffsetSlider;
@property (weak) IBOutlet NSSlider *gridVSpacingSlider;
@property (weak) IBOutlet NSSlider *gridVOffsetSlider;

/** 
 * Called if the controlls have changed.
 * Will redraw the controlls and the PDFView.
 */
- (IBAction)update:(id)sender;

/**
 * The box of the controlls.
 * Needed for costum adjustments. 
 */
@property (weak) IBOutlet NSBox *theBox;

@end
