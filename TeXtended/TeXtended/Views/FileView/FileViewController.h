//
//  FileViewController.h
//  TeXtended
//
//  Created by Tobias Mende on 01.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <TMTHelperCollection/TMTTextFieldDelegate.h>
@class FileNode, FileOutlineView;
@interface FileViewController : NSViewController <NSOutlineViewDelegate,NSMenuDelegate, NSControlTextEditingDelegate> {
    BOOL pathObserverIsActive;
}
@property (strong) IBOutlet NSTreeController *fileTree;
@property (nonatomic) NSString *path;
@property (assign,nonatomic) NSDocument *document;
@property NSMutableArray *contents;
@property (strong) IBOutlet FileOutlineView *outlineView;

- (void) updatePath;
- (void) buildTree;
- (FileNode *)currentFileNode;


#pragma mark - Context Menu Actions
- (IBAction)openFile:(id)sender;
- (IBAction)renameFile:(id)sender;
- (IBAction)deleteFile:(id)sender;
- (IBAction)createNewFolder:(id)sender;
- (IBAction)createNewFile:(id)sender;
- (IBAction)createNewFolderInRoot:(id)sender;
- (IBAction)createNewFileInRoot:(id)sender;
- (IBAction)revealInFinder:(id)sender;
- (IBAction)openRootInFinder:(id)sender;
- (IBAction)showInformation:(id)sender;

@end
