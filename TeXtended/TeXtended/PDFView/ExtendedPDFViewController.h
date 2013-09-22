//
//  PDFViewController.h
//  TeXtended
//
//  Created by Max Bannach on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewControllerProtocol.h"

/**
 * A Controller for a view handeling a ExtendedPdf.
 *
 * @author Max Bannach
 */
@class ExtendedPdf, DocumentModel,PDFView, DocumentController;

@interface ExtendedPDFViewController : NSViewController<ViewControllerProtocol>


/** Current model from which the pdf is handeld by this class. */
@property (strong,nonatomic) DocumentModel *model;

/** The coresponding PdfView. */
@property (strong) IBOutlet PDFView *pdfView;

@property (assign) DocumentController *documentController;

/** 
 * Setup synctex from the pdf back to tex.
 * @param sender
 */
- (void) startBackwardSynctex:(id)sender;
@end
