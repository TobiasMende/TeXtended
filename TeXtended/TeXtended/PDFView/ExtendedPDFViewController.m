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
#import "DocumentController.h"
#import "MainDocument.h"
#import "TMTLog.h"
#import "TMTNotificationCenter.h"
#import "TMTTabViewItem.h"

@interface ExtendedPDFViewController ()
- (void)compilerDidEndCompiling:(NSNotification *)notification;
- (void)loadPDF;
- (void)updatePDFPosition:(NSDictionary*)info;
- (void)updateTabViewItem;
@end

@implementation ExtendedPDFViewController

- (id)initWithDocumentController:(DocumentController *)dc {
    self = [super initWithNibName:@"ExtendedPDFView" bundle:nil];
    if (self) {
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
            [[TMTNotificationCenter centerForCompilable:self.model] postNotificationName:TMTViewSynctexChanged object:m userInfo:[NSDictionary dictionaryWithObjectsAndKeys:beginTex,TMTBackwardSynctexBeginKey,endTex,TMTBackwardSynctexEndKey, nil]];
        }
        // TODO: add support for not opened documents!
    } else {
        NSBeep();
    }
}


- (void)setModel:(DocumentModel *)model {
    if (model != _model) {
        if(_model) {
            [[TMTNotificationCenter centerForCompilable:_model] removeObserver:self name:TMTCompilerSynctexChanged object:_model];
        }
        _model = model;
        [self updateTabViewItem];
        if (_model) {
            [[TMTNotificationCenter centerForCompilable:_model] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerSynctexChanged object:_model];
            
        }
    }
}

- (void)setFirstResponderDelegate:(id<FirstResponderDelegate>)delegate {
    self.pdfView.firstResponderDelegate = delegate;
}

- (void)updateTabViewItem {
    if (!self.model) {
        return;
    }
    //id identifier = self.model.texPath ? self.model.texPath : @"UntitledPDF";
    if (!self.tabViewItem) {
        self.tabViewItem = [TMTTabViewItem new];
        self.tabViewItem.view = self.view;
        [self.tabViewItem bind:@"title" toObject:self withKeyPath:@"model.pdfName" options:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Untitled", @"Untitled") forKey:NSNullPlaceholderBindingOption]];
        [self.tabViewItem bind:@"isProcessing" toObject:self withKeyPath:@"model.isCompiling" options:NULL];
        [self.tabViewItem bind:@"identifier" toObject:self withKeyPath:@"model.texPath" options:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Unknown", @"Unknown") forKey:NSNullPlaceholderBindingOption]];
    }
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
    if (self.model && self.model.pdfPath) {
        NSURL *url = [NSURL fileURLWithPath:self.model.pdfPath];
        PDFDocument *pdfDoc;
        pdfDoc = [[PDFDocument alloc] initWithURL:url];
        [self.pdfView setDocument:pdfDoc];
    }
}


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
    DDLogVerbose(@"dealloc");
#endif
    [[TMTNotificationCenter centerForCompilable:self.model] removeObserver:self];
}

@end
