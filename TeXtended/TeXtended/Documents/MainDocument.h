//
//  MainDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FirstResponderDelegate.h"

@class Compilable, MainWindowController, ExportCompileWindowController, DocumentController, DocumentModel, PrintDialogController, MergeWindowController, EncodingController, ShareDialogController, TemplateController;

@interface MainDocument : NSDocument <NSSharingServicePickerDelegate,NSSharingServiceDelegate> {
    ExportCompileWindowController *exportWindowController;
    PrintDialogController *printDialogController;
    MergeWindowController *mergeWindowController;
    ShareDialogController *shareDialogController;
    NSRecursiveLock *numberLock;
}
/** The controller of the documents main window */
@property (assign) MainWindowController *mainWindowController;

@property (strong) TemplateController *templateController;

/** A set of all document controllers of the project */
@property (strong) NSMutableSet *documentControllers;

@property (nonatomic) NSUInteger numberOfCompilingDocuments;

@property EncodingController *encController;

@property id<FirstResponderDelegate> currentDC;

- (void) saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action;
- (Compilable *) model;
- (void)initializeDocumentControllers;
- (void)finalCompileForDocumentController:(DocumentController *)dc;
- (void)showPrintDialog;
- (void)printDialogDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context;
- (void)printOperationDidRun:(NSPrintOperation *)printOperation  success:(BOOL)success  contextInfo:(void *)contextInfo;
- (void)shareDialogDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context;
- (void)openNewTabForCompilable:(DocumentModel*)model;
- (void)removeDocumentController:(DocumentController *)dc;
- (void)firstResponderDidChangeNotification:(NSNotification *)note;
- (IBAction)exportSingleDocument:(id)sender;

- (void)decrementNumberOfCompilingDocuments;
- (void)incrementNumberOfCompilingDocuments;
- (IBAction)saveAsTemplate:(id)sender;
- (IBAction)shareFile:(id)sender;
- (void)shareItems:(NSArray*)items;
@end
