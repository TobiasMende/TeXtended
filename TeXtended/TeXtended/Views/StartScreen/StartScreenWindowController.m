//
//  StartScreenWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 01.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "StartScreenWindowController.h"
#import "DocumentCreationController.h"
#import "ApplicationController.h"
#import "SimpleDocument.h"

@interface StartScreenWindowController ()
- (void)relinkMenuItemsAndShowMenu:(NSMenu *)menu;
@end

@implementation StartScreenWindowController

-(id)init {
    self = [super initWithWindowNibName:@"StartScreenWindow"];
    return self;
}

#pragma mark - Actions

- (IBAction)openNewDocument:(id)sender {
    self.close;
    [[DocumentCreationController sharedDocumentController] newDocument:nil];
}

- (IBAction)openNewProject:(id)sender {
    self.close;
    [[DocumentCreationController sharedDocumentController] newProject:nil];
}

- (IBAction)openTemplate:(id)sender {
    self.close;
    [[ApplicationController sharedApplicationController] showNewFromTemplate:nil];
}

- (IBAction)showRecentDocuments:(id)sender {
    NSMenu *recents = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Open Recent Document", @"")];
    [[ApplicationController sharedApplicationController] addRecentSimpleDocumentsTo:recents];
    [self relinkMenuItemsAndShowMenu:recents];
    
}

- (IBAction)showRecentProjects:(id)sender {
    NSMenu *recents = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"Open Recent Projects", @"")];
    [[ApplicationController sharedApplicationController] addRecentProjectDocumentsTo:recents];
    [self relinkMenuItemsAndShowMenu:recents];
}

- (IBAction)openExistingDocumentOrProject:(id)sender {
    self.close;
    [[DocumentCreationController sharedDocumentController] openDocument:nil];
}


#pragma mark - Methods

- (void)close {
    [self.window performClose:nil];
}

- (NSArray *)recentDocuments {
    return [[DocumentCreationController sharedDocumentController] recentSimpleDocumentsURLs];
}

- (NSArray *)recentProjects {
    return [[DocumentCreationController sharedDocumentController] recentProjectDocumentsURLs];
}

- (void)relinkMenuItemsAndShowMenu:(NSMenu *)menu {
    for (NSMenuItem *item in menu.itemArray) {
        item.target = self;
        item.action = @selector(openRecent:);
    }
    
    [menu popUpMenuPositioningItem:nil atLocation:[NSEvent mouseLocation] inView:nil];
}

- (void)openRecent:(id)sender {
    self.close;
    [[ApplicationController sharedApplicationController] openRecent:sender];
}
@end
