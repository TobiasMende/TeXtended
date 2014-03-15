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

@property (weak) NSPopUpButton* selectionPopup;
@property (strong) IBOutlet NSTabView *mainView;
@property (assign) MainWindowController *mainWindowController;
@property (nonatomic) NSInteger selectedIndex;

- (id)initWithMainWindowController:(MainWindowController *)mwc andPopUpButton:(NSPopUpButton*) button;
- (void)windowIsGoingToDie;
@end
