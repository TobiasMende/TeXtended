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
- (void) objectWillDie:(NSNotification *)note;
@end

@implementation StructureOutlineViewController

- (id)initWithMainWindowController:(MainWindowController *)mwc {
    self = [super initWithNibName:@"StructureOutlineView" bundle:nil];
    if (self) {
        self.mainWindowController = mwc;
        [self.mainWindowController addObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectWillDie:) name:TMTObjectWillDieNotification object:self.mainWindowController];
    }
    return self;
}

- (void)objectWillDie:(NSNotification *)note {
    [self.mainWindowController removeObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments"];
    self.mainWindowController = nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self firstResponderDidChange];
}

- (void)firstResponderDidChange {
    NSArray *mainDocuments = self.mainWindowController.myCurrentFirstResponderDelegate.model.mainDocuments;
    sections = [NSMutableArray arrayWithCapacity:mainDocuments.count];
    [self.selectionPopup removeAllItems];
    for(NSTabViewItem *item in self.mainView.tabViewItems) {
        [self.mainView removeTabViewItem:item];
    }
    for(DocumentModel *model in mainDocuments) {
        StructureOutlineSectionViewController *structure = [[StructureOutlineSectionViewController alloc] initWithRootNode:model];
        NSTabViewItem *item = [NSTabViewItem new];
        item.view = structure.view;
        NSString *name = model.texName ? model.texName : model.texIdentifier;
        [self.selectionPopup addItemWithTitle:name];
        [item bind:@"label" toObject:model withKeyPath:@"texName" options:nil];
        [sections addObject:structure];
        [self.mainView addTabViewItem:item];
    }
  
}

- (void)dealloc {
    if (self.mainWindowController) {
        [self.mainWindowController removeObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

@end
