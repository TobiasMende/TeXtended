//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel, FileViewModel, InfoWindowController, DocumentController, PathObserver;

@interface FileViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource, NSTextDelegate> {
    
    /** Rootnode for the fileviewmodel */
    FileViewModel *nodes;
    
    /** Items to drop within fileview */
    NSArray* draggedItems;
    
    /** Observer to catch changes in folder */
    __weak PathObserver *observer;
    
    /** Outlioneview to display the fileviewmidel */
    __weak IBOutlet NSOutlineView *outline;
    
    /** Flag to keep if the document is saved */
    BOOL initialized;
}

/** Documentmodel which is displayed */
@property (weak) DocumentModel* doc;

/** Controller for inforview */
@property InfoWindowController *infoWindowController;

/** Method for catching double clicks on outlineview
 @param sender is the sender
 */
- (void)doubleClick:(id)sender;

/**Method for loading a document to display
 @param document is the document to display
 */
- (void)loadDocument:(DocumentModel*)document;

/** Method to work with the notification handler after compiling
 @param sender is the sender
 */
- (void)updateFileViewModel:(id)sender;

/** Method for catching clicks on titlebutton
 @param sender is the sender
 */
- (IBAction)openInfoView:(id)sender;

/** Method for catching clicks on open folder in contextmenu
 @param sender is the sender
 */
- (IBAction)openFolderinFinder:(id)sender;

/** Method for catching clicks on new file in contextmenu
 @param sender is the sender
 */
- (IBAction)newFile:(id)sender;

/** Method for catching clicks on new folder in contextmenu
 @param sender is the sender
 */
- (IBAction)newFolder:(id)sender;

/** Method for catching clicks on duplicate file in contextmenu
 @param sender is the sender
 */
- (IBAction)duplicate:(id)sender;

/** Method for catching clicks on rename file in contextmenu
 @param sender is the sender
 */
- (IBAction)renameFile:(id)sender;

/** Method for catching clicks on delete file in contextmenu
 @param sender is the sender
 */
- (IBAction)deleteFile:(id)sender;

/** Button to display infoview */
@property (weak) IBOutlet NSButton *titleButton;
@end