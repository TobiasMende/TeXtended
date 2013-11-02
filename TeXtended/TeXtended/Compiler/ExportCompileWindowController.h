//
//  ExportCompileWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentController,DocumentModel, TMTTableView, MainDocument;

/*
 * Controller for the export window.
 * 
 * @author Max Bananch
 */
@interface ExportCompileWindowController : NSWindowController<NSOpenSavePanelDelegate, NSWindowDelegate> {
    NSSavePanel *pdfPathPanel;
    NSOpenPanel *texPathPanel;
}

/** ´YES´ if the PDFs should be opend (by a extern editor) after the export. */
@property (assign) IBOutlet NSButton *openCheckbox;

/** ´YES´ fi bibtex should be used. */
@property (assign) IBOutlet NSButton *bibCheckbox;

/** Selected TableView in the tabke. */
@property (assign) IBOutlet TMTTableView *selectionTable;

/** Box arround the selection views. */
@property (assign) IBOutlet NSBox *selectionView;

/** Box arround the settings views. */
@property (assign) IBOutlet NSBox *settingsView;

/** The DocomentModel for which the export is called. */
@property (strong) DocumentModel *model;

@property (weak, nonatomic) DocumentController* documentController;

/** Controller for the MainDocuments of the given DocumentController. */
@property (assign) IBOutlet NSArrayController *mainDocumentsController;

@property (weak) MainDocument *mainDocument;

- (id)initWithMainDocument:(MainDocument*)mainDocument;

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

- (void) export:(id)sender;
@end
