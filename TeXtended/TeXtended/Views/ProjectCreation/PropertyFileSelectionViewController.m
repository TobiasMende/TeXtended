//
//  PropertyFileSelectionViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "PropertyFileSelectionViewController.h"
#import "FolderSelectionViewController.h"
@interface PropertyFileSelectionViewController ()

@end

@implementation PropertyFileSelectionViewController

- (id)initWithFolderSelectionController:(FolderSelectionViewController *)folderSelection {
    self = [super initWithNibName:@"PropertyFileSelectionView" bundle:nil];
    if(self) {
        self.folderSelection = folderSelection;
    }
    return self;
}

- (IBAction)select:(id)sender {
}

@end
