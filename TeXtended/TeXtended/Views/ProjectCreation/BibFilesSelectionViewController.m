//
//  BibFilesSelectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "BibFilesSelectionViewController.h"
#import "FolderSelectionViewController.h"

@interface BibFilesSelectionViewController ()

@end

@implementation BibFilesSelectionViewController

- (id)initWithFolderSelectionController:(FolderSelectionViewController *)folderSelection {
    self = [super initWithNibName:@"BibFilesSelectionView" bundle:nil];
    if (self) {
        self.folderSelection = folderSelection;
    }
    return self;
}
@end
