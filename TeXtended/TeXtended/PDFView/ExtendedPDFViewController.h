//
//  PDFViewController.h
//  TeXtended
//
//  Created by Max Bannach on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"

/**
 * A Controller for a view handeling a ExtendedPdf.
 *
 * @author Max Bannach
 */
@class ExtendedPdf, DocumentModel,PDFView;

@interface ExtendedPDFViewController : NSViewController<DocumentControllerProtocol>

/** Parent in the controller tree. */
@property (weak)id<DocumentControllerProtocol> parent;

/** Current model from which the pdf is handeld by this class. */
@property (strong,nonatomic) DocumentModel *model;

/** The coresponding PdfView. */
@property (strong) IBOutlet PDFView *pdfView;

/** 
 * Setup synctex from the pdf back to tex.
 * @param sender
 */
- (void) startBackwardSynctex:(id)sender;
@end
