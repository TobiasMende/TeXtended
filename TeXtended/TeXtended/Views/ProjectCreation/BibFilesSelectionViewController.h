//
//  BibFilesSelectionViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProjectCreationAssistantViewController.h"

@class FolderSelectionViewController;

@interface BibFilesSelectionViewController : NSViewController <ProjectCreationAssistantViewController>
    {
        NSOpenPanel *addPanel;

        NSSavePanel *createPanel;
    }


    @property FolderSelectionViewController *folderSelection;

    @property (strong) IBOutlet NSArrayController *bibFiles;

    - (id)initWithFolderSelectionController:(FolderSelectionViewController *)folderSelection;

    - (IBAction)addBibFile:(id)sender;

    - (IBAction)createBibFile:(id)sender;
@end
