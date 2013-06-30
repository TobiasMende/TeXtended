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

- (void)loadDocument:(DocumentModel*) document
{
    if(self.doc != document)
    {
        self.doc = document;
    }
    
    if(self.doc.project)
    {
        self.documentName = self.doc.project.name;
        self.documentType = @"Project";
        self.documentPath = self.doc.project.path;
        for(DocumentModel* model in self.doc.project.documents)
        {
            if ([[[model texName] pathExtension] isEqualToString:@"tex"])
            {
                [texDocs addObject:model];
            }
        }
    }
    else
    {
        self.documentName = self.doc.texName;
        self.documentType = @"Document";
        self.documentPath = self.doc.texPath;
    }
    [self.table reloadData];
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
