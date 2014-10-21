//
//  PDFViewController.m
//  TeXtended
//
//  Created by Max Bannach on 01.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExtendedPDFViewController.h"
#import "ExtendedPdf.h"
#import "ForwardSynctex.h"
#import "BackwardSynctex.h"
#import "DocumentCreationController.h"
#import "TMTTabViewItem.h"
#import "TMTTabManager.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT_DYNAMIC

@interface ExtendedPDFViewController ()

    - (void)compilerDidEndCompiling:(NSNotification *)notification;

    - (void)loadPDF;

    - (void)updatePDFPosition:(NSDictionary *)info;

    - (void)updateTabViewItem;

    - (void)viewDidClose:(NSNotification *)note;
@end

@implementation ExtendedPDFViewController

    - (id)init
    {
        self = [super initWithNibName:@"ExtendedPDFView" bundle:nil];
        if (self) {
        }
        return self;
    }

+ (void)initialize
{
    if (self == [ExtendedPDFViewController class]) {
        
        LOGGING_LOAD           /* put initialization code here */
        
    }
}

/** Load the view and add a controlls panel */
    - (void)loadView
    {
        [super loadView];
        [(ExtendedPdf *) self.pdfView setController:self];
        [self performSelectorOnMainThread:@selector(loadPDF) withObject:nil waitUntilDone:NO];
    }


    - (void)startBackwardSynctex:(id)sender
    {
        PDFSelection *currentSelection = [self.pdfView currentSelection];
        if (currentSelection) {
            PDFPage *p = (currentSelection.pages)[0];
            NSRect selectionBounds = [currentSelection boundsForPage:p];
            NSRect pageBounds = [p boundsForBox:kPDFDisplayBoxMediaBox];
            NSPoint beginPos, endPos;
            beginPos.x = selectionBounds.origin.x;
            beginPos.y = NSMaxY(pageBounds) - NSMaxY(selectionBounds);

            endPos.x = NSMaxX(selectionBounds);
            endPos.y = NSMaxY(pageBounds) - selectionBounds.origin.y;
            NSUInteger index = [self.pdfView.document indexForPage:p];
            BackwardSynctex *beginTex = [[BackwardSynctex alloc] initWithOutputPath:self.model.pdfPath page:index + 1 andPosition:beginPos];
            BackwardSynctex *endTex = [[BackwardSynctex alloc] initWithOutputPath:self.model.pdfPath page:index + 1 andPosition:endPos];
            if (beginTex && endTex) {
                [[DocumentCreationController sharedDocumentController] showTexDocumentForPath:beginTex.inputPath withReferenceModel:self.model andCompletionHandler:^(DocumentModel *model)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TMTViewSynctexChanged object:model userInfo:@{TMTBackwardSynctexBeginKey : beginTex, TMTBackwardSynctexEndKey : endTex}];
                }];


            }
            // TODO: add support for not opened documents!
        } else {
            NSBeep();
        }
    }

    - (void)viewDidClose:(NSNotification *)note
    {
        self.pdfView.firstResponderDelegate = nil;
    }


    - (void)setModel:(DocumentModel *)model
    {
        if (model != _model) {
            if (_model) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerSynctexChanged object:_model];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTCompilerDidEndCompiling object:_model];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTTabViewDidCloseNotification object:_model.pdfIdentifier];
            }
            _model = model;
            [self updateTabViewItem];
            if (_model) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerDidEndCompiling:) name:TMTCompilerDidEndCompiling object:_model];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(compilerSynctexDidChange:) name:TMTCompilerSynctexChanged object:_model];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidClose:) name:TMTTabViewDidCloseNotification object:_model.pdfIdentifier];

            }
        }
    }

    - (void)setFirstResponderDelegate:(id <FirstResponderDelegate>)delegate
    {
        self.pdfView.firstResponderDelegate = delegate;
    }

    - (void)updateTabViewItem
    {
        if (!self.model) {
            return;
        }
        //id identifier = self.model.texPath ? self.model.texPath : @"UntitledPDF";
        if (!self.tabViewItem) {
            self.tabViewItem = [TMTTabViewItem new];
            self.tabViewItem.view = self.view;
            [self.tabViewItem bind:@"title" toObject:self withKeyPath:@"model.pdfName" options:@{NSNullPlaceholderBindingOption : NSLocalizedString(@"Untitled", @"Untitled")}];
            [self.tabViewItem bind:@"isProcessing" toObject:self withKeyPath:@"model.isCompiling" options:NULL];
            [self.tabViewItem bind:@"identifier" toObject:self withKeyPath:@"model.pdfIdentifier" options:NULL];
        }
    }


    - (void)loadPDF
    {
        if (self.model.pdfPath) {
            // what is visible before the update?
            PDFDestination *visibleArea = [self.pdfView currentDestination];
            NSUInteger index = NSNotFound;
            NSPoint point = NSMakePoint(0, 0);
            if (visibleArea) {
                index = [self.pdfView.document indexForPage:visibleArea.page];
                point = visibleArea.point;
            }

            // update
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.model.pdfPath]) {
                NSURL *url = [NSURL fileURLWithPath:self.model.pdfPath];
                PDFDocument *pdfDoc;
                pdfDoc = [[PDFDocument alloc] initWithURL:url];
                DDLogTrace(@"%@", self.model.texPath);
                [self.pdfView setDocument:pdfDoc];
                // restore visible region
                if (index != NSNotFound && index < pdfDoc.pageCount) {
                    PDFPage *page = [pdfDoc pageAtIndex:index];
                    if (page) {
                        [self.pdfView goToRect:NSMakeRect(point.x, point.y, 0, 0) onPage:page];
                    }
                }
                
                [self.pdfView updatePageNumber:nil];
            }
        }
    }


#pragma mark -
#pragma mark Notification Observer

    - (void)compilerDidEndCompiling:(NSNotification *)notification
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
        {
            [self loadPDF];
            [self updatePDFPosition:[notification userInfo]];
        }];
    }

    - (void)compilerSynctexDidChange:(NSNotification *)notification
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
        {
            [self updatePDFPosition:[notification userInfo]];
        }];
    }

    - (void)updatePDFPosition:(NSDictionary *)info
    {
        PDFDocument *doc = self.pdfView.document;
        //
        if (doc) {
            ForwardSynctex *synctex = info[TMTForwardSynctexKey];
            if (synctex.page > 0 && doc.pageCount > synctex.page - 1) {
                PDFPage *p = [doc pageAtIndex:synctex.page - 1];
                CGFloat y = NSMaxY([p boundsForBox:kPDFDisplayBoxMediaBox]) - synctex.v;
                NSPoint point = NSMakePoint(synctex.h, y);
                NSRect rect = NSMakeRect(point.x, point.y + NSMaxY([p boundsForBox:kPDFDisplayBoxMediaBox]) / 5, 0, 0);
                [self.pdfView goToRect:rect onPage:p];
            }
        }

    }

    - (void)dealloc
    {
        NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:self.model.pdfIdentifier];
        if (item) {
            [item.tabView removeTabViewItem:item];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }

@end
