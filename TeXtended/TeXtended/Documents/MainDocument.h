//
//  MainDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Compilable, MainWindowController, ExportCompileWindowController, DocumentController, StatsPanelController, DocumentModel, PrintDialogController;

@interface MainDocument : NSDocument {
    ExportCompileWindowController *exportWindowController;
    StatsPanelController *statisticPanelController;
    PrintDialogController *printDialogController;
}
/** The controller of the documents main window */
@property (assign) MainWindowController *mainWindowController;

/** A set of all document controllers of the project */
@property (strong) NSMutableSet *documentControllers;

@property NSUInteger numberOfCompilingDocuments;

- (void) saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action;
- (Compilable *) model;
- (void)initializeDocumentControllers;
- (void)finalCompileForDocumentController:(DocumentController *)dc;
- (void)showStatisticsForModel:(DocumentController *)dc;
- (void)showPrintDialog;
- (void)printDialogDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context;
- (void)openNewTabForCompilable:(DocumentModel*)model;
- (void)removeDocumentController:(DocumentController *)dc;
- (void)firstResponderDidChangeNotification:(NSNotification *)note;
@end
