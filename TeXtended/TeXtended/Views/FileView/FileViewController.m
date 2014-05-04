//
//  FileViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 01.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "FileViewController.h"
#import <TMTHelperCollection/TMTLog.h>
#import "FileNode.h"
#import "DocumentCreationController.h"
#import "MainDocument.h"

#import <TMTHelperCollection/PathObserverFactory.h>
#import <TMTHelperCollection/TMTTextFieldDelegate.h>
#import <TMTHelperCollection/TMTTextField.h>

static const NSString *FILE_KEY_PATH = @"fileURL";
static const NSString *WINDOW_KEY_PATH = @"window";
static NSArray *INTERNAL_EXTENSIONS;

@interface FileViewController ()
- (MainDocument *)currentMainDocument;
- (NSString *)basePathForCreation:(NSString *)path;
- (void)createDirectoryInDirectory:(NSString *)path;
- (void)createFileInDirectory:(NSString *)path;
- (void)pathObserverBuildTree;
@end

@implementation FileViewController

+ (void)initialize {
    if ([self class]== [FileViewController class]) {
        INTERNAL_EXTENSIONS = @[@"tex", @"sty", @"cls"];
    }
}

- (id)init {
    return [self initWithNibName:@"FileView" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        pathObserverIsActive = YES;
    }
    return self;
}

- (void)setDocument:(NSDocument *)document {
    if (_document) {
        [_document removeObserver:self forKeyPath:FILE_KEY_PATH];
    }
    _document = document;
    if (_document) {
        [_document addObserver:self forKeyPath:FILE_KEY_PATH options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)setPath:(NSString *)path {
    if (![_path isEqualToString:path]) {
        if (_path) {
            [PathObserverFactory removeObserver:self];
        }
        _path = path;
        
        if (_path) {
            [[PathObserverFactory pathObserverForPath:_path] addObserver:self withSelector:@selector(pathObserverBuildTree)];
            [self buildTree];
        }
    }
}

- (void)pathObserverBuildTree {
    if (pathObserverIsActive) {
        [self buildTree];
    }
}

- (void)buildTree {
    NSError *error;
    FileNode *root = [FileNode fileNodeWithPath:self.path];
    self.contents = root.children;
    [self.fileTree rearrangeObjects];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:FILE_KEY_PATH]) {
        [self updatePath];
    }
}

- (void)updatePath {
    NSURL *url = self.document.fileURL;
    self.path = [url.path stringByDeletingLastPathComponent];
    DDLogWarn(@"Setting path: %@", self.path);
}

- (void)dealloc {
    [self.document removeObserver:self forKeyPath:FILE_KEY_PATH];
     [PathObserverFactory removeObserver:self];
}


- (FileNode *)currentFileNode {
    NSInteger row = self.outlineView.clickedRow < 0 ? self.outlineView.selectedRow : self.outlineView.clickedRow;
    if (row < 0) {
        return nil;
    }
    return [[self.outlineView itemAtRow:row] representedObject];
}

- (MainDocument *)currentMainDocument {
    if ([self.document isKindOfClass:[MainDocument class]]) {
        return self.document;
    }
    return nil;
}

- (NSString *)basePathForCreation:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    
    [fm fileExistsAtPath:path isDirectory:&isDir];
    
    return isDir ? path : [path stringByDeletingLastPathComponent];
    
}

#pragma mark - Text Delegates



- (void)controlTextDidEndEditing:(NSNotification *)obj {
    [self buildTree];    
    pathObserverIsActive = YES;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    DDLogInfo(@"Should?");
    return YES;
    
}

- (BOOL)control:(NSControl *)control isValidObject:(id)obj {
    FileNode *node = [self currentFileNode];
    NSString *basePath = [node.path stringByDeletingLastPathComponent];
    NSFileManager *fm = [NSFileManager defaultManager];
    return [obj length] > 0 && ![obj hasPrefix:@"."] && ([node.name isEqualTo:obj] || ! [fm fileExistsAtPath:[basePath stringByAppendingPathComponent:obj]]);
}

