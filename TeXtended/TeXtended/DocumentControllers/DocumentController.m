//
//  DocumentController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DocumentController.h"
#import "TextViewController.h"
#import "Compiler.h"
#import "MainWindowController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "ExtendedPDFViewController.h"
#import "MainDocument.h"
#import "TMTTabManager.h"
#import "HighlightingTextView.h"
#import "ExtendedPdf.h"
#import "ModelInfoWindowController.h"

@interface DocumentController ()

    - (void)updateViewsAfterModelChange;

    - (ExtendedPDFViewController *)findExistingPDFViewControllerFor:(DocumentModel *)model;

    - (void)findOrCreatePDFViewControllerFor:(DocumentModel *)model;
@end

@implementation DocumentController

    + (void)initialize
    {
        if (self == [DocumentController class]) {

            /* put initialization code here */

        }
    }

    - (id)initWithDocument:(DocumentModel *)model andMainDocument:(MainDocument *)mainDocument
    {
        self = [super init];
        if (self) {
            self.mainDocument = mainDocument;
            self.model = model;
            self.model.documentOpened = YES;
            self.consoleViewControllers = [NSMutableSet new];
            self.compiler = [[Compiler alloc] initWithCompileProcessHandler:self];
            [self.textViewController addObserver:self.compiler];
        }
        return self;
    }


    - (BOOL)saveDocumentModel:(NSError * __autoreleasing *)outError
    {
        self.model.selectedRange =self.textViewController.textView.selectedRange;
        return [self.model saveContent:[self.textViewController content] error:outError];
    }


    - (void)breakUndoCoalescing
    {
        [self.textViewController breakUndoCoalescing];
    }


    - (void)setModel:(DocumentModel *)model
    {
        if (model != _model) {
            if (self.model) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTTabViewDidCloseNotification object:self.model.texIdentifier];
                for (DocumentModel *m in self.model.mainDocuments) {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:TMTTabViewDidCloseNotification object:m.pdfIdentifier];
                }
            }
            _model = model;

            [self updateViewsAfterModelChange];
            if (self.model) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(texViewDidClose:) name:TMTTabViewDidCloseNotification object:self.model.texIdentifier];
                for (DocumentModel *m in self.model.mainDocuments) {
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pdfViewDidClose:) name:TMTTabViewDidCloseNotification object:m.pdfIdentifier];
                }
            }
        }
    }

    - (void)texViewDidClose:(NSNotification *)note
    {
        self.model.documentOpened = NO;
        self.textViewController.textView.firstResponderDelegate = nil;
        self.textViewController = nil;
        [self.mainDocument removeDocumentController:self];
    }

    - (void)closeDocument
    {
        self.model.documentOpened = NO;
        self.textViewController.textView.firstResponderDelegate = nil;
        self.textViewController = nil;
        NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:self.model.texIdentifier];
        [item.tabView removeTabViewItem:item];
        [self.mainDocument removeDocumentController:self];
    }

    - (void)pdfViewDidClose:(NSNotification *)note
    {
        NSString *identifier = note.object;
        ExtendedPDFViewController *controller;
        for (ExtendedPDFViewController *c in self.pdfViewControllers) {
            if ([c.model.pdfIdentifier isEqualToString:identifier]) {
                controller = c;
                break;
            }
        }
        if (controller) {
            [self.pdfViewControllers removeObject:controller];
        }
    }


    - (void)updateViewsAfterModelChange
    {
        DDLogVerbose(@"updateViewsAfterModelChange: model = %@, mainDocument = %@, windowController = %@", self.model, self.mainDocument, self.mainDocument.mainWindowController);
        _textViewController = [[TextViewController alloc] initWithFirstResponder:self];
        [self.mainDocument.mainWindowController addTabViewItemToFirst:self.textViewController.tabViewItem];
        NSError *error;
        NSString *content = [self.model loadContent:&error];
        if (!error) {
            self.textViewController.content = content;
            self.pdfViewControllers = [NSMutableSet new];
            for (DocumentModel *model in self.model.mainDocuments) {
                [self findOrCreatePDFViewControllerFor:model];
            }
        } else {
            [self closeDocument];
        }

    }

    - (void)showPDFViews
    {
        for (DocumentModel *model in self.model.mainDocuments) {
            BOOL containsController = NO;
            for (ExtendedPDFViewController *controller in self.pdfViewControllers) {
                if ([controller.model isEqualTo:model]) {
                    containsController = YES;
                    break;
                }
            }
            if (containsController) {
                continue;
            }
            [self findOrCreatePDFViewControllerFor:model];
        }
    }

    - (void)findOrCreatePDFViewControllerFor:(DocumentModel *)model
    {
        ExtendedPDFViewController *cont = [self findExistingPDFViewControllerFor:model];
        if (!cont) {
            cont = [[ExtendedPDFViewController alloc] init];
            cont.model = model;
            [cont setFirstResponderDelegate:self];
            [self.mainDocument.mainWindowController addTabViewItemToSecond:cont.tabViewItem];
        }
        NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:model.pdfIdentifier];
        if (item.tabView && item.tabView.window) {
            [item.tabView.window makeKeyAndOrderFront:nil];
        }
        [item.tabView selectTabViewItem:item];
        [self.pdfViewControllers addObject:cont];

    }

    - (ExtendedPDFViewController *)findExistingPDFViewControllerFor:(DocumentModel *)model
    {
        for (DocumentController *dc in self.mainDocument.documentControllers) {
            if ([dc isEqualTo:self]) {
                continue;
            }
            for (ExtendedPDFViewController *c in dc.pdfViewControllers) {
                if ([c.model isEqualTo:model]) {
                    return c;
                }
            }
        }
        return nil;
    }

    - (void)compile:(CompileMode)mode
    {
        switch (mode) {
            case live:
                [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(liveCompile:didSave:contextInfo:)];
                break;
            case draft:
                [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(liveCompile:didSave:contextInfo:)];
                break;
            case final:
                [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(finalCompile:didSave:contextInfo:)];
                break;
            default:
                break;
        }
    }

    - (void)draftCompile
    {
        [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(draftCompile:didSave:contextInfo:)];

    }

    - (void)draftCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context
    {
        if (self.model.texPath) {
            [self.compiler compile:draft];
        }
    }

    - (void)finalCompile
    {
        [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(finalCompile:didSave:contextInfo:)];

    }

    - (void)finalCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context
    {
        if (self.model.texPath) {
            [self.compiler compile:final];
        }
    }

    - (void)refreshLiveView
    {
        [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(liveCompile:didSave:contextInfo:)];

    }

    - (void)liveCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context
    {
        if (self.model.texPath) {
            [self.compiler compile:live];
        }
    }


