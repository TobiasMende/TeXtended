//
//  ProjectCreationWindowController.m
//  TeXtended
//
//  Created by Max Bannach on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ProjectCreationWindowController.h"
#import "FolderSelectionViewController.h"
#import "CompilerSettingsViewController.h"
#import "MainDocumentSelectionViewController.h"
#import "PropertyFileSelectionViewController.h"
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
    compilerSettings = [CompilerSettingsViewController new];
    propertySelection = [PropertyFileSelectionViewController new];
    mainOcumentSelection = [[MainDocumentSelectionViewController alloc] init];
    container.sectionViews = [NSArray arrayWithObjects:
                            [[DMPaletteSectionView alloc] initWithContentView:folderSelection.view andTitle:@"Project Path"],
                            [[DMPaletteSectionView alloc] initWithContentView:mainOcumentSelection.view andTitle:@"Maindocuments and Bibfiles"],
                              [[DMPaletteSectionView alloc] initWithContentView:propertySelection.view andTitle:@"Select a property file"],
                            [[DMPaletteSectionView alloc] initWithContentView:compilerSettings.view andTitle:@"Compiler Settings"],
                              nil];
    container.sectionHeaderGradientEndColor = [NSColor colorWithCalibratedRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
    container.sectionHeaderGradientStartColor = [NSColor colorWithCalibratedRed:0.82f green:0.82f blue:0.82f alpha:1.00f];
}

@end
