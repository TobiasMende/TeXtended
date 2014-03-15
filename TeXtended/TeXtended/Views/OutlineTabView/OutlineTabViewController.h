//
//  OutlineTabViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController, MessageOutlineViewContainerController, SMTabBar, SMTabBarItem, StructureOutlineViewController;
@interface OutlineTabViewController : NSViewController
@property (assign) MainWindowController* mainWindowController;

@property MessageOutlineViewContainerController* messageOutlineViewContainerController;
@property StructureOutlineViewController *structureOutlineViewController;
@property (strong) IBOutlet SMTabBar *tabBar;
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSPopUpButton *selectionPopup;

- (id)initWithMainWindowController:(MainWindowController*) mwc;
- (void)tabBar:(SMTabBar *)tabBar didSelectItem:(SMTabBarItem *)item;
- (void)windowIsGoingToDie;
@end