- (void) controlDidSelectText:(TMTTextField *)control {
    pathObserverIsActive = NO;
    NSText *editor = [self.view.window fieldEditor:YES forObject:control];
    NSString *base = [control.stringValue stringByDeletingPathExtension];
    [editor setSelectedRange:[control.stringValue rangeOfString:base]];
}

#pragma mark - Context Menu Actions


- (IBAction)openFile:(id)sender {
    FileNode *node = self.currentFileNode;
    NSString *extension = node.path.pathExtension;
    if ([INTERNAL_EXTENSIONS containsObject:extension] && [self.document isKindOfClass:[MainDocument class]]) {
        [[DocumentCreationController sharedDocumentController] showTexDocumentForPath:node.path withReferenceModel:[(MainDocument *)self.document model] andCompletionHandler:nil];
    } else {
        [[NSWorkspace sharedWorkspace] openFile:node.path];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (!self.currentMainDocument) {
        return [super respondsToSelector:aSelector];
    }
    if (aSelector == @selector(deleteFile:)) {
        FileNode *node = self.currentFileNode;
        MainDocument *md = self.currentMainDocument;
        return  node && md && ![md.model.path isEqualToString:node.path];
    }
    
    return [super respondsToSelector:aSelector];
}

- (IBAction)renameFile:(id)sender {
    NSInteger row = self.outlineView.clickedRow < 0 ? self.outlineView.selectedRow : self.outlineView.clickedRow;
    if (row < 0) {
        NSBeep();
        return;
    }
    [self.outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    
    [self.outlineView editColumn:0 row:row withEvent:nil select:YES];
    // TODO: finish implementation
    
}



- (IBAction)deleteFile:(id)sender {
    FileNode *node = self.currentFileNode;
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Delete File?", @"Delete File Alert Title") defaultButton:NSLocalizedString(@"Delete", @"Delete Button") alternateButton:NSLocalizedString(@"Cancel", @"Cancel Button") otherButton:nil informativeTextWithFormat:NSLocalizedString(@"Are you sure to delete the file %@", @""), node.path.lastPathComponent];
    alert.icon = node.icon;
    NSModalResponse response = [alert runModal];
    
    if (response == NSAlertDefaultReturn) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:node.path error:&error];
        if (error) {
            [[NSAlert alertWithError:error] runModal];
        }
    }
    
    
}

- (IBAction)createNewFile:(id)sender {
    FileNode *node = self.currentFileNode;
    NSString *path = [self basePathForCreation:node.path];
    [self createFileInDirectory:path];
}

- (void)createNewFileInRoot:(id)sender {
    [self createFileInDirectory:self.path];
}

- (void)createFileInDirectory:(NSString *)path {
    
}

- (IBAction)createNewFolder:(id)sender {
    FileNode *node = self.currentFileNode;
    NSString *path = [self basePathForCreation:node.path];
    [self createDirectoryInDirectory:path];
}


- (void)createNewFolderInRoot:(id)sender {
    [self createDirectoryInDirectory:self.path];
}

- (void)createDirectoryInDirectory:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *base = NSLocalizedString(@"Untitled Folder", @"");
    NSString *name = [NSString stringWithString:base];
    NSUInteger idx = 2;
    while ([fm fileExistsAtPath:[path stringByAppendingPathComponent:name]]) {
        name = [NSString stringWithFormat:@"%@ %li", base, idx];
        idx ++;
    }
    NSString *totalPath = [path stringByAppendingPathComponent:name];
    NSError *error;
    [fm createDirectoryAtPath:totalPath withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
        [[NSAlert alertWithError:error] runModal];
    } else {
        // TODO: implement
    }
}

- (IBAction)revealInFinder:(id)sender {
    FileNode *node = self.currentFileNode;
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:node.path]]];
}

- (void)openRootInFinder:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:self.path];
}

- (IBAction)showInformation:(id)sender {
    // TODO: implement
}

@end
