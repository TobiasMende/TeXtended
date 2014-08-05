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
#import "ProjectModel.h"
#import "ModelInfoWindowController.h"

@interface DocumentController ()

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
            _model = model;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(texViewDidClose:) name:TMTTabViewDidCloseNotification object:self.model.texIdentifier];
            for (DocumentModel *m in self.model.mainDocuments) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pdfViewDidClose:) name:TMTTabViewDidCloseNotification object:m.pdfIdentifier];
            }
            self.model.documentOpened = YES;
            self.consoleViewControllers = [NSMutableSet new];
            self.compiler = [[Compiler alloc] initWithCompileProcessHandler:self];
            _textViewController = [[TextViewController alloc] initWithFirstResponder:self andModel:self.model];
            [self.textViewController addObserver:self.compiler];
        }
        return self;
    }


    - (BOOL)saveDocumentModel:(NSError * __autoreleasing *)outError
    {
        TMT_TRACE
        self.model.selectedRange =self.textViewController.textView.selectedRange;
        if (!self.textViewController.dirty) {
            return YES;
        }
        BOOL success = [self.model saveContent:[self.textViewController content] error:outError];
        
        if (success) {
            self.textViewController.dirty = NO;
        }
        return success;
    }


    - (void)breakUndoCoalescing
    {
        TMT_TRACE
        [self.textViewController breakUndoCoalescing];
    }


    - (void)texViewDidClose:(NSNotification *)note
    {
        self.model.documentOpened = NO;
        [self.mainDocument removeDocumentController:self];
    }

    - (void)closeDocument
    {
        self.model.documentOpened = NO;
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


    - (void)loadViews {
        [self.textViewController loadView];
    }

    - (void)textViewControllerDidLoadView:(TextViewController *)controller
    {
        DDLogVerbose(@"updateViewsAfterModelChange: model = %@, mainDocument = %@, windowController = %@", self.model, self.mainDocument, self.mainDocument.mainWindowController);
        
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
            [[NSAlert alertWithError:error] runModal];
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
        TMT_TRACE
        [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(draftCompile:didSave:contextInfo:)];

    }

    - (void)draftCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context
    {
        TMT_TRACE
        if (self.model.texPath) {
            [self.compiler compile:draft];
        }
    }

    - (void)finalCompile
    {
        TMT_TRACE
        [self.mainDocument saveEntireDocumentWithDelegate:self andSelector:@selector(finalCompile:didSave:contextInfo:)];

    }

    - (void)finalCompile:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void *)context
    {
        TMT_TRACE
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
        TMT_TRACE
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
    
    if (!modelInfoWindow) {
        modelInfoWindow= [ModelInfoWindowController sharedInstance];
    }
    modelInfoWindow.model = self.model;
    [modelInfoWindow showWindow:self];
    
}

- (void)showProjectInformation:(id)sender {
    if (self.model.project) {
        if (!modelInfoWindow) {
            modelInfoWindow= [ModelInfoWindowController sharedInstance];
        }
        modelInfoWindow.model = self.model.project;
        [modelInfoWindow showWindow:self];
    } else {
        NSBeep();
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(showProjectInformation:)) {
        return self.model.project != nil;
    } else {
        return [super respondsToSelector:aSelector];
    }
}

#pragma mark -
#pragma mark Dealloc

    - (void)dealloc
    {
        DDLogVerbose(@"dealloc [%@]", self.model.texPath);
        [self.textViewController firstResponderIsDeallocating];
        [self.compiler terminateAndKill];
        for (ExtendedPDFViewController *c in self.pdfViewControllers) {
            if ([c.pdfView.firstResponderDelegate isEqual:self]) {
                c.pdfView.firstResponderDelegate = NULL;
            }
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
@end
