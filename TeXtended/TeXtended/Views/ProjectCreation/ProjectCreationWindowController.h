//
//  ProjectCreationWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMPaletteContainer, FolderSelectionViewController, CompilerSettingsViewController ,MainDocumentSelectionViewController;
@interface ProjectCreationWindowController : NSWindowController {
    IBOutlet DMPaletteContainer* container;
    FolderSelectionViewController* folderSelection;
    MainDocumentSelectionViewController* mainOcumentSelection;
    CompilerSettingsViewController *compilerSettings;
}


@end
