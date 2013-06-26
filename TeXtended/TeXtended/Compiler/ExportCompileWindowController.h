//
//  ExportCompileWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentController,DocumentModel;
@interface ExportCompileWindowController : NSWindowController
@property (weak) IBOutlet NSButton *bibCheckbox;
@property (weak) IBOutlet NSTableView *selectionTable;
@property (weak) IBOutlet NSBox *selectionView;
@property (weak) IBOutlet NSBox *settingsView;
@property (weak) DocumentModel *model;
@property (weak) DocumentController* controller;
@property (strong) IBOutlet NSArrayController *mainDocumentsController;
-(id)initWithDocumentController:(DocumentController*) controller;
- (IBAction)export:(id)sender;

@end
