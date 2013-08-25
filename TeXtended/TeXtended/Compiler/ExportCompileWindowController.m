//
//  ExportCompileWindowController.m
//  TeXtended
//
//  Created by Max Bannach on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ExportCompileWindowController.h"
#import "DocumentController.h"
#import "DocumentModel.h"
#import "ProjectModel.h"
#import "TMTTableView.h"

@interface ExportCompileWindowController ()
- (void) internalSetActive:(BOOL)active;
@end

@implementation ExportCompileWindowController

+ (void)initialize {
    [self exposeBinding:@"canRemoveEntry"];
}

-(id)initWithDocumentController:(DocumentController*) controller {
    self = [super initWithWindowNibName:@"ExportCompileWindow"];
    if (self) {
        _controller = controller;
    }
    return self;
}

- (void)windowDidLoad {
    self.window.isVisible = NO;
    [super windowDidLoad];
}

- (void)awakeFromNib {
    [self.selectionView.titleCell setTextColor:[NSColor controlLightHighlightColor]];
    [self.settingsView.titleCell setTextColor:[NSColor controlLightHighlightColor]];
    NSMutableAttributedString *bibCheckboxTitle = [[self.bibCheckbox attributedTitle] mutableCopy];
    [bibCheckboxTitle addAttribute:NSForegroundColorAttributeName value:[NSColor controlLightHighlightColor] range:NSMakeRange(0, bibCheckboxTitle.length)];
    NSMutableAttributedString *openCheckboxTitle = [[self.openCheckbox attributedTitle] mutableCopy];
    [openCheckboxTitle addAttribute:NSForegroundColorAttributeName value:[NSColor controlLightHighlightColor] range:NSMakeRange(0, openCheckboxTitle.length)];
    
    [self.bibCheckbox setAttributedTitle:bibCheckboxTitle];
    [self.openCheckbox setAttributedTitle:openCheckboxTitle];
    [self.selectionTable setBackgroundColor:[NSColor clearColor]];
    if (self.mainDocumentsController.selectedObjects.count == 0 && [self.mainDocumentsController.arrangedObjects count] > 0) {
        [self.mainDocumentsController setSelectionIndex:0];
    }
}

- (IBAction)export:(id)sender {
    if (self.controller) {
        [self.controller finalCompile];
        [self.window orderOut:nil];
    }
}

- (IBAction)exportPathDialog:(id)sender {
    pdfPathPanel = [NSSavePanel savePanel];
    [pdfPathPanel setTitle:NSLocalizedString(@"Choose a pdf path", @"choosePDFPath")];
    [pdfPathPanel setCanCreateDirectories:YES];
    [pdfPathPanel setCanSelectHiddenExtension:YES];
    [pdfPathPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"pdf", nil]];
    DocumentModel *m = [self.mainDocumentsController.selectedObjects objectAtIndex:0];
    if (m) {
        NSURL *url;
        if (m.pdfPath) {
            url = [NSURL fileURLWithPath:[m.pdfPath stringByDeletingLastPathComponent]];
        } else if(m.texPath) {
            url = [NSURL fileURLWithPath:[m.texPath stringByDeletingLastPathComponent]];
        }
        [pdfPathPanel setDirectoryURL:url];
    }
    [pdfPathPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *file = [pdfPathPanel URL];
            DocumentModel *m = [self.mainDocumentsController.selectedObjects objectAtIndex:0];
            m.pdfPath = [file path];
        }
    }];
    
}

- (BOOL)canRemoveEntry {
    return [self.mainDocumentsController.arrangedObjects count] > 1;
}

- (IBAction)removeMainDocument:(id)sender {
    DocumentModel *m = [self.mainDocumentsController.selectedObjects objectAtIndex:0];
    [self.model removeMainDocumentsObject:m];
}

- (IBAction)addMainDocument:(id)sender {
    texPathPanel = [NSOpenPanel openPanel];
    [texPathPanel setTitle:NSLocalizedString(@"Choose a tex document", @"chooseTexPath")];
    [texPathPanel setCanCreateDirectories:YES];
    [texPathPanel setCanSelectHiddenExtension:YES];
    [texPathPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"tex", nil]];
    NSURL *url;
    if (self.model.texPath) {
        url = [NSURL fileURLWithPath:[self.model.texPath stringByDeletingLastPathComponent]];
    } else if(self.model.project && self.model.project.path) {
        url = [NSURL fileURLWithPath:[self.model.project.path stringByDeletingLastPathComponent]];
    }
    [texPathPanel setDirectoryURL:url];
    [texPathPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *file = [texPathPanel URL];
            DocumentModel *m = [self.model modelForTexPath:file.path];
            [self.model addMainDocumentsObject:m];
        }
    }];
}


- (void)setActive:(BOOL)active {
    if (active) {
        [self showWindow:self];
    } else {
        [self close];
    }
    _active = active;
}

- (void)internalSetActive:(BOOL)active {
    [self willChangeValueForKey:@"active"];
    _active = active;
    [self didChangeValueForKey:@"active"];
}
#pragma mark -
#pragma mark Delegate Methods

- (void)windowWillClose:(NSNotification *)notification {    
    [self internalSetActive:NO];
}


- (void)windowDidBecomeMain:(NSNotification *)notification {
    [self internalSetActive:YES];
}

@end
