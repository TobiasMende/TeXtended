//
//  MessageOutlineViewContainer.h
//  TeXtended
//
//  Created by Max Bannach on 08.02.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainWindowController;
@interface MessageOutlineViewContainerController : NSViewController {
    NSMutableArray *messages;
    NSString *mainDocument;
}

@property (strong) IBOutlet NSPopUpButton *selectionPopup;
@property (strong) IBOutlet NSTabView *mainView;
@property (assign) MainWindowController *mainWindowController;

- (id)initWithMainWindowController:(MainWindowController *)mwc;
@end
