//
//  StructureOutlineViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "StructureOutlineViewController.h"
#import "StructureOutlineSectionViewController.h"
#import "MainWindowController.h"
#import "DMPaletteContainer.h"
#import "FirstResponderDelegate.h"
#import "DocumentModel.h"
#import "DMPaletteSectionView.h"

@interface StructureOutlineViewController ()
- (void) firstResponderDidChange;
@end

@implementation StructureOutlineViewController

- (id)initWithMainWindowController:(MainWindowController *)mwc {
    self = [super initWithNibName:@"StructureOutlineView" bundle:nil];
    if (self) {
        self.mainWindowController = mwc;
        [self.mainWindowController addObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    }
    return self;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self firstResponderDidChange];
}

- (void)firstResponderDidChange {
    NSSet *mainDocuments = self.mainWindowController.myCurrentFirstResponderDelegate.model.mainDocuments;
    sections = [NSMutableArray arrayWithCapacity:mainDocuments.count];
    for(NSTabViewItem *item in self.mainView.tabViewItems) {
        [self.mainView removeTabViewItem:item];
    }
    for(DocumentModel *model in mainDocuments) {
        StructureOutlineSectionViewController *structure = [[StructureOutlineSectionViewController alloc] initWithRootNode:model];
        NSTabViewItem *item = [NSTabViewItem new];
        item.view = structure.view;
        [item bind:@"identifier" toObject:model withKeyPath:@"texName" options:nil];
        [sections addObject:structure];
        [self.mainView addTabViewItem:item];
    }
    if (mainDocuments.count <= 1) {
        [self.mainView setTabViewType:NSNoTabsNoBorder];
    } else {
        [self.mainView setTabViewType:NSBottomTabsBezelBorder];
    }
}

- (void)dealloc {
    if (self.mainWindowController) {
        [self.mainWindowController removeObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments"];
    }
}

@end
