//
//  TexdocViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TexdocViewController.h"
#import "TexdocEntry.h"

@interface TexdocViewController ()

@end

@implementation TexdocViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib {
    if (!entries || entries.count == 0) {
        [self setView:notFoundView];
    }
}

- (void)setContent:(NSMutableArray *)texdoc {
    if (texdoc.count >0) {
        entries = texdoc;
        if (listView) {
            [listView reloadData];
        }
    } 
}

- (id)init {
    self = [self initWithNibName:@"TexdocView" bundle:nil];
    if (self) {
    }
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return entries.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    TexdocEntry *entry = [entries objectAtIndex:row];
    return [entry valueForKey:identifier];
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
    
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSUInteger row = [listView selectedRow];
    if (row < entries.count) {
        TexdocEntry *entry = [entries objectAtIndex:row];
        NSURL *url = [NSURL fileURLWithPath:entry.path];
        [[NSWorkspace sharedWorkspace] openURL: url];
    }
}

@end
