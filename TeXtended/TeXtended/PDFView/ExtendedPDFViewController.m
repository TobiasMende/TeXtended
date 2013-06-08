//
//  PDFViewController.m
//  TeXtended
//
//  Created by Max Bannach on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExtendedPDFViewController.h"
#import "ExtendedPdf.h"
#import "DocumentModel.h"
#import "Constants.h"


@interface ExtendedPDFViewController ()
- (void)compilerDidEndCompiling:(NSNotification *)notification;
- (void)loadPDF;
@end

@implementation ExtendedPDFViewController

- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"ExtendedPDFView" bundle:nil];
    if (self) {
        self.parent = parent;
    }
    return self;
}

- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (void)setModel:(DocumentModel *)model {
    if(_model) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:self];
    }
    [self willChangeValueForKey:@"model"];
    _model = model;
    [self didChangeValueForKey:@"model"];
    if (_model) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerDidEndCompiling object:_model];
    }
}

- (NSSet*)children {
    return [NSSet setWithObjects:nil];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    [self documentHasChangedAction];
}

- (void) documentHasChangedAction {
    [self loadPDF];
}

- (void)loadPDF {
    if (self.model.pdfPath) {
        NSURL *url = [NSURL fileURLWithPath:self.model.pdfPath];
        PDFDocument *pdfDoc;
        pdfDoc = [[PDFDocument alloc] initWithURL:url];
        [self.pdfView setDocument:pdfDoc];
        [self.pdfView setNeedsDisplay:YES];
    }
}

- (void) breakUndoCoalescing {}


#pragma mark -
#pragma mark Notification Observer

- (void)compilerDidEndCompiling:(NSNotification *)notification {
    [self loadPDF];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"ExtendedPDFViewController dealloc");
#endif
     [[NSNotificationCenter defaultCenter]removeObserver:self];
}



@end
