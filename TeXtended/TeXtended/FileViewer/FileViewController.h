//
//  OutlineViewStaticAppDeligate.h
//  Sandbox
//
//  Created by Tobias Hecht on 16.04.13.
//  Copyright (c) 2013 Tobias Hecht. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DocumentModel, FileViewModel, InfoWindowController, DocumentController, PathObserver, Compilable, MainDocument;

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
    
    /** Outlioneview to display the fileviewmodel */
    __weak IBOutlet NSOutlineView *outline;
    
    __weak IBOutlet NSButton *infoLoadButton;
}

/** Model which is displayed */
@property (assign,nonatomic) Compilable* compilable;

@property MainDocument* mainDocument;

/** Controller for inforview */
@property InfoWindowController *infoWindowController;

/** Method for catching double clicks on outlineview
 @param sender is the sender
 */
- (IBAction)doubleClick:(id)sender;


/** Method to work with the notification handler after compiling
 */
- (void)updateFileViewModel;


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

/** Method for catching clicks on rename project in contextmenu
 @param sender is the sender
 */
- (IBAction)renameProject:(id)sender;

/** Method for catching clicks on close project in contextmenu
 @param sender is the sender
 */
- (IBAction)closeProject:(id)sender;

/** Method for catching clicks on open in contextmenu
 @param sender is the sender
 */
- (IBAction)openFile:(id)sender;

/** Method for catching clicks on information in contextmenu of fileview
 @param sender is the sender
 */
- (IBAction)openInfoViewForFile:(id)sender;

/** Method for catching clicks on information in contextmenu of item in fileview
 @param sender is the sender
 */
- (IBAction)showInformationForFile:(id)sender;
@end