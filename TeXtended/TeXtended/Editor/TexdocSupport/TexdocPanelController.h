//
//  TexdocPanelController.h
//  TeXtended
//
//  Created by Tobias Mende on 12.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TexdocHandlerProtocol.h"

@class TexdocViewController;

/**
 The TexdocPanelController handles the panel in which the users can search for arbitrary package names and which show a couple of results to the user.
 
 **Author:** Tobias Mende
 
 */
@interface TexdocPanelController : NSWindowController<NSTextFieldDelegate,TexdocHandlerProtocol>

/** The content box of the panel */
@property (assign) IBOutlet NSBox *contentBox;

/** The main view of the panel */
@property (assign) IBOutlet NSView *view;

/** The field in which to enter the package name */
@property (assign) IBOutlet NSTextField *packageField;

/** The TexdocViewController controlling the results and the according view */
@property (strong) IBOutlet TexdocViewController *texdocViewController;

/** The search panel for starting a request */
@property (assign) IBOutlet NSView *searchPanel;

/** If `YES` the task is searching for results. */
@property BOOL searching;

/** Method for starting the texdoc search
 
 @param sender the sender
 */
- (IBAction)startTexdoc:(id)sender;

/** Method for clearing the results and starting a new search
 
 @param sender the sender
 */
- (IBAction)clearSearch:(id)sender;

/** Outlet to the clear button */
@property (assign) IBOutlet NSButton *clearButton;

/** Outlet to the search button */
@property (assign) IBOutlet NSButton *searchButton;


@end
