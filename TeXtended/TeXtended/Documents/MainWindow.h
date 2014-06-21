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
@interface MainWindow : NSWindow <NSToolbarDelegate>

/** Reference to the controller of this window */
    @property (assign) IBOutlet MainWindowController *controller;

@end
