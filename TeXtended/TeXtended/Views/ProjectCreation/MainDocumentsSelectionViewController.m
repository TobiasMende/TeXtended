//
//  MainDocumentsSelectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainDocumentsSelectionViewController.h"
#import "FolderSelectionViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "ProjectModel.h"

LOGGING_DEFAULT

@interface MainDocumentsSelectionViewController ()

    - (void)initializeContent;
@end

@implementation MainDocumentsSelectionViewController

    - (id)initWithFolderSelectionController:(FolderSelectionViewController *)folderSelection
    {
        self = [super initWithNibName:@"MainDocumentsSelectionView" bundle:nil];
        if (self) {
            self.folderSelection = folderSelection;
            [self.folderSelection addObserver:self forKeyPath:@"path" options:NSKeyValueObservingOptionNew context:NULL];
        }
        return self;
    }

    - (void)loadView
    {
        [super loadView];

    }

    - (IBAction)addDocument:(id)sender
    {
        NSArray *docs = [self.possibleDocuments selectedObjects];
        [self.selectedDocuments addObjects:docs];
        [self.possibleDocuments removeObjects:docs];
    }

    - (IBAction)removeDocument:(id)sender
    {
        NSArray *docs = [self.selectedDocuments selectedObjects];
        [self.possibleDocuments addObjects:docs];
        [self.selectedDocuments removeObjects:docs];
    }

    - (IBAction)createDocument:(id)sender
    {
        if (!createPanel) {
            createPanel = [NSSavePanel new];
            createPanel.directoryURL = [NSURL URLWithString:self.folderSelection.path];
            createPanel.canCreateDirectories = NO;
            createPanel.allowedFileTypes = @[@"tex"];
            createPanel.nameFieldLabel = NSLocalizedString(@"File Name:", @"File Name");
            createPanel.title = NSLocalizedString(@"Add a Main File", @"Add a Main File");
        }
        [createPanel beginWithCompletionHandler:^(NSInteger result)
        {
            if (result == NSFileHandlingPanelOKButton) {
                NSString *path = self->createPanel.URL.path;
                NSFileManager *fm = [NSFileManager defaultManager];
                if (![fm fileExistsAtPath:path]) {
                    NSString *content = @"% Start your awesome tex project here!";
                    NSError *error;
                    [content writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    if (!error) {
                        [self.possibleDocuments addObject:path];
                    } else {
                        DDLogError(@"Can't create document at %@: %@", path, error.userInfo);
                    }
                }
            }
            [self.view.window orderFront:nil];
        }];
    }

    - (void)initializeContent
    {
        NSString *path = self.folderSelection.path;
        [self.possibleDocuments setContent:nil];
        [self.selectedDocuments setContent:nil];
        [self.selectedDocuments removeObjects:[self.selectedDocuments arrangedObjects]];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error;
        NSArray *dirContents = [fm contentsOfDirectoryAtPath:path error:&error];
        if (error) {
            DDLogError(@"Can't get content: %@", error.userInfo);
            return;
        }
        NSArray *texFiles = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"pathExtension like \"tex\""]];
        NSMutableArray *paths = [[NSMutableArray alloc] initWithCapacity:texFiles.count];
        for (NSString *file in texFiles) {
            [paths addObject:[path stringByAppendingPathComponent:file]];
        }
        [self.possibleDocuments setContent:paths];

    }


    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        if ([object isEqualTo:self.folderSelection]) {
            if (self.folderSelection.path != nil) {
                [self initializeContent];
            }
        }
    }

    - (void)configureProjectModel:(ProjectModel *)project
    {
        NSArray *paths = self.selectedDocuments.arrangedObjects;
        for (NSString *path in paths) {
            DocumentModel *model = [project modelForTexPath:path byCreating:YES];
            [project addMainDocument:model];
        }
    }

    - (void)dealloc
    {
        [self.folderSelection removeObserver:self forKeyPath:@"path"];
    }

@end
