//
//  StructureOutlineViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController;
@interface StructureOutlineViewController : NSViewController {
    NSMutableArray *sections;
}
@property (strong) IBOutlet NSPopUpButton *selectionPopup;
@property (strong) IBOutlet NSTabView *mainView;
@property NSUInteger selectedIndex;
@property (assign) MainWindowController *mainWindowController;

- (id)initWithMainWindowController:(MainWindowController *)mwc;
@end
