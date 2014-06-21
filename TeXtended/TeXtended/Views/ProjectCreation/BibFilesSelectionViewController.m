//
//  BibFilesSelectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "BibFilesSelectionViewController.h"
#import "FolderSelectionViewController.h"
#import "ProjectModel.h"

@interface BibFilesSelectionViewController ()

@end

@implementation BibFilesSelectionViewController

    - (id)initWithFolderSelectionController:(FolderSelectionViewController *)folderSelection
    {
        self = [super initWithNibName:@"BibFilesSelectionView" bundle:nil];
        if (self) {
            self.folderSelection = folderSelection;
        }
        return self;
    }

    - (IBAction)addBibFile:(id)sender
    {
        if (!addPanel) {
            addPanel = [NSOpenPanel new];
            addPanel.directoryURL = [NSURL URLWithString:self.folderSelection.path];
            addPanel.title = NSLocalizedString(@"Select bib files", @"Select bib files");
            addPanel.allowedFileTypes = @[@"bib"];
            addPanel.allowsMultipleSelection = YES;
        }
        [addPanel beginWithCompletionHandler:^(NSInteger result)
        {
            if (result == NSFileHandlingPanelOKButton) {
                NSArray *urls = addPanel.URLs;
                for (NSURL *url in urls) {
                    NSString *path = url.path;
                    if (![self.bibFiles.arrangedObjects containsObject:path]) {
                        [self.bibFiles addObject:path];
                    }
                }
            }
            [self.view.window orderFront:nil];
        }];

    }

    - (IBAction)createBibFile:(id)sender
    {
        if (!createPanel) {
            createPanel = [NSSavePanel new];
            createPanel.directoryURL = [NSURL URLWithString:self.folderSelection.path];
            createPanel.title = NSLocalizedString(@"Create a bib file", @"Create a bib file");
            createPanel.nameFieldLabel = NSLocalizedString(@"File Name:", @"File Name");
            createPanel.allowedFileTypes = @[@"bib"];
        }
        [createPanel beginWithCompletionHandler:^(NSInteger result)
        {
            if (result == NSFileHandlingPanelOKButton) {
                NSString *path = createPanel.URL.path;
                NSFileManager *fm = [NSFileManager defaultManager];
                if (![self.bibFiles.arrangedObjects containsObject:path] && ![fm fileExistsAtPath:path]) {
                    if ([fm createFileAtPath:path contents:[@"" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil]) {
                        [self.bibFiles addObject:path];
                    }
                }
            }
            [self.view.window orderFront:nil];
        }];
    }

    - (void)configureProjectModel:(ProjectModel *)project
    {
        for (NSString *path in self.bibFiles.arrangedObjects) {
            [project addBibFileWithPath:path];
        }
    }
@end
