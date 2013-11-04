//
//  ConsoleWindowController.m
//  TeXtended
//
//  Created by Tobias Mende on 03.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleWindowController.h"
#import "ConsoleManager.h"
#import "TMTTableRowView.h"
#import "ConsoleCellView.h"
#import "TMTLog.h"
#import "Constants.h"
#import "ConsoleData.h"
#import "ConsoleViewController.h"


@interface ConsoleWindowController ()
- (void)updateData:(NSNotification *)note;
@end

@implementation ConsoleWindowController

- (id)init {
    self = [super initWithWindowNibName:@"ConsoleWindow"];
    if (self) {
        self.manager = [ConsoleManager sharedConsoleManager];
        [[NSNotificationCenter defaultCenter] addObserverForName:TMT_CONSOLE_MANAGER_CHANGED object:self.manager queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
            [self updateData:note];
        }];
    }
    return self;
}

- (void)updateData:(NSNotification *)note {
    self.consoleDatas = [[NSMutableArray alloc] initWithCapacity:self.manager.consoles.count];
    
    for (ConsoleData *data in self.manager.consoles.objectEnumerator) {
        if (data.showConsole) {
            [self.consoleDatas addObject:data];
        }
    }
    [self.consoleDatas sortUsingSelector:@selector(compareConsoleData:)];
    BOOL found = NO;
    NSUInteger currentRow;
    for (currentRow =0; currentRow < self.consoleDatas.count; currentRow++) {
        if ([[self.consoleDatas objectAtIndex:currentRow] isEqual:self.viewController.console]) {
            found = YES;
            break;
        }
    }
    [self.tableView reloadData];
    
    if (found) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:currentRow] byExtendingSelection:NO];
    }
    NSInteger row = [self.tableView selectedRow];
    if (row == -1) {
        self.viewController.console = nil;
    }
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.viewController = [ConsoleViewController new];
    self.contentView.contentView = self.viewController.view;
    [self.contentView setNeedsDisplay:YES];
    [self updateData:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


#pragma mark - Table View Data Source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.consoleDatas.count;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    TMTTableRowView *view = [tableView makeViewWithIdentifier:@"TMTTableRowView" owner:self];
    if (!view) {
        view = [TMTTableRowView new];
    }
    return view;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    ConsoleCellView *result = [tableView makeViewWithIdentifier:@"ConsoleCellView" owner:self];
    if (!result) {
        NSViewController *c = [[NSViewController alloc] initWithNibName:@"ConsoleCellView" bundle:nil];
        result = (ConsoleCellView*)c.view;
    }
    if (row < self.consoleDatas.count) {
        result.console = [self.consoleDatas objectAtIndex:row];
    }
    return result;
}

#pragma mark - Table View Delegate


- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [self.tableView selectedRow];
    if (row >= 0 && row < self.consoleDatas.count) {
        self.viewController.console = [self.consoleDatas objectAtIndex:row];
        [self.viewController scrollToCurrentPosition];
    }
}


# pragma mark - Actions

- (void)unhideConsoles:(id)sender {
    for (ConsoleData *data in self.manager.consoles.objectEnumerator) {
        if (!data.showConsole) {
            data.showConsole = YES;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
