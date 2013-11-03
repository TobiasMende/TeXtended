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

@end

@implementation ConsoleWindowController

- (id)init {
    self = [super initWithWindowNibName:@"ConsoleWindow"];
    self.manager = [ConsoleManager sharedConsoleManager];
    [[NSNotificationCenter defaultCenter] addObserverForName:TMT_CONSOLE_MANAGER_CHANGED object:self.manager queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        [self.tableView reloadData];
    }];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


#pragma mark - Table View Data Source
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.manager.consoles.count;
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
    if (row < self.manager.consoles.count) {
        result.console = [[self.manager.consoles allValues] objectAtIndex:row];
    }
    return result;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 35.0;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger row = [self.tableView selectedRow];
    if (row >= 0 && row < self.manager.consoles.count) {
        ConsoleData *data = [[self.manager.consoles allValues] objectAtIndex:row];
        self.contentView.contentView = data.viewController.view;
    }
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
