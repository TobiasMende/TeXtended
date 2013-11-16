//
//  ProjectCreationWindowController.m
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ProjectCreationWindowController.h"
#import "FolderSelectionViewController.h"
#import "MainDocumentSelectionViewController.h"
#import "DMPaletteContainer.h"

@interface ProjectCreationWindowController ()

@end

@implementation ProjectCreationWindowController

- (id) init {
    self = [super initWithWindowNibName:@"ProjectCreationWindow"];
    if (self) {
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    folderSelection = [[FolderSelectionViewController alloc] init];
    mainOcumentSelection = [[MainDocumentSelectionViewController alloc] init];
    
    container.sectionViews = [NSArray arrayWithObjects:
                              [[DMPaletteSectionView alloc] initWithContentView:folderSelection.view andTitle:@"Project Path"],
                              [[DMPaletteSectionView alloc] initWithContentView:mainOcumentSelection.view andTitle:@"Maindocuments and Bibfiles"],
                              nil];
}

@end
