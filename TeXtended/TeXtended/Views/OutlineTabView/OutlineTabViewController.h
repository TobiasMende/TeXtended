//
//  OutlineTabViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController, SMTabBar, SMTabBarItem;
@interface OutlineTabViewController : NSViewController
@property (assign) MainWindowController* mainWindowController;
@property NSViewController *currentViewController;
@property (strong) IBOutlet SMTabBar *tabBar;
@property (strong) IBOutlet NSBox *contentView;

@property (strong) IBOutlet NSPopUpButton *selectionPopup;

@property (nonatomic) NSInteger selectedItem;

- (id)initWithMainWindowController:(MainWindowController*) mwc;
- (void)tabBar:(SMTabBar *)tabBar didSelectItem:(SMTabBarItem *)item;
- (void)windowIsGoingToDie;
@end
