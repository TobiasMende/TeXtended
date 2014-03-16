//
//  OutlineTabViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "OutlineTabViewController.h"
#import "MainWindowController.h"
#import "MainDocument.h"
#import "SMTabBarItem.h"
#import "DMPaletteContainer.h"
#import "SMTabBar.h"
#import "MessageOutlineViewController.h"
#import "StructureOutlineViewController.h"
#import <TMTHelperCollection/TMTLog.h>

static const NSUInteger MESSAGE_TAB_TAG = 0;
static const NSUInteger OUTLINE_TAB_TAG = 1;

@interface OutlineTabViewController ()
- (void)updateViewForTab:(NSUInteger)tag andSelectedItem:(NSUInteger)item;
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
        
        [self.mainWindowController addObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior context:NULL];
    }
    return self;
}

- (void)tabBar:(SMTabBar *)tabBar didSelectItem:(SMTabBarItem *)item {
    [self updateViewForTab:item.tag andSelectedItem:self.selectedItem];
}

- (void)loadView {
    [super loadView];
    NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:2];
    {
        NSImage *image = [NSImage imageNamed:@"alert-circled"];
        [image setSize:NSMakeSize(16, 16)];
        [image setTemplate:YES];
        SMTabBarItem *item = [[SMTabBarItem alloc] initWithImage:image tag:MESSAGE_TAB_TAG];
        item.toolTip = NSLocalizedString(@"Compiler Messages", nil);
        item.keyEquivalent = @"1";
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        [tabBarItems addObject:item];
    }
    {
        NSImage *image = [NSImage imageNamed:@"map"];
        [image setSize:NSMakeSize(16, 16)];
        [image setTemplate:YES];
        SMTabBarItem *item = [[SMTabBarItem alloc] initWithImage:image tag:OUTLINE_TAB_TAG];
        item.toolTip = NSLocalizedString(@"Outline View", nil);
        item.keyEquivalent = @"2";
        item.keyEquivalentModifierMask = NSCommandKeyMask;
        [tabBarItems addObject:item];
    }
    self.tabBar.items = tabBarItems;

}

- (void)windowIsGoingToDie {
    [self.mainWindowController removeObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments"];
    for(NSMenuItem *item in self.selectionPopup.menu.itemArray) {
        [item unbind:@"title"];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.mainWindowController]) {
        [self firstResponderDidChange];
    }
}

- (void)firstResponderDidChange {
    NSArray *mainDocuments = self.mainWindowController.myCurrentFirstResponderDelegate.model.mainDocuments;
 
    for(NSMenuItem *item in self.selectionPopup.menu.itemArray) {
        [item unbind:@"title"];
    }
    NSMenu *menu = [[NSMenu alloc] init];
    for (DocumentModel *dm in mainDocuments) {
        NSMenuItem *item = [[NSMenuItem alloc] init];
        item.representedObject = dm;
        [item bind:@"title" toObject:dm withKeyPath:@"texName" options:NULL];
        [menu addItem:item];
    }
    
    DocumentModel *current = self.selectionPopup.selectedItem.representedObject;
    
    self.selectionPopup.menu = menu;
    
    if (current) {
        NSInteger index = [self.selectionPopup indexOfItemWithRepresentedObject:current] >= 0;
        if (index >= 0) {
            [self.selectionPopup selectItemAtIndex:index];
        }
    } else {
        self.selectedItem = 0;
        [self.selectionPopup selectItemAtIndex:0];
    }
    
    
}

- (void)updateViewForTab:(NSUInteger)tag andSelectedItem:(NSUInteger)item {
    if (item < 0 || item  >= self.selectionPopup.itemArray.count) {
        return;
    }
    DocumentModel *model = [[self.selectionPopup itemAtIndex:item] representedObject];
    if (!model) {
        return;
    }
    NSViewController *vc = nil;
    if (tag == MESSAGE_TAB_TAG) {
        vc = [[MessageOutlineViewController alloc] initWithModel:model];
    } else if(tag == OUTLINE_TAB_TAG) {
        vc = [[StructureOutlineViewController alloc] initWithRootNode:model];
    } else {
        DDLogError(@"Unexpected Case!");
        return;
    }
    self.currentViewController = vc;
    self.contentView.contentView = vc.view;
}


- (void)setSelectedItem:(NSInteger)selectedItem {
    _selectedItem = selectedItem;
    [self updateViewForTab:self.tabBar.selectedItem.tag andSelectedItem:selectedItem];
}

@end
