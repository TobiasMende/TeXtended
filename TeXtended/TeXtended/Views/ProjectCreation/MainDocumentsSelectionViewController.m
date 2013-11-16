//
//  MainDocumentsSelectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainDocumentsSelectionViewController.h"
#import "FolderSelectionViewController.h"

@interface MainDocumentsSelectionViewController ()

@end

@implementation MainDocumentsSelectionViewController

- (id)initWithFolderSelectionController:(FolderSelectionViewController *)folderSelection {
    self = [super initWithNibName:@"MainDocumentsSelectionView" bundle:nil];
    if (self) {
        self.folderSelection = folderSelection;
    }
    return self;
}

- (IBAction)addDocument:(id)sender {
}

- (IBAction)removeDocument:(id)sender {
}

- (IBAction)createDocument:(id)sender {
}

@end
