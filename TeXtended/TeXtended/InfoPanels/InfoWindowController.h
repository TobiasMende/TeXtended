//
//  InfoWindowController.h
//  TeXtended
//
//  Created by Tobias Hecht on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentModel,CompileFlowHandler,Compilable;

/**
 This view controller handles the InfoWindow and other important objects connected to it.
 
 It is the data source of the Maindocuments table within the InfoWindow.
 
 **Author:** Tobias Hecht
 
 */

@interface InfoWindowController : NSWindowController <NSTableViewDataSource> {
    NSMutableArray *texDocs;
    
    NSOpenPanel *texPathPanel;
}

/** Tableview displaying the Maindocuments */
@property (weak) IBOutlet NSTableView *table;
/** Documentmodel which is displayed */
@property (weak, nonatomic) DocumentModel* doc;
/** Label for the Document- or Projectname */
@property (weak) IBOutlet NSTextField *lblName;
/** Label for the documentmodel type (Project/Document) */
@property (weak) IBOutlet NSTextField *lblType;
/** Label for the date of last compile */
@property (weak) IBOutlet NSTextField *lblCompile;
/** Label for the date of last change */
@property (weak) IBOutlet NSTextField *lblChange;
/** Label for the documentpath */
@property (weak) IBOutlet NSTextField *lblPath;
/** Textfield for the number of iterations of draft compiler */
@property (weak) IBOutlet NSTextField *DraftIt;
/** Textfield for the number of iterations of live compiler */
@property (weak) IBOutlet NSTextField *LiveIt;
/** Textfield for the number of iterations of final compiler */
@property (weak) IBOutlet NSTextField *FinalIt;
/** Compileflowhandler for the iterationslimits */
@property (weak) IBOutlet CompileFlowHandler *CompilerFlowHandlerObj;
/** Button to add maindocuments */
@property (weak) IBOutlet NSButton *addButton;
/** Button to remove maindocuments */
@property (weak) IBOutlet NSButton *removeButton;
/** */
@property (weak) IBOutlet NSArrayController *mainDocumentsController;
/** Name of the Document */
@property (weak) NSString* documentName;
/** Type of the Document */
@property (weak) NSString* documentType;
/** Path of the Document */
@property (weak) NSString* documentPath;

/** Method for catching clicks on the addButton
 @param sender is the sender
 */
- (IBAction)addMainDocument:(id)sender;

/** Method for catching clicks on the removeButton
 @param sender is the sender
 */
- (IBAction)removeMainDocument:(id)sender;

/**
 
 return
 */
- (BOOL) canRemoveEntry;
@end
