//
//  ProjectCreationWindowController.h
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DMPaletteContainer, FolderSelectionViewController;
@interface ProjectCreationWindowController : NSWindowController {
    IBOutlet DMPaletteContainer* container;
    FolderSelectionViewController* folderSelection;
}


@end
