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

static const NSString *FILE_KEY_PATH = @"fileURL";
static const NSString *WINDOW_KEY_PATH = @"window";
static NSArray *INTERNAL_EXTENSIONS;

@interface FileViewController ()

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
            [[PathObserverFactory pathObserverForPath:_path] addObserver:self withSelector:@selector(buildTree)];
            [self buildTree];
        }
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

#pragma mark - Context Menu Actions
- (void)menuNeedsUpdate:(NSMenu *)menu {
    NSInteger row = self.outlineView.clickedRow;
    if (row < 0) {
        [menu cancelTrackingWithoutAnimation];
        return;
    }
}


- (IBAction)openFile:(id)sender {
    FileNode *node = self.currentFileNode;
    NSString *extension = node.path.pathExtension;
    if ([INTERNAL_EXTENSIONS containsObject:extension] && [self.document isKindOfClass:[MainDocument class]]) {
        [[DocumentCreationController sharedDocumentController] showTexDocumentForPath:node.path withReferenceModel:[(MainDocument *)self.document model] andCompletionHandler:nil];
    } else {
        [[NSWorkspace sharedWorkspace] openFile:node.path];
    }
}

- (IBAction)renameFile:(id)sender {
}

- (IBAction)deleteFile:(id)sender {
}

- (IBAction)createNewFolder:(id)sender {
}

- (IBAction)createNewFile:(id)sender {
}

- (IBAction)revealInFinder:(id)sender {
}

- (IBAction)showInformation:(id)sender {
}

@end
