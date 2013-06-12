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
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMinimum:self.CompilerFlowHandlerObj.minIterations];
    [formatter setMaximum:self.CompilerFlowHandlerObj.maxIterations];
    [self.DraftIt setFormatter:formatter];
    [self.FinalIt setFormatter:formatter];
    [self.LiveIt setFormatter:formatter];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)loadDocument:(DocumentModel*) document
{
    if(self.doc != document)
        self.doc = document;
    [self.table reloadData];
    if(self.doc.project)
    {
        [self.lblName setStringValue:self.doc.project.name];
        NSString *compileText;
        if(self.doc.lastCompile)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd, yyyy - HH:mm"];
            compileText = [formatter stringFromDate:self.doc.lastCompile];
        }
        else
            compileText = [NSString stringWithFormat:@"-"];
        [self.lblCompile setStringValue:compileText];
        
        NSString *changedText;
        if(self.doc.lastChanged)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd, yyyy - HH:mm"];
            changedText = [formatter stringFromDate:self.doc.lastChanged];
        }
        else
            changedText = [NSString stringWithFormat:@"-"];
        [self.lblChange setStringValue:changedText];
        [self.lblType setStringValue:@"Project"];
        [self.lblPath setStringValue:self.doc.project.path];
    }
    else
    {
        [self.lblName setStringValue:self.doc.texName];
        NSString *compileText;
        if(self.doc.lastCompile)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd, yyyy - HH:mm"];
            compileText = [formatter stringFromDate:self.doc.lastCompile];
        }
        else
            compileText = [NSString stringWithFormat:@"-"];
        [self.lblCompile setStringValue:compileText];
        
        NSString *changedText;
        if(self.doc.lastChanged)
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd, yyyy - HH:mm"];
            changedText = [formatter stringFromDate:self.doc.lastChanged];
        }
        else
            changedText = [NSString stringWithFormat:@"-"];
        [self.lblChange setStringValue:changedText];
        [self.lblType setStringValue:@"Document"];
        [self.lblPath setStringValue:self.doc.texPath];
    }
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(self.doc)
    {
        return [[self.doc mainDocuments ]count];
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    return [[[self.doc mainDocuments] allObjects] objectAtIndex:rowIndex];
}

@end
