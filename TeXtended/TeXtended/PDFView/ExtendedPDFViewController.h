//
//  PDFViewController.h
//  TeXtended
//
//  Created by Max Bannach on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DocumentControllerProtocol.h"

@class ExtendedPdf, DocumentModel;

@interface ExtendedPDFViewController : NSViewController<DocumentControllerProtocol>

@property (weak)id<DocumentControllerProtocol> parent;
@property (weak,nonatomic) DocumentModel *model;
@property (unsafe_unretained) IBOutlet ExtendedPdf *pdfView;

@end
