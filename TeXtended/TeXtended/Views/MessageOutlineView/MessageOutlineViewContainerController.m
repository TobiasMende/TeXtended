//
//  MessageOutlineViewContainer.m
//  TeXtended
//
//  Created by Max Bannach on 08.02.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "MessageOutlineViewContainerController.h"
#import "MainWindowController.h"
#import "MessageOutlineViewController.h"
#import <TMTHelperCollection/TMTlog.h>
#import "TMTNotificationCenter.h"

@interface MessageOutlineViewContainerController ()
- (void) firstResponderDidChange;
- (void) objectWillDie:(NSNotification *)note;
- (void) updateViewForIndex:(NSInteger) index;
@end

@implementation MessageOutlineViewContainerController

- (id)initWithMainWindowController:(MainWindowController *)mwc andPopUpButton:(NSPopUpButton*) button{
    self = [super initWithNibName:@"MessageOutlineViewContainer" bundle:nil];
    if (self) {
        self.mainWindowController = mwc;
        [self.mainWindowController addObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior context:NULL];
        self.selectionPopup = button;
    }
    return self;
}

- (void)windowIsGoingToDie {
    [self.mainWindowController removeObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments"];
    self.mainWindowController = nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.mainWindowController]) {
        [self firstResponderDidChange];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    [self updateViewForIndex:selectedIndex];
}

- (void)updateViewForIndex:(NSInteger)index {
    NSArray *mainDocuments = self.mainWindowController.myCurrentFirstResponderDelegate.model.mainDocuments;
    if (index >= 0 && index < mainDocuments.count) {
        [self.mainView selectTabViewItemAtIndex:index];
        DocumentModel *mainDocument = mainDocuments[index];
        self.mainWindowController.myCurrentFirstResponderDelegate.model.currentMainDocument = mainDocument;
        [[TMTNotificationCenter centerForCompilable:mainDocument] postNotificationName:TMTSelectedMainDocumentDidChangeNotification object:self userInfo:@{TMTNewSelectedMainDocumentKey: mainDocument}];
    }
}

- (void)firstResponderDidChange {
    NSArray *mainDocuments = self.mainWindowController.myCurrentFirstResponderDelegate.model.mainDocuments;
    messages = [NSMutableArray arrayWithCapacity:mainDocuments.count];
    NSString *currentSelection = self.selectionPopup.selectedItem.title;
    for(NSTabViewItem *item in self.mainView.tabViewItems) {
        [self.mainView removeTabViewItem:item];
    }
    
    BOOL selectionExists = NO;
    for(DocumentModel *model in mainDocuments) {
        MessageOutlineViewController *messageView = [[MessageOutlineViewController alloc] initWithModel:model];
        NSTabViewItem *item = [NSTabViewItem new];
        item.view = messageView.view;
        
        NSString *name = model.texName ? model.texName : model.texIdentifier;
        [item bind:@"label" toObject:model withKeyPath:@"texName" options:nil];
        
        if ([name isEqualToString:currentSelection]) {
            selectionExists = YES;
        }
        
        [messages addObject:messageView];
        [self.mainView addTabViewItem:item];
        if (selectionExists) {
            [self.mainView selectTabViewItemAtIndex:[self.selectionPopup indexOfItemWithTitle:currentSelection]];
        }
    }
}

- (void)dealloc {
    if (self.mainWindowController) {
        [self.mainWindowController removeObserver:self forKeyPath:@"myCurrentFirstResponderDelegate.model.mainDocuments"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

@end
