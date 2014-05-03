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

static const NSString *FILE_KEY_PATH = @"fileURL";
static const NSString *WINDOW_KEY_PATH = @"window";

@interface FileViewController ()

@end

@implementation FileViewController

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
    _path = path;
    
    if (_path) {
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
}


@end
