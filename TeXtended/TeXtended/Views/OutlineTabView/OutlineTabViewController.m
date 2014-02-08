//
//  OutlineTabViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "OutlineTabViewController.h"
#import "MessageOutlineViewContainerController.h"
#import "StructureOutlineViewController.h"
#import "MainWindowController.h"
#import "MainDocument.h"
#import "SMTabBarItem.h"
#import "DMPaletteContainer.h"
#import "SMTabBar.h"
#import <TMTHelperCollection/TMTLog.h>

@interface OutlineTabViewController ()

@end

@implementation OutlineTabViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (id)initWithMainWindowController:(MainWindowController *)mwc {
    self = [super initWithNibName:@"OutlineTabView" bundle:nil];
    if (self) {
        self.mainWindowController = mwc;
        
    }
    return self;
}

- (void)tabBar:(SMTabBar *)tabBar didSelectItem:(SMTabBarItem *)item {
    [self.tabView selectTabViewItemAtIndex:[self.tabBar.items indexOfObject:item]];
}

- (void)loadView {
    [super loadView];
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:2];
    {
        NSImage *image = [NSImage imageNamed:@"alert-circled"];
        [image setSize:NSMakeSize(16, 16)];
        [image setTemplate:YES];
        SMTabBarItem *item = [[SMTabBarItem alloc] initWithImage:image tag:0];
        item.toolTip = NSLocalizedString(@"Compiler Messages", nil);
        item.keyEquivalent = @"1";
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        [tabBarItems addObject:item];
    }
    {
        NSImage *image = [NSImage imageNamed:@"map"];
        [image setSize:NSMakeSize(16, 16)];
        [image setTemplate:YES];
        SMTabBarItem *item = [[SMTabBarItem alloc] initWithImage:image tag:1];
        item.toolTip = NSLocalizedString(@"Outline View", nil);
        item.keyEquivalent = @"2";
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        [tabBarItems addObject:item];
    }
    self.messageOutlineViewContainerController = [[MessageOutlineViewContainerController alloc] initWithMainWindowController:self.mainWindowController];
    self.structureOutlineViewController = [[StructureOutlineViewController alloc] initWithMainWindowController:self.mainWindowController];
    NSTabViewItem *messages = [NSTabViewItem new];
    messages.view = self.messageOutlineViewContainerController.view;
    [self.tabView addTabViewItem:messages];
    NSTabViewItem *outline = [NSTabViewItem new];
    outline.view = self.structureOutlineViewController.view;
    [self.tabView addTabViewItem:outline];
    self.tabBar.items = tabBarItems;
}

- (void)windowIsGoingToDie {
    [self.structureOutlineViewController windowIsGoingToDie];
}

@end
