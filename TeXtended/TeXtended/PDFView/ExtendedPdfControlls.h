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
@class ExtendedPdf;

@interface ExtendedPdfControlls : NSViewController

/** The ExtendedPdf we belong to. */
    @property (assign) ExtendedPdf *extendedPdf;

/** The PdfView were this controlls depend on */
    @property (assign) IBOutlet NSSlider *gridHSpacingSlider;

    @property (assign) IBOutlet NSSlider *gridHOffsetSlider;

    @property (assign) IBOutlet NSSlider *gridVSpacingSlider;

    @property (assign) IBOutlet NSSlider *gridVOffsetSlider;

    @property (strong) IBOutlet NSButton *shineThrough;

    - (IBAction)checkShineThrough:(id)sender;


/** Constructor */
    - (id)initWithExtendedPdf:(ExtendedPdf *)extedendPdf;

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
