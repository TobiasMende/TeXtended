//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel, FileViewModel, InfoWindowController, DocumentController, PathObserver, Compilable;

/**
 This view controller handles the FileView and other important objects connected to it.
 
 It is the data source and the delegate of the FileOutlineView within the FileView.
 
 **Author:** Tobias Hecht
 
 */

@interface FileViewController : NSViewController <NSOutlineViewDelegate, NSOutlineViewDataSource, NSTextDelegate> {
    
    /** Rootnode for the fileviewmodel */
    FileViewModel *nodes;
    
    /** Items to drop within fileview */
    NSArray* draggedItems;
    
    /** Observer to catch changes in folder */
    __weak PathObserver *observer;
    
    /** Outlioneview to display the fileviewmidel */
    IBOutlet NSOutlineView *outline;
    
    /** Flag to keep if the document is saved */
    BOOL initialized;
}

/** Documentmodel which is displayed */
@property (weak, nonatomic) DocumentModel* document;

@property (nonatomic) Compilable *mainCompilabel;

/** Controller for inforview */
@property InfoWindowController *infoWindowController;

/** Method for catching double clicks on outlineview
 @param sender is the sender
 */
- (IBAction)doubleClick:(id)sender;


/** Method to work with the notification handler after compiling
 */
- (void)updateFileViewModel;

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
@end