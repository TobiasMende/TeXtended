//
//  MainDocument.m
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainDocument.h"
#import "DocumentController.h"
#import "MainWindowController.h"
#import "ExportCompileWindowController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "TMTTabManager.h"
#import "PrintDialogController.h"
#import "EncodingController.h"
#import "ShareDialogController.h"
#import "TemplateController.h"

@interface MainDocument ()

    - (void)firstResponderDidChangeNotification:(NSNotification *)note;
@end

@implementation MainDocument

    - (id)init
    {
        self = [super init];
        if (self) {
            self.encController = [EncodingController new];
            numberLock = [NSRecursiveLock new];
        }
        return self;
    }


    - (void)windowControllerDidLoadNib:(NSWindowController *)windowController
    {
        [super windowControllerDidLoadNib:windowController];
        if ([windowController isKindOfClass:[MainWindowController class]]) {
            self.currentDC = self.documentControllers.anyObject;
            for (DocumentController *dc in self.documentControllers) {
                [dc loadViews];
            }
        }


    }

    - (void)setNumberOfCompilingDocuments:(NSUInteger)numberOfCompilingDocuments
    {
        [numberLock lock];
        _numberOfCompilingDocuments = numberOfCompilingDocuments;
        [numberLock unlock];
    }


    - (void)decrementNumberOfCompilingDocuments
    {
        [numberLock lock];
        self.numberOfCompilingDocuments--;
        [numberLock unlock];
    }

    - (void)incrementNumberOfCompilingDocuments
    {
        [numberLock lock];
        self.numberOfCompilingDocuments++;
        [numberLock unlock];
    }


    - (void)saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }

    - (void)saveAsTemplate:(id)sender
    {
        self.templateController = [TemplateController new];

    }

    - (Compilable *)model
    {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                     userInfo:nil];
    }

    - (void)firstResponderDidChangeNotification:(NSNotification *)note
    {

        id <FirstResponderDelegate> delegate = note.userInfo[TMTFirstResponderKey];

        self.currentDC = delegate;
        if (note.userInfo[TMTNotificationSourceWindowKey]) {
            [self addWindowController:[note.userInfo[TMTNotificationSourceWindowKey] windowController]];
        }
    }

    + (BOOL)autosavesInPlace
    {
        return YES;

    }


    - (void)initializeDocumentControllers
    {
        DDLogVerbose(@"initializeDocumentControllers (Count: %li)", self.model.mainDocuments.count);
        self.documentControllers = [NSMutableSet new];
        for (DocumentModel *m in self.model.openDocuments) {
            [self.documentControllers addObject:[[DocumentController alloc] initWithDocument:m andMainDocument:self]];
        }
    }

    - (void)removeDocumentController:(DocumentController *)dc
    {
        [self.documentControllers removeObject:dc];
        if (self.documentControllers.count == 0) {
            [self close];
        }
    }


    - (void)makeWindowControllers
    {
        DDLogVerbose(@"makeWindowControllers");
        MainWindowController *mc = [[MainWindowController alloc] initForDocument:self];
        self.mainWindowController = mc;
        [self initializeDocumentControllers];
        [self addWindowController:mc];

    }

    - (void)finalCompileForDocumentController:(DocumentController *)dc
    {
        if (!exportWindowController) {
            exportWindowController = [[ExportCompileWindowController alloc] initWithMainDocument:self];
        }
        exportWindowController.documentController = dc;
        [exportWindowController showWindow:nil];
    }

    - (IBAction)shareFile:(id)sender
    {
        NSMutableArray *documentPaths = [[NSMutableArray alloc] init];

        for (DocumentController *dc in self.documentControllers) {
            if (dc.model.pdfName) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:dc.model.pdfPath]) {
                    [documentPaths addObject:dc.model.pdfPath];
                }
            }
        }

        if ([documentPaths count] == 0) {
            return;
        }

        if ([documentPaths count] == 1) {
            NSArray *fileURLs = [NSArray arrayWithObject:[[NSURL alloc] initFileURLWithPath:[documentPaths objectAtIndex:0]]];

            [self shareItems:fileURLs];
        }
        else if ([documentPaths count] > 1) {
            if (!shareDialogController) {
                shareDialogController = [[ShareDialogController alloc] init];
            }
            shareDialogController.content = documentPaths;
            [NSApp beginSheet:[shareDialogController window]
               modalForWindow:[self.mainWindowController window]
                modalDelegate:self
               didEndSelector:@selector(shareDialogDidEnd:returnCode:contextInfo:)
                  contextInfo:nil];
            [NSApp runModalForWindow:[self.mainWindowController window]];
        }
    }

    - (void)shareDialogDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context
    {
        NSArray *items = shareDialogController.choice;
        if ([items count] > 0) {
            [self shareItems:items];
        }
    }

    - (void)shareItems:(NSArray *)items
    {
        if (items.count == 0) {
            return;
        }
        NSSharingServicePicker *sharingServicePicker = [[NSSharingServicePicker alloc] initWithItems:items];
        sharingServicePicker.delegate = self;

        if (items.count > 1) {
            [sharingServicePicker showRelativeToRect:shareDialogController.okButton.bounds
                                              ofView:shareDialogController.okButton
                                       preferredEdge:NSMinYEdge];
        }
        else if (items.count == 1) {
            [sharingServicePicker showRelativeToRect:self.mainWindowController.shareButton.bounds
                                              ofView:self.mainWindowController.shareButton
                                       preferredEdge:NSMinYEdge];
        }
    }

    - (IBAction)exportSingleDocument:(id)sender
    {
        [NSException raise:@"exportSingleDocument not implemented." format:@"Yout have to implement exportSingleDocument in subclasses of MainDocument."];
    }


    - (BOOL)respondsToSelector:(SEL)aSelector
    {
        if (aSelector == @selector(exportSingleDocument:)) {
            return self.fileURL != nil;
        } else {
            return [super respondsToSelector:aSelector];
        }
    }

    - (void)openNewTabForCompilable:(DocumentModel *)model
    {
        for (DocumentController *dc in self.documentControllers) {
            if (dc.model == model) {
                NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:model.texIdentifier];
                if (item) {
                    [item.tabView.window makeKeyAndOrderFront:self];
                    [item.tabView selectTabViewItem:item];
                }
                [dc showPDFViews];
                self.currentDC = dc;
                return;
            }
        }

        DocumentController *dc = [[DocumentController alloc] initWithDocument:model andMainDocument:self];
        [self.documentControllers addObject:dc];
        self.currentDC = dc;
        [dc loadViews];
        NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:model.texIdentifier];
        [item.tabView selectTabViewItem:item];
        [item.tabView.window makeFirstResponder:item.view];
    }



