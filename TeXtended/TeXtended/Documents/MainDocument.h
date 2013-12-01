//
//  MainDocument.h
//  TeXtended
//
//  Created by Tobias Mende on 02.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Compilable, MainWindowController, ExportCompileWindowController, DocumentController, StatsPanelController, DocumentModel;

@interface MainDocument : NSDocument {
    ExportCompileWindowController *exportWindowController;
    StatsPanelController *statisticPanelController;
}
/** The controller of the documents main window */
@property (weak) MainWindowController *mainWindowController;

/** A set of all document controllers of the project */
@property (strong) NSMutableSet *documentControllers;

- (void) saveEntireDocumentWithDelegate:(id)delegate andSelector:(SEL)action;
- (Compilable *) model;
- (void)initializeDocumentControllers;
- (void)finalCompileForDocumentController:(DocumentController *)dc;
- (void)showStatisticsForModel:(DocumentController *)dc;
- (void)openNewTabForCompilable:(DocumentModel*)model;
@end
