//
//  TexdocViewController.m
//  TeXtended
//
//  Created by Tobias Mende on 23.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TexdocViewController.h"
#import "TexdocEntry.h"
#import <TMTHelperCollection/TMTTableView.h>

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

    - (id)init
    {
        self = [self initWithNibName:@"TexdocView" bundle:nil];
        if (self) {
        }
        return self;
    }

    - (void)awakeFromNib
    {
        if (!entries || entries.count == 0) {
            [self setView:notFoundView];
        } else {
            [self.listView setEnterAction:@selector(click:)];
            [self.listView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        }

    }

    - (void)setContent:(NSMutableArray *)texdoc
    {
        if (texdoc.count > 0) {
            entries = texdoc;
            if (self.listView) {
                [self.listView reloadData];
            }
        }
    }

    - (IBAction)click:(id)sender
    {
        [self openSelectedDoc];
    }

    - (void)setPackage:(NSString *)package
    {
        NSString *head = [@"Select Documentation for " stringByAppendingFormat:@"%@:", package];
        _package = head;
    }


    - (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
    {
        return entries.count;
    }


    - (void)setDarkBackgroundMode
    {
        [self.label setTextColor:[NSColor controlLightHighlightColor]];
    }

    - (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
    {
        NSString *identifier = [tableColumn identifier];
        TexdocEntry *entry = entries[row];
        return [entry valueForKey:identifier];
    }


    - (void)openSelectedDoc
    {
        NSInteger row = [self.listView selectedRow];
        if (row >= 0 && (NSUInteger)row < entries.count) {
            TexdocEntry *entry = entries[row];
            NSURL *url = [NSURL fileURLWithPath:entry.path];
            [[NSWorkspace sharedWorkspace] openURL:url];
        }
    }

    - (IBAction)label:(id)sender
    {
    }
@end
