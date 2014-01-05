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

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

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
        NSString *firstName = [NSString localizedNameOfStringEncoding:[first intValue]];
        NSString *secondName = [NSString localizedNameOfStringEncoding:[second intValue]];
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
    [texPathPanel setAllowedFileTypes:@[@"tex"]];
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

- (IBAction)encodingSelectionChange:(id)sender {
    if (self.compilable.encoding) {
        self.compilable.encoding = encodings[self.encodingPopUp.indexOfSelectedItem];
    }
}

- (BOOL)canRemoveEntry {
    return [self.mainDocumentsController.arrangedObjects count] > 1;
}

- (void) setCompilable:(Compilable *)compilable {
    
    if ([self.compilable.type isEqualToString:@"Document"]) {
            [self.compilable removeObserver:self forKeyPath:@"self.encoding"];
    }
    
    _compilable = compilable;
    if ([self.compilable.type isEqualToString:@"Document"]) {
        [self.compilable addObserver:self forKeyPath:@"self.encoding" options:NSKeyValueObservingOptionInitial context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.encoding"]) {
        if (self.compilable.encoding) {
            [self.encodingPopUp selectItemAtIndex:[encodings indexOfObject:self.compilable.encoding]];
        }
    }
}

#pragma mark -
#pragma mark Delegate Methods

- (void)windowWillClose:(NSNotification *)notification {
    self.window.isVisible = NO;
}


- (void)windowDidBecomeMain:(NSNotification *)notification {
    self.window.isVisible = YES;
    if ([[self.compilable.path pathExtension] isEqualToString:@"tex"]) {
        [self.encodingPopUp setHidden:NO];
    }
    else {
        [self.encodingPopUp setHidden:YES];
    }
}


- (void)dealloc {
    if ([self.compilable.type isEqualToString:@"Document"]) {
            [self.compilable removeObserver:self forKeyPath:@"self.encoding"];
    }
    DDLogVerbose(@"dealloc");
}

@end