#pragma mark - Printing
    - (void)printDocument:(id)sender
    {
        [self showPrintDialog];
    }

    - (void)showPrintDialog
    {
        if (!printDialogController) {
            printDialogController = [PrintDialogController new];
        }

        NSMutableArray *documentNames = [[NSMutableArray alloc] init];
        NSMutableArray *documentIdentifier = [[NSMutableArray alloc] init];
        for (DocumentController *dc in self.documentControllers) {
            if (dc.model.pdfName) {
                [documentNames addObject:dc.model.pdfName];
                [documentIdentifier addObject:dc.model.pdfIdentifier];
            }
            if (dc.model.texName) {
                [documentNames addObject:dc.model.texName];
                [documentIdentifier addObject:dc.model.texIdentifier];
            }
        }
        printDialogController.popUpElements = [NSArray arrayWithArray:documentNames];
        printDialogController.popUpIdentifier = [NSArray arrayWithArray:documentIdentifier];

        [NSApp beginSheet:[printDialogController window]
           modalForWindow:[self.mainWindowController window]
            modalDelegate:self
           didEndSelector:@selector(printDialogDidEnd:returnCode:contextInfo:)
              contextInfo:nil];
        [NSApp runModalForWindow:[self.mainWindowController window]];
    }

    - (void)printDialogDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context
    {
        if (returnCode != NSRunAbortedResponse) {
            NSString *identifier = [printDialogController.popUpIdentifier objectAtIndex:printDialogController.documentName.indexOfSelectedItem];
            BOOL isPDF = [[identifier substringFromIndex:identifier.length - 4] isEqualToString:@"-pdf"];

            if (isPDF) {
                NSTabViewItem *item = [[TMTTabManager sharedTabManager] tabViewItemForIdentifier:identifier];
                [item.tabView selectTabViewItem:item];
                [[item view] printDocument:nil];
            }
            else {
                for (DocumentController *dc in self.documentControllers) {
                    if (dc.model.texIdentifier == identifier) {
                        NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 468, 648)];


                        NSString *text = [NSString stringWithContentsOfFile:dc.model.texPath encoding:[dc.model.encoding unsignedLongValue] error:nil];

                        [textView setEditable:true];
                        [textView insertText:text];

                        NSPrintOperation *printOperation;

                        printOperation = [NSPrintOperation printOperationWithView:textView];

                        [printOperation runOperation];

                    }
                }
            }
        }
    }

    - (void)printOperationDidRun:(NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(void *)contextInfo
    {
        // Nothing to do here...
    }

#pragma mark -

    - (void)dealloc
    {
        for (DocumentController *dc in [self.documentControllers copy]) {
            [dc closeDocument];
        }
    }

@end
