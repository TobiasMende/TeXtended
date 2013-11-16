//
//  PropertyFileSelectionViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class FolderSelectionViewController;
@interface PropertyFileSelectionViewController : NSViewController

@property (strong) IBOutlet NSString* filePath;

@property FolderSelectionViewController *folderSelection;
- (id)initWithFolderSelectionController:(FolderSelectionViewController*) folderSelection;

- (IBAction)select:(id)sender;

@end
