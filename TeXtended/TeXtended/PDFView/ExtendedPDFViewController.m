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
#import "ForwardSynctex.h"


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
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerSynctexChanged object:_model];
    }
    [self willChangeValueForKey:@"model"];
    _model = model;
    [self didChangeValueForKey:@"model"];
    if (_model) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerSynctexChanged object:_model];
    }
}

- (NSSet*)children {
    return [NSSet setWithObjects:nil];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    [self documentHasChangedAction];
}

- (void) documentHasChangedAction {
    if (!self.pdfView.document) {
        [self loadPDF];
    }
}

- (void)loadPDF {
    if (self.model.faultingState == 0 && self.model.pdfPath) {
        NSURL *url = [NSURL fileURLWithPath:self.model.pdfPath];
        PDFDocument *pdfDoc;
        pdfDoc = [[PDFDocument alloc] initWithURL:url];
        [self.pdfView performSelectorOnMainThread:@selector(setDocument:) withObject:pdfDoc waitUntilDone:YES];
    }
}

- (void) breakUndoCoalescing {}


#pragma mark -
#pragma mark Notification Observer

- (void)compilerDidEndCompiling:(NSNotification *)notification {
    [self loadPDF];
    PDFDocument *doc = self.pdfView.document;
    if (doc) {
        ForwardSynctex *synctex = [[notification userInfo] objectForKey:TMTForwardSynctexKey];
        if (synctex.page > 0) {
            PDFPage *p = [doc pageAtIndex:synctex.page-1];
            CGFloat y = NSMaxY([p boundsForBox:kPDFDisplayBoxMediaBox]) - synctex.v;
            NSPoint point = NSMakePoint(synctex.h, y);
            [self.pdfView goToRect:NSMakeRect(point.x, point.y+20, 0, 0) onPage:p];
        }
    }
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"ExtendedPDFViewController dealloc");
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
