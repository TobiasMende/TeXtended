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
#import "MainDocumentsSelectionViewController.h"
#import "BibFilesSelectionViewController.h"
#import "PropertyFileSelectionViewController.h"
#import "DMPaletteContainer.h"
#import "ProjectDocument.h"
#import "ProjectModel.h"

@interface ProjectCreationWindowController ()
@end

@implementation ProjectCreationWindowController

    - (id)init
    {
        self = [super initWithWindowNibName:@"ProjectCreationWindow"];
        if (self) {
            self.folderSelection = [[FolderSelectionViewController alloc] init];
            compilerSettings = [CompilerSettingsViewController new];
            propertySelection = [[PropertyFileSelectionViewController alloc] initWithFolderSelectionController:self.folderSelection];
            self.mainDocumentSelection = [[MainDocumentsSelectionViewController alloc] initWithFolderSelectionController:self.folderSelection];
            bibFilesSelection = [[BibFilesSelectionViewController alloc] initWithFolderSelectionController:self.folderSelection];
        }
        return self;
    }

    - (void)windowDidLoad
    {
        [super windowDidLoad];


        DMPaletteSectionView *projectPathContainer = [[DMPaletteSectionView alloc] initWithContentView:self.folderSelection.view andTitle:NSLocalizedString(@"1. Select a project folder", @"Title in ProjectCreationWindow")];
        DMPaletteSectionView *mainAndBibcontainer = [[DMPaletteSectionView alloc] initWithContentView:self.mainDocumentSelection.view andTitle:NSLocalizedString(@"2. Select or create the main documents", @"Title in ProjectCreationWindow")];
        DMPaletteSectionView *propertyFileContainer = [[DMPaletteSectionView alloc] initWithContentView:propertySelection.view andTitle:NSLocalizedString(@"3. Select a property file", @"Title in ProjectCreationWindow")];
        DMPaletteSectionView *bibFileContainer = [[DMPaletteSectionView alloc] initWithContentView:bibFilesSelection.view andTitle:NSLocalizedString(@"4. Select the bib files", @"Title in ProjectCreationWindow")];
        DMPaletteSectionView *compilerSettingContainer = [[DMPaletteSectionView alloc] initWithContentView:compilerSettings.view andTitle:NSLocalizedString(@"5. Configure the compiler settings", @"Title in ProjectCreationWindow")];
        container.sectionViews = @[projectPathContainer,
                mainAndBibcontainer,
                propertyFileContainer,
                bibFileContainer,
                compilerSettingContainer];
        [container collapseSectionView:propertyFileContainer];
        [container collapseSectionView:bibFileContainer];
        [container collapseSectionView:compilerSettingContainer];
        container.sectionHeaderGradientEndColor = [NSColor colorWithCalibratedRed:0.95f green:0.95f blue:0.95f alpha:1.00f];
        container.sectionHeaderGradientStartColor = [NSColor colorWithCalibratedRed:0.82f green:0.82f blue:0.82f alpha:1.00f];
        container.hasHorizontalScroller = NO;
    }

    - (IBAction)cancelProjectCreation:(id)sender
    {
        [self.window orderOut:nil];
        if (self.terminationHandler) {
            self.terminationHandler(nil, NO);
        }
    }

    - (IBAction)createProject:(id)sender
    {
        [self.window orderOut:nil];
        ProjectDocument *doc = [ProjectDocument new];
        [self.folderSelection configureProjectModel:doc.model];
        [self.mainDocumentSelection configureProjectModel:doc.model];
        [bibFilesSelection configureProjectModel:doc.model];
        [compilerSettings configureProjectModel:doc.model];
        [propertySelection configureProjectModel:doc.model];
        doc.fileURL = [[NSURL alloc] initFileURLWithPath:doc.model.path];
        if (self.terminationHandler) {
            self.terminationHandler(doc, YES);
        }
    }
@end
