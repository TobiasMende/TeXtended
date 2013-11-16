//
//  MainDocumentsSelectionViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FolderSelectionViewController;
@interface MainDocumentsSelectionViewController : NSViewController
@property (strong) IBOutlet NSTableColumn *selectedDocuments;
@property (strong) IBOutlet NSTableView *possibleDocuments;
@property FolderSelectionViewController *folderSelection;
- (id)initWithFolderSelectionController:(FolderSelectionViewController*) folderSelection;

- (IBAction)addDocument:(id)sender;
- (IBAction)removeDocument:(id)sender;
- (IBAction)createDocument:(id)sender;

@end
