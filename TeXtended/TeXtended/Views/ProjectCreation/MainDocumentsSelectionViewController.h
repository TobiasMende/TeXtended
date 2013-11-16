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
@property (strong) IBOutlet NSTableView *possibleDocumentsTable;
@property (strong) IBOutlet NSTableView *selectedDocumentsTable;
@property (strong) IBOutlet NSArrayController *possibleDocuments;
@property (strong) IBOutlet NSArrayController *selectedDocuments;
@property FolderSelectionViewController *folderSelection;
- (id)initWithFolderSelectionController:(FolderSelectionViewController*) folderSelection;

- (IBAction)addDocument:(id)sender;
- (IBAction)removeDocument:(id)sender;
- (IBAction)createDocument:(id)sender;

@end
