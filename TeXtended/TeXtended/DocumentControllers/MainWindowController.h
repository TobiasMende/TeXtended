//
//  MainWindowController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowControllerProtocol.h"
@class DocumentController, FileOutlineView, FileViewController, ExportCompileWindowController, TMTSplitView;

/**
 The MainWindowController is the controller of the main window of each document. 
 
 Maybe there are more than one window per document later, but this controller is the most important one, holding references to some other controller like the DocumentController and others.
 
 **Author:** Tobias Mende
 
 */

@interface MainWindowController : NSWindowController<WindowControllerProtocol, NSSplitViewDelegate, NSWindowDelegate> {
}

/** Property holding the content view (e.g. the editor and pdf view) */
@property (weak) IBOutlet TMTSplitView *contentView;

/** Reference to the splitview control for controling the state of the splitviews subviews */
@property (weak) IBOutlet NSSegmentedControl *splitviewControl;

/** The main view containing the left and content view */
@property (weak) IBOutlet TMTSplitView *mainView;

/** The left sidebar containing the file view and an outline view */
@property (weak) IBOutlet NSSplitView *sidebar;

/** The subview of the sidebar */
@property (weak) IBOutlet NSSplitView *left;

/** The middle view containing editor and console in most cases */
@property (weak) IBOutlet NSSplitView *middle;

/** The right view containing the pdf view in most cases */
@property (weak) IBOutlet NSSplitView *right;

/** the DocumentController controlling the current DocumentModel */
@property (strong, nonatomic) DocumentController *documentController;

/** the FileViewController containing the file outline view */
@property (strong) FileViewController *fileViewController;

/** The controller controlling the export window */
@property (strong) ExportCompileWindowController* exportWindow;

/** The area in which to show the file view itself */
@property (weak) IBOutlet NSBox *fileViewArea;


/** Method for toggling the collapse state of a view which is determined by the senders tag. See TMTSplitView for further details 
 
 @param sender the sender
 */
- (IBAction)collapseView:(id)sender;

/** Action for opening the redmine ticket system in the default web browser 
 
 @param sender the sender
 */
- (IBAction)reportBug:(id)sender;

/** Action initiating the draft compile on the DocumentController 
 
 @param sender the sender
 */
- (IBAction)draftCompile:(id)sender;

/** Action initiating the final compile on the DocumentController 
 
 @param sender the sender
 */
- (IBAction)finalCompile:(id)sender;

/** Action initiating the live compile on the DocumentController 
 
 @param sender the sender
 */
- (IBAction)liveCompile:(id)sender;

/**
 A method for performing a general action which is determined by the sender in any instance. This method calls the method  with the same arguments.
 
 @warning This method is used to reduce the number of methods in the first responder. Use it only, if the action to perform is really clean and generate other action methods otherwise.
 
 @param sender the sender
 
 */
- (IBAction)genericAction:(id)sender;
@end
