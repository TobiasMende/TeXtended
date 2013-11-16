//
//  MainAndBibFileSelectionViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FolderSelectionViewController;
@interface MainAndBibFileSelectionViewController : NSViewController
@property FolderSelectionViewController *folderSelection;
- (id)initWithFolderSelectionController:(FolderSelectionViewController*) folderSelection;
@end
