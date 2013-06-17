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
- (void)updatePDFPosition:(NSDictionary*)info;
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
        [self performSelectorOnMainThread:@selector(loadPDF) withObject:nil waitUntilDone:YES];
    }
}

- (void)loadPDF {
    if (self.model.faultingState == 0 && self.model.pdfPath) {
        NSURL *url = [NSURL fileURLWithPath:self.model.pdfPath];
        PDFDocument *pdfDoc;
        pdfDoc = [[PDFDocument alloc] initWithURL:url];
        [self.pdfView setDocument:pdfDoc];
    }
}

- (void) breakUndoCoalescing {}


#pragma mark -
#pragma mark Notification Observer

- (void)compilerDidEndCompiling:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(updatePDFPosition:) withObject:[notification userInfo] waitUntilDone:NO];
}

- (void)updatePDFPosition:(NSDictionary *)info {
    PDFDocument *doc = self.pdfView.document;
    [self loadPDF];
    if (doc) {
        ForwardSynctex *synctex = [info objectForKey:TMTForwardSynctexKey];
        if (synctex.page > 0) {
            PDFPage *p = [doc pageAtIndex:synctex.page-1];
            CGFloat y = NSMaxY([p boundsForBox:kPDFDisplayBoxMediaBox]) - synctex.v;
            NSPoint point = NSMakePoint(synctex.h, y);
            NSRect rect = NSMakeRect(point.x, point.y+100, 0, 0);
            [self.pdfView goToRect:rect onPage:p];
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
