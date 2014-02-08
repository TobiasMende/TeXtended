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
#import "MainDocument.h"
#import <TMTHelperCollection/TMTTableView.h>

@interface ExportCompileWindowController ()
@end

@implementation ExportCompileWindowController

+ (void)initialize {
    [self exposeBinding:@"canRemoveEntry"];
}

-(id)initWithMainDocument:(MainDocument *)mainDocument {
    self = [super initWithWindowNibName:@"ExportCompileWindow"];
    if (self) {
        self.mainDocument = mainDocument;
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


- (IBAction)exportPathDialog:(id)sender {
    pdfPathPanel = [NSSavePanel savePanel];
    [pdfPathPanel setTitle:NSLocalizedString(@"Choose a pdf path", @"choosePDFPath")];
    [pdfPathPanel setCanCreateDirectories:YES];
    [pdfPathPanel setCanSelectHiddenExtension:YES];
    [pdfPathPanel setAllowedFileTypes:@[@"pdf"]];
    DocumentModel *m = (self.mainDocumentsController.selectedObjects)[0];
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
            DocumentModel *m = (self.mainDocumentsController.selectedObjects)[0];
            m.pdfPath = [file path];
        }
    }];
    
}

- (BOOL)canRemoveEntry {
    return [self.mainDocumentsController.arrangedObjects count] > 1;
}

- (IBAction)removeMainDocument:(id)sender {
    DocumentModel *m = (self.mainDocumentsController.selectedObjects)[0];
    [self.model removeMainDocument:m];
}

- (IBAction)addMainDocument:(id)sender {
    texPathPanel = [NSOpenPanel openPanel];
    [texPathPanel setTitle:NSLocalizedString(@"Choose a tex document", @"chooseTexPath")];
    [texPathPanel setCanCreateDirectories:YES];
    [texPathPanel setCanSelectHiddenExtension:YES];
    [texPathPanel setAllowedFileTypes:@[@"tex"]];
    NSURL *url;
    if (self.model.texPath) {
        url = [NSURL fileURLWithPath:[self.model.texPath stringByDeletingLastPathComponent]];
    } else if(self.model.project && self.model.project.path) {
        url = [NSURL fileURLWithPath:[self.model.project.path stringByDeletingLastPathComponent]];
    }
    [texPathPanel setDirectoryURL:url];
    __unsafe_unretained DocumentModel *weakModel = self.model;
    [texPathPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *file = [texPathPanel URL];
            DocumentModel *m = [weakModel modelForTexPath:file.path];
            [weakModel addMainDocument:m];
        }
    }];
}

- (void)setDocumentController:(DocumentController *)documentController {
    _documentController = documentController;
    self.model = documentController.model;
}


- (void)export:(id)sender {
    [self.window orderOut:nil];
    if (self.documentController && self.mainDocument) {
        [self.mainDocument saveEntireDocumentWithDelegate:self.documentController andSelector:@selector(finalCompile:didSave:contextInfo:)];
    }
}

#pragma mark -
#pragma mark Delegate Methods

@end
