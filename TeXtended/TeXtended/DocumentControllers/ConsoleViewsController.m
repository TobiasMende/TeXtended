//
//  ConsoleViewsController.m
//  TeXtended
//
//  Created by Tobias Mende on 26.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleViewsController.h"
#import "DocumentModel.h"
#import "ConsoleViewController.h"
#import "DocumentController.h"
#import "DocumentControllerProtocol.h"
#import "MessageDataSource.h"

@interface ConsoleViewsController ()
- (void)clearTabView;
@end

@implementation ConsoleViewsController

- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"ConsoleViewsView" bundle:nil];
    if (self) {
        self.parent = parent;
        [self initialize];
    }
    return self;
}

- (void)loadView {
    [super loadView];
     [self loadConsoles:[self.parent documentController]];
    
    [self.messageDataSource setModel:self.model];
}

- (void) initialize {
   _model = [[self.parent documentController] model];
    [self.model addObserver:self forKeyPath:@"mainDocuments" options:NSKeyValueObservingOptionNew context:NULL];
    
}

- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    for (id<DocumentControllerProtocol> c in self.children) {
        [c documentModelHasChangedAction:controller];
    }
}

- (void) documentHasChangedAction {
    for (id<DocumentControllerProtocol> c in self.children) {
        [c documentHasChangedAction];
    }
}

- (void) breakUndoCoalescing{
}

- (void) clearTabView {
    for (NSTabViewItem *item in [self.tabView tabViewItems]) {
        [self.tabView removeTabViewItem:item];
    }
    [self.view setNeedsDisplay:YES];
    
}

- (void) loadConsoles:(DocumentController*) controller {
    if (self.model.faultingState > 0) {
        return;
    }
    [self clearTabView];
    NSMutableSet *tmp = [[NSMutableSet alloc] init];
    for (DocumentModel* model in [self.model mainDocuments]) {
        ConsoleViewController *consoleViewController = [[ConsoleViewController alloc] initWithParent:self];
        [consoleViewController setModel:model];
        // add the view to the tab view
        NSTabViewItem *item = [[NSTabViewItem alloc] init];
        if ([model texName]) {
            [item setLabel:[model texName]];
        } else {
            [item setLabel:NSLocalizedString(@"Untitled", @"Untitled")];
        }
        [item bind:@"label" toObject:model withKeyPath:@"texName" options:nil];
        [item setView:[consoleViewController view]];
        [self.tabView addTabViewItem:item];
        
        [tmp addObject:consoleViewController];
    }
    
}

#pragma mark -
#pragma mark Observers

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self.model] && self.model.faultingState == 0) {
        if ([keyPath isEqualToString:@"mainDocuments"]) {
            [self loadConsoles:[self documentController]];
        }
    }
}


#pragma mark -
#pragma mark Dealloc etc.

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"ConsoleViewsController dealloc");
    
#endif
    [self.model removeObserver:self forKeyPath:@"mainDocuments"];
}

@end
