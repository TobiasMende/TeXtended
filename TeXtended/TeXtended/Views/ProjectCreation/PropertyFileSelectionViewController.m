//
//  PropertyFileSelectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PropertyFileSelectionViewController.h"
#import "FolderSelectionViewController.h"
#import "ProjectModel.h"

@interface PropertyFileSelectionViewController ()

@end

@implementation PropertyFileSelectionViewController

    - (id)initWithFolderSelectionController:(FolderSelectionViewController *)folderSelection
    {
        self = [super initWithNibName:@"PropertyFileSelectionView" bundle:nil];
        if (self) {
            self.folderSelection = folderSelection;
        }
        return self;
    }

    - (IBAction)select:(id)sender
    {
        NSOpenPanel *panel = [[NSOpenPanel alloc] init];
        
        if ([sender isEqual:self.pathControl]) {
            panel.directoryURL = self.pathControl.clickedPathComponentCell.URL;
        }

        panel.canChooseFiles = YES;
        panel.canChooseDirectories = NO;
        panel.title = NSLocalizedString(@"Choose Properties File", @"Choose Properties File");
        panel.canCreateDirectories = NO;
        panel.allowedFileTypes = @[@"tex"];

        [panel beginWithCompletionHandler:^(NSInteger result)
        {
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *directory = [panel URL];
                self.filePath = [directory path];
                [self.view.window orderFront:nil];
            }
        }];

    }

    - (void)configureProjectModel:(ProjectModel *)project
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        if (self.filePath && [fm fileExistsAtPath:self.filePath]) {
            project.properties = [project modelForTexPath:self.filePath byCreating:YES];
        }
    }



@end
