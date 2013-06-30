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
#import "BackwardSynctex.h"
#import "DocumentCreationController.h"
#import "MainDocument.h"

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

/** Load the view and add a controlls panel */
- (void)loadView {
    [super loadView];
    [(ExtendedPdf*)self.pdfView setController:self];
    [self loadPDF];
}

- (void) startBackwardSynctex:(id)sender {
    PDFSelection *currentSelection = [self.pdfView currentSelection];
    if (currentSelection) {
        PDFPage *p = [currentSelection.pages objectAtIndex:0];
        NSRect selectionBounds = [currentSelection boundsForPage:p];
        NSRect pageBounds = [p boundsForBox:kPDFDisplayBoxMediaBox];
        NSPoint beginPos, endPos;
        beginPos.x = selectionBounds.origin.x;
        beginPos.y = NSMaxY(pageBounds)-NSMaxY(selectionBounds);
        
        endPos.x = NSMaxX(selectionBounds);
        endPos.y = NSMaxY(pageBounds)- selectionBounds.origin.y;
        NSUInteger index = [self.pdfView.document indexForPage:p];
        BackwardSynctex *beginTex = [[BackwardSynctex alloc] initWithOutputPath:self.model.pdfPath page:index+1 andPosition:beginPos];
        BackwardSynctex *endTex = [[BackwardSynctex alloc] initWithOutputPath:self.model.pdfPath page:index+1 andPosition:endPos];
        if (beginTex && endTex) {
            DocumentModel *m = [self.model modelForTexPath:beginTex.inputPath];
            [[NSNotificationCenter defaultCenter] postNotificationName:TMTViewSynctexChanged object:m userInfo:[NSDictionary dictionaryWithObjectsAndKeys:beginTex,TMTBackwardSynctexBeginKey,endTex,TMTBackwardSynctexEndKey, nil]];
        }
        // TODO: add support for not opened documents!
    } else {
        NSBeep();
    }
}

- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (void)setModel:(DocumentModel *)model {
    if (model != _model) {
        if(_model) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerSynctexChanged object:_model];
        }
        _model = model;
        if (_model) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerSynctexChanged object:_model];
            
        }
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
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self loadPDF];
        }];
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
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updatePDFPosition:[notification userInfo]];
    }];
}

- (void)updatePDFPosition:(NSDictionary *)info {
    PDFDocument *doc = self.pdfView.document;
    [self loadPDF];
    if (doc) {
        ForwardSynctex *synctex = [info objectForKey:TMTForwardSynctexKey];
        if (synctex.page > 0 && doc.pageCount > synctex.page-1) {
            PDFPage *p = [doc pageAtIndex:synctex.page-1];
            CGFloat y = NSMaxY([p boundsForBox:kPDFDisplayBoxMediaBox]) - synctex.v;
            NSPoint point = NSMakePoint(synctex.h, y);
            NSRect rect = NSMakeRect(point.x, point.y+NSMaxY([p boundsForBox:kPDFDisplayBoxMediaBox])/5, 0, 0);
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
