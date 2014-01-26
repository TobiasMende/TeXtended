//
//  OutlineTabViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController, MessageOutlineViewController, SMTabBar, SMTabBarItem, StructureOutlineViewController;
@interface OutlineTabViewController : NSViewController
@property (assign) MainWindowController* mainWindowController;

@property MessageOutlineViewController* messageOutlineViewController;
@property StructureOutlineViewController *structureOutlineViewController;
@property (strong) IBOutlet SMTabBar *tabBar;
@property (strong) IBOutlet NSTabView *tabView;

- (id)initWithMainWindowController:(MainWindowController*) mwc;
- (void)tabBar:(SMTabBar *)tabBar didSelectItem:(SMTabBarItem *)item;
@end
