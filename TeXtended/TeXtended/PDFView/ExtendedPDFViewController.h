//
//  PDFViewController.h
//  TeXtended
//
//  Created by Max Bannach on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"

@class ExtendedPdf, DocumentModel,PDFView;

@interface ExtendedPDFViewController : NSViewController<DocumentControllerProtocol>

@property (weak)id<DocumentControllerProtocol> parent;
@property (weak,nonatomic) DocumentModel *model;
@property (weak) IBOutlet PDFView *pdfView;
- (void) startBackwardSynctex:(id)sender;
@end