#pragma mark - First Responder Delegate

    - (void)saveDocument:(id)sender
    {

        [self.mainDocument saveDocument:self];

    }

    - (void)liveCompile:(id)sender
    {
        [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(liveCompile:didSave:contextInfo:)];
    }

    - (void)draftCompile:(id)sender
    {
        [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(draftCompile:didSave:contextInfo:)];
    }

    - (void)finalCompile:(id)sender
    {
        [self.mainDocument finalCompileForDocumentController:self];
    }


    - (void)abort
    {
        [self.compiler abort];
    }

- (void)showInformation:(id)sender {
    
    if (!_modelInfoWindow) {
        _modelInfoWindow= [ModelInfoWindowController sharedInstance];
    }
    _modelInfoWindow.model = self.model;
    [_modelInfoWindow showWindow:self];
    
}

- (void)showProjectInformation:(id)sender {
    if (self.model.project) {
        if (!_modelInfoWindow) {
            _modelInfoWindow= [ModelInfoWindowController sharedInstance];
        }
        _modelInfoWindow.model = self.model.project;
        [_modelInfoWindow showWindow:self];
    } else {
        NSBeep();
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(showProjectInformation:)) {
        return self.model.project;
    } else {
        return [super respondsToSelector:aSelector];
    }
}

#pragma mark -
#pragma mark Dealloc

    - (void)dealloc
    {
        self.textViewController.firstResponderDelegate = nil;
        [self.compiler terminateAndKill];
        for (ExtendedPDFViewController *c in self.pdfViewControllers) {
            if ([c.pdfView.firstResponderDelegate isEqual:self]) {
                c.pdfView.firstResponderDelegate = NULL;
            }
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
@end
