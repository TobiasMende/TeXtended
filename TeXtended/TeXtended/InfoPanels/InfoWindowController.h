//
//  InfoWindowController.h
//  TeXtended
//
//  Created by Tobias Hecht on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DocumentModel,CompileFlowHandler,Compilable,EncodingController;

/**
 This view controller handles the InfoWindow and other important objects connected to it.
 
 It is the data source of the Maindocuments table within the InfoWindow.
 
 **Author:** Tobias Hecht
 
 */

@interface InfoWindowController : NSWindowController <NSTableViewDataSource, NSWindowDelegate> {
    NSMutableArray *texDocs;
    
    NSOpenPanel *texPathPanel;
    
    NSArray *encodings;
}


/** Tableview displaying the Maindocuments */
@property (assign) IBOutlet NSTableView *table;
/** Model which is displayed */
@property (strong, nonatomic) Compilable* compilable;
/** Label for the Document- or Projectname */
@property (assign) IBOutlet NSTextField *lblName;
/** Label for the documentmodel type (Project/Document) */
@property (assign) IBOutlet NSTextField *lblType;
/** Label for the date of last compile */
@property (assign) IBOutlet NSTextField *lblCompile;
/** Label for the date of last change */
@property (assign) IBOutlet NSTextField *lblChange;
/** Label for the documentpath */
@property (assign) IBOutlet NSTextField *lblPath;
/** Textfield for the number of iterations of draft compiler */
@property (assign) IBOutlet NSTextField *DraftIt;
/** Textfield for the number of iterations of live compiler */
@property (assign) IBOutlet NSTextField *LiveIt;
/** Textfield for the number of iterations of final compiler */
@property (assign) IBOutlet NSTextField *FinalIt;
/** Compileflowhandler for the iterationslimits */
@property (assign) IBOutlet CompileFlowHandler *CompilerFlowHandlerObj;
/** Button to add maindocuments */
@property (assign) IBOutlet NSButton *addButton;
/** Button to remove maindocuments */
@property (assign) IBOutlet NSButton *removeButton;
/** */
@property (assign) IBOutlet NSArrayController *mainDocumentsController;
/** Name of the Document */
@property (assign) NSString* documentName;
/** Type of the Document */
@property (assign) NSString* documentType;
/** Path of the Document */
@property (assign) NSString* documentPath;

@property IBOutlet NSPopUpButton* encodingPopUp;

/** Method for catching clicks on the addButton
 @param sender is the sender
 */
- (IBAction)addMainDocument:(id)sender;

/** Method for catching clicks on the removeButton
 @param sender is the sender
 */
- (IBAction)removeMainDocument:(id)sender;

- (IBAction)encodingSelectionChange:(id)sender;

/**
 
 return
 */
- (BOOL) canRemoveEntry;
@end
