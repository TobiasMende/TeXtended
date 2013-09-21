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

/** Clears the tab view, i.e. removes all elements. */
- (void)clearTabView;

/**
 * Add a item to the tab view for the given controller of a console view.
 *
 * @param controller the ConsoleViewController
 */
- (void)addTabItemFor:(ConsoleViewController*)controller;
@end

@implementation ConsoleViewsController

- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"ConsoleViewsView2" bundle:nil];
    if (self) {
        self.parent = parent;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    [self initialize];
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

/**
 * Load the consoles for all main documents of the give DocumentController.
 *
 * @param controller the given DocumentController
 */
- (void) loadConsoles:(DocumentController*) controller {
    if (self.model.faultingState > 0) {
        return;
    }
    [self clearTabView];
    NSMutableSet *newChilds = [[NSMutableSet alloc] initWithCapacity:self.model.mainDocuments.count];
    for (DocumentModel *m in self.model.mainDocuments) {
        BOOL controllerExists = NO;
        for(ConsoleViewController *controller in self.children) {
            if ([controller.model isEqualTo:m]) {
                [newChilds addObject:controller];
                [self addTabItemFor:controller];
                controllerExists = YES;
                break;
            }
        }
        if (!controllerExists) {
            ConsoleViewController *consoleViewController = [[ConsoleViewController alloc] initWithParent:self];
            [consoleViewController setModel:m];
            [newChilds addObject:consoleViewController];
            [self addTabItemFor:consoleViewController];
        }
    }
    self.children = newChilds;
    
}

- (void)addTabItemFor:(ConsoleViewController *)controller {
    DocumentModel *m = controller.model;
    NSTabViewItem *item = [[NSTabViewItem alloc] init];
    if ([m texName]) {
        [item setLabel:[m texName]];
    } else {
        [item setLabel:NSLocalizedString(@"Untitled", @"Untitled")];
    }
    [item bind:@"label" toObject:m withKeyPath:@"texName" options:nil];
    [item setView:[controller view]];
    [self.tabView addTabViewItem:item];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

@end
