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

@interface ConsoleViewsController ()
- (void)clearTabView;
@end

@implementation ConsoleViewsController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithParent:(id<DocumentControllerProtocol>)parent {
    self = [super initWithNibName:@"ConsoleViewsView" bundle:nil];
    if (self) {
        self.parent = parent;
        [self initialize];
    }
    return self;
}

- (void) initialize {
    //TODO: add children view depending on current model
}

- (DocumentController * ) documentController {
    return [self.parent documentController];
}

- (void) documentModelHasChangedAction : (DocumentController*) controller {
    [self loadConsoles:controller];
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
}

- (void) loadConsoles:(DocumentController*) controller {
    [self clearTabView];
    
    NSMutableSet *tmp = [[NSMutableSet alloc] init];
    DocumentModel *mainModel = [controller model];
    for (DocumentModel* model in [mainModel mainDocuments]) {
        ConsoleViewController *consoleViewController = [[ConsoleViewController alloc] initWithParent:self];
        [consoleViewController setModel:model];
        // add the view to the tab view
        NSTabViewItem *item = [[NSTabViewItem alloc] init];
        if ([model texName]) {
            [item setLabel:[model texName]];
        } else {
            [item setLabel:NSLocalizedString(@"Untitled", @"Untitled")];
        }
        [item setView:[consoleViewController view]];
        [self.tabView addTabViewItem:item];
        
        [tmp addObject:consoleViewController];
    }
    if ([[mainModel mainDocuments] count] > 1) {
        [self.tabView setTabViewType:NSBottomTabsBezelBorder];
    } else {
        [self.tabView setTabViewType:NSNoTabsNoBorder];
    }
    [self setChildren:tmp];
}

@end
