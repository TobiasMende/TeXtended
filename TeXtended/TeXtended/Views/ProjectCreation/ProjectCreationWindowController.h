//
//  ProjectCreationWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMPaletteContainer, PropertyFileSelectionViewController, FolderSelectionViewController, CompilerSettingsViewController ,MainAndBibFileSelectionViewController;
@interface ProjectCreationWindowController : NSWindowController {
    IBOutlet DMPaletteContainer* container;
    FolderSelectionViewController* folderSelection;
    MainAndBibFileSelectionViewController* mainDocumentSelection;
    CompilerSettingsViewController *compilerSettings;
    PropertyFileSelectionViewController *propertySelection;
}


@end
