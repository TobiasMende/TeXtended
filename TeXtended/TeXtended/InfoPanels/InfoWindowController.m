//
//  InfoWindowController.m
//  TeXtended
//
//  Created by Tobias Hecht on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "InfoWindowController.h"
#import "DocumentModel.h"
#import "ProjectModel.h"
#import "CompileFlowHandler.h"
#import "Compilable.h"

@interface InfoWindowController ()

@end

@implementation InfoWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
    }
    
    return self;
}

- (id)init {
    self = [super initWithWindowNibName:@"InfoWindow"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)setDocument:(DocumentModel *)document {
    [self willChangeValueForKey:@"doc"];
    _doc = document;
    [self didChangeValueForKey:@"doc"];
    self.mainCompilabel = document.project? document.project : document;
}

- (void)setMainCompilabel:(Compilable *)mainCompilabel {
    if (_mainCompilabel) {
        [self.mainCompilabel removeObserver:self forKeyPath:@"path"];
    }
    [self willChangeValueForKey:@"mainCompilabel"];
    _mainCompilabel = mainCompilabel;
    [self didChangeValueForKey:@"mainCompilabel"];
    if (_mainCompilabel) {
        [self.mainCompilabel addObserver:self forKeyPath:@"path" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    }
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(self.doc)
    {
        return [[self.doc mainDocuments ] count];
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [[[[[self.doc mainDocuments] allObjects] objectAtIndex:rowIndex] texName] stringByDeletingPathExtension];
}

- (IBAction)addMainDocument:(id)sender
{
    NSLog(@"Add Main Document");
}

- (IBAction)removeMainDocument:(id)sender
{
    NSLog(@"Remove Main Document");
    NSMutableArray* mainDocs = [[self.doc.mainDocuments allObjects] mutableCopy];
    [mainDocs removeObjectAtIndex:[self.table selectedRow]];
    self.doc.mainDocuments = [NSSet setWithArray:mainDocs];
    [self.table reloadData];
}

@end
