//
//  MainWindow.h
//  TeXtended
//
//  Created by Tobias Mende on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController;
/**
 Subclass of a NSWindow handling some user actions and different behaviour.
 
 **Author:** Tobias Mende
 
 */
@interface MainWindow : NSWindow
/** Reference to the controller of this window */
@property (unsafe_unretained) IBOutlet MainWindowController *controller;

/** The genereic action method (see [MainWindowController genericAction:])
 
 @param sender the sender
 */
- (IBAction)genericAction:(id)sender;

/** The draft compile action
 
 @param sender the sender
 */
- (IBAction)draftCompile:(id)sender;

/** The final compile action
 
 @param sender the sender
 */
- (IBAction)export:(id)sender;
@end
