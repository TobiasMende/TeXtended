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
#import <TMTHelperCollection/TMTlog.h>

@interface StructureOutlineViewController ()
- (void) firstResponderDidChange;
- (void) objectWillDie:(NSNotification *)note;
@end

@implementation StructureOutlineViewController

- (id)initWithMainWindowController:(MainWindowController *)mwc andWithPopUpButton:(NSPopUpButton*) button {
    self = [super initWithNibName:@"StructureOutlineView" bundle:nil];
    if (self) {
        self.mainWindowController = mwc;
        [self.mainWindowController addObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    }
    self.selectionPopup = button;
    return self;
}

- (void)windowIsGoingToDie {
    [self.mainWindowController removeObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments"];
    self.mainWindowController = nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self firstResponderDidChange];
}

- (void)firstResponderDidChange {
    NSArray *mainDocuments = self.mainWindowController.myCurrentFirstResponderDelegate.model.mainDocuments;
    sections = [NSMutableArray arrayWithCapacity:mainDocuments.count];
    NSString *currentSelection = self.selectionPopup.selectedItem.title;

    for(NSTabViewItem *item in self.mainView.tabViewItems) {
        [self.mainView removeTabViewItem:item];
    }
    BOOL selectionExists = NO;
    for(DocumentModel *model in mainDocuments) {
        StructureOutlineSectionViewController *structure = [[StructureOutlineSectionViewController alloc] initWithRootNode:model];
        NSTabViewItem *item = [NSTabViewItem new];
        item.view = structure.view;
        NSString *name = model.texName ? model.texName : model.texIdentifier;
       
        [item bind:@"label" toObject:model withKeyPath:@"texName" options:nil];
        if ([name isEqualToString:currentSelection]) {
            selectionExists = YES;
        }
        [sections addObject:structure];
        [self.mainView addTabViewItem:item];
        if (selectionExists) {
            [self.mainView selectTabViewItemAtIndex:[self.selectionPopup indexOfItemWithTitle:currentSelection]];
            
        }
    }
    
  
}

- (void)dealloc {
    if (self.mainWindowController) {
        [self.mainWindowController removeObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments"];
    }
}

@end
