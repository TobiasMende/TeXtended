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
#import "EncodingController.h"
#import <TMTHelperCollection/TMTLog.h>

@interface InfoWindowController ()

@end

@implementation InfoWindowController
- (id)init {
    self = [super initWithWindowNibName:@"InfoWindow"];
    
    if (self) {
    }
    
    return self;
}

- (void)windowDidLoad {
    const NSStringEncoding *encoding = [NSString availableStringEncodings];
    NSMutableArray *allEncodings = [[NSMutableArray alloc] init];
    while (*encoding != 0) {
        [allEncodings addObject:@(*encoding)];
        encoding++;
    }
    [allEncodings sortUsingComparator:^NSComparisonResult(id first, id second) {
        NSString *firstName = [NSString localizedNameOfStringEncoding:[first unsignedLongValue]];
        NSString *secondName = [NSString localizedNameOfStringEncoding:[second unsignedLongValue]];
        return [firstName compare:secondName];
    }];
    
    [self.encodingPopUp removeAllItems];
    // Fill with encodings
    for (NSInteger cnt = 0; cnt < [allEncodings count]; cnt++) {
        NSNumber *encodingNumber = allEncodings[cnt];
        NSStringEncoding encoding = [encodingNumber unsignedLongValue];
        [self.encodingPopUp addItemWithTitle:[NSString localizedNameOfStringEncoding:encoding]];
        [[self.encodingPopUp lastItem] setRepresentedObject:encodingNumber];
        [[self.encodingPopUp lastItem] setEnabled:YES];
    }
    
    encodings = allEncodings;
    
    self.window.isVisible = NO;
    /*if (self.mainDocumentsController.selectedObjects.count == 0 && [self.mainDocumentsController.arrangedObjects count] > 0) {
        [self.mainDocumentsController setSelectionIndex:0];
    }
    if (self.bibFilesController.selectedObjects.count == 0 && [self.bibFilesController.arrangedObjects count] > 0) {
        [self.bibFilesController setSelectionIndex:0];
    }*/
    [super windowDidLoad];
}

- (IBAction)addMainDocument:(id)sender {
    texPathPanel = [NSOpenPanel openPanel];
    [texPathPanel setTitle:NSLocalizedString(@"Choose a tex document", @"chooseTexPath")];
    [texPathPanel setCanCreateDirectories:YES];
    [texPathPanel setCanSelectHiddenExtension:YES];
    [texPathPanel setAllowedFileTypes:@[@"tex"]];
    NSURL *url= [NSURL fileURLWithPath:[self.compilable.path stringByDeletingLastPathComponent]];
    [texPathPanel setDirectoryURL:url];
    [texPathPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *file = [texPathPanel URL];
            DocumentModel *m = [self.compilable modelForTexPath:file.path];
            [self.compilable addMainDocument:m];
        }
    }];
}

- (IBAction)removeMainDocument:(id)sender {
    NSMutableArray* mainDocs = [self.compilable.mainDocuments mutableCopy];
    [mainDocs removeObjectAtIndex:[self.table selectedRow]];
    self.compilable.mainDocuments = mainDocs;
    [self.table reloadData];
}

- (IBAction)addBibFile:(id)sender {
    texPathPanel = [NSOpenPanel openPanel];
    [texPathPanel setTitle:NSLocalizedString(@"Choose a bib document", @"chooseBibPath")];
    [texPathPanel setCanCreateDirectories:YES];
    [texPathPanel setCanSelectHiddenExtension:YES];
    [texPathPanel setAllowedFileTypes:@[@"bib"]];
    NSURL *url= [NSURL fileURLWithPath:[self.compilable.path stringByDeletingLastPathComponent]];
    [texPathPanel setDirectoryURL:url];
    [texPathPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *file = [texPathPanel URL];
            ProjectModel *m = (ProjectModel*)self.compilable;
            [m addBibFileWithPath:[file path]];
        }
    }];
}

- (IBAction)removeBibFile:(id)sender {
    ProjectModel *m = (ProjectModel*)self.compilable;
    [m removeBibFileWithIndex:[self.bibTable selectedRow]];
    [self.bibTable reloadData];
}

- (IBAction)encodingSelectionChange:(id)sender {
    if (self.compilable.encoding) {
        self.compilable.encoding = encodings[self.encodingPopUp.indexOfSelectedItem];
    }
}

- (BOOL)canRemoveEntry {
    return [self.mainDocumentsController.arrangedObjects count] > 1;
}

- (BOOL)canRemoveBibEntry {
    return [self.bibFilesController.arrangedObjects count] > 0;
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
