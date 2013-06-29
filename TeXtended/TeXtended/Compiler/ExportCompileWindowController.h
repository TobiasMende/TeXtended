//
//  ExportCompileWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentController,DocumentModel, TMTTableView;
@interface ExportCompileWindowController : NSWindowController<NSOpenSavePanelDelegate> {
    NSSavePanel *pdfPathPanel;
    NSOpenPanel *texPathPanel;
}
@property (weak) IBOutlet NSButton *openCheckbox;
@property (weak) IBOutlet NSButton *bibCheckbox;
@property (weak) IBOutlet TMTTableView *selectionTable;
@property (weak) IBOutlet NSBox *selectionView;
@property (weak) IBOutlet NSBox *settingsView;
@property (weak) DocumentModel *model;
@property (weak) DocumentController* controller;
@property (weak) IBOutlet NSArrayController *mainDocumentsController;
-(id)initWithDocumentController:(DocumentController*) controller;
- (IBAction)export:(id)sender;
- (IBAction)exportPathDialog:(id)sender;
- (IBAction)removeMainDocument:(id)sender;
- (IBAction)addMainDocument:(id)sender;
- (BOOL) canRemoveEntry;
@end
