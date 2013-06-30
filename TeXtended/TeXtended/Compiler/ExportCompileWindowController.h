//
//  ExportCompileWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentController,DocumentModel, TMTTableView;

/*
 * Controller for the export window.
 * 
 * @author Max Bananch
 */
@interface ExportCompileWindowController : NSWindowController<NSOpenSavePanelDelegate> {
    NSSavePanel *pdfPathPanel;
    NSOpenPanel *texPathPanel;
}

/** ´YES´ if the PDFs should be opend (by a extern editor) after the export. */
@property (weak) IBOutlet NSButton *openCheckbox;

/** ´YES´ fi bibtex should be used. */
@property (weak) IBOutlet NSButton *bibCheckbox;

/** Selected TableView in the tabke. */
@property (weak) IBOutlet TMTTableView *selectionTable;

/** Box arround the selection views. */
@property (weak) IBOutlet NSBox *selectionView;

/** Box arround the settings views. */
@property (weak) IBOutlet NSBox *settingsView;

/** The DocomentModel for which the export is called. */
@property (weak) DocumentModel *model;

/** The DocumentController for which the export is called. */
@property (weak) DocumentController* controller;

/** Controller for the MainDocuments of the given DocumentController. */
@property (weak) IBOutlet NSArrayController *mainDocumentsController;

/** Init with a DocumentController which should be exported. */
-(id)initWithDocumentController:(DocumentController*) controller;

/**
 * Start the exporting.
 * @param sender
 */
- (IBAction)export:(id)sender;

/** 
 * Open a dialog to change the export path.
 * @param sender
 */
- (IBAction)exportPathDialog:(id)sender;

/**
 * Remove a main document from the maindocument list.
 * @param sender
 */
- (IBAction)removeMainDocument:(id)sender;

/**
 * Add a main document from the maindocument list.
 * @param sender
 */
- (IBAction)addMainDocument:(id)sender;

/**
 * Test is another maindocument can be removed from the maindocuments list.
 * @yes ´YES´ is a maindocument can be removed.
 */
- (BOOL) canRemoveEntry;
@end
