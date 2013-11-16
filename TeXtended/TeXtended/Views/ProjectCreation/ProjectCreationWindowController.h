//
//  ProjectCreationWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMPaletteContainer, PropertyFileSelectionViewController, FolderSelectionViewController, CompilerSettingsViewController ,MainDocumentsSelectionViewController, BibFilesSelectionViewController, ProjectDocument;
@interface ProjectCreationWindowController : NSWindowController {
    IBOutlet DMPaletteContainer* container;
    FolderSelectionViewController* folderSelection;
    MainDocumentsSelectionViewController* mainDocumentSelection;
    BibFilesSelectionViewController *bibFilesSelection;
    CompilerSettingsViewController *compilerSettings;
    PropertyFileSelectionViewController *propertySelection;
}

@property (copy) void (^terminationHandler)(ProjectDocument  *project, BOOL success);
- (IBAction)cancelProjectCreation:(id)sender;
- (IBAction)createProject:(id)sender;


@end
