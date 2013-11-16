//
//  MainAndBibFileSelectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainAndBibFileSelectionViewController.h"
#import "FolderSelectionViewController.h"

@interface MainAndBibFileSelectionViewController ()

@end

@implementation MainAndBibFileSelectionViewController

- (id)initWithFolderSelectionController:(FolderSelectionViewController*) folderSelection {
    self = [super initWithNibName:@"MainAndBibFileSelectionView" bundle:nil];
    if (self) {
        self.folderSelection = folderSelection;
    }
    return self;
}

@end
