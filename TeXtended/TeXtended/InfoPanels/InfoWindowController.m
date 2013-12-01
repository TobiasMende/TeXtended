//
//  InfoWindowController.m
//  TeXtended
//
//  Created by Tobias Hecht on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "InfoWindowController.h"
#import "DocumentModel.h"
#import "ProjectModel.h"
#import "CompileFlowHandler.h"
#import "Compilable.h"

@interface InfoWindowController ()

@end

@implementation InfoWindowController

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (id)init {
    self = [super initWithWindowNibName:@"InfoWindow"];
    
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad {
    self.window.isVisible = NO;
    if (self.mainDocumentsController.selectedObjects.count == 0 && [self.mainDocumentsController.arrangedObjects count] > 0) {
        [self.mainDocumentsController setSelectionIndex:0];
    }
    [super windowDidLoad];
}

- (IBAction)addMainDocument:(id)sender {
    texPathPanel = [NSOpenPanel openPanel];
    [texPathPanel setTitle:NSLocalizedString(@"Choose a tex document", @"chooseTexPath")];
    [texPathPanel setCanCreateDirectories:YES];
    [texPathPanel setCanSelectHiddenExtension:YES];
    [texPathPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"tex", nil]];
    NSURL *url= [NSURL fileURLWithPath:[self.compilable.path stringByDeletingLastPathComponent]];
    [texPathPanel setDirectoryURL:url];
    [texPathPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *file = [texPathPanel URL];
            DocumentModel *m = [self.compilable modelForTexPath:file.path];
            [self.compilable addMainDocumentsObject:m];
        }
    }];
}

- (IBAction)removeMainDocument:(id)sender {
    NSMutableArray* mainDocs = [[self.compilable.mainDocuments allObjects] mutableCopy];
    [mainDocs removeObjectAtIndex:[self.table selectedRow]];
    self.compilable.mainDocuments = [NSSet setWithArray:mainDocs];
    [self.table reloadData];
}

- (BOOL)canRemoveEntry {
    return [self.mainDocumentsController.arrangedObjects count] > 1;
}

#pragma mark -
#pragma mark Delegate Methods

- (void)windowWillClose:(NSNotification *)notification {
    self.window.isVisible = NO;
}


- (void)windowDidBecomeMain:(NSNotification *)notification {
    self.window.isVisible = YES;
}


@end
