//
//  MainWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DMSplitView.h"
#import "ViewControllerProtocol.h"
#import "FirstResponderDelegate.h"
@class DocumentController, FileViewController, TMTSplitView, DMSplitView, OutlineTabViewController, TMTTabViewController, MainDocument, TMTTabViewItem;

/**
 The MainWindowController is the controller of the main window of each document. 
 
 Maybe there are more than one window per document later, but this controller is the most important one, holding references to some other controller like the DocumentController and others.
 
 **Author:** Tobias Mende
 
 */

@interface MainWindowController : NSWindowController<NSWindowDelegate,DMSplitViewDelegate> {
}
@property (weak) id<FirstResponderDelegate> myCurrentFirstResponderDelegate;
@property TMTTabViewController *firsTabViewController;
@property TMTTabViewController *secondTabViewController;

@property (assign) MainDocument *mainDocument;

@property (strong) IBOutlet NSButton *sidebarViewToggle;
@property (strong) IBOutlet NSButton *secondViewToggle;

@property (strong) IBOutlet NSBox *fileViewArea;
@property (strong) IBOutlet NSBox *outlineViewArea;

/** The main view containing the left and content view */
@property (strong) IBOutlet DMSplitView *mainView;

/** The left sidebar containing the file view and an outline view */
@property (strong) IBOutlet DMSplitView *sidebar;

/** The content split view (editor + pdf) */
@property  (assign) IBOutlet DMSplitView *contentView;


@property IBOutlet OutlineTabViewController* outlineController;

/** the FileViewController containing the file outline view */
@property  FileViewController *fileViewController;


/** Action for opening the redmine ticket system in the default web browser 
 
 @param sender the sender
 */
- (IBAction)reportBug:(id)sender;

- (IBAction)toggleSidebarView:(id)sender;
- (IBAction)toggleSecondView:(id)sender;

- (id)initForDocument:(MainDocument*)document;

- (void) showDocument:(DocumentController *)dc;
- (void) addTabViewItemToFirst:(TMTTabViewItem *)item;
- (void) addTabViewItemToSecond:(TMTTabViewItem *)item;

@end
