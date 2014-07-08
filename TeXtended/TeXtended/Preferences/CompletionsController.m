//
//  CompletionsController.m
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CompletionsController.h"
#import "CompletionManager.h"
#import "TMTArrayController.h"
#import "MultiLineCellEditorViewController.h"
#import "CompletionTableController.h"
#import <TMTHelperCollection/TMTTableViewDelegate.h>


@interface CompletionsController ()


@end

NSInteger commandTag = 1;

NSInteger environmentTag = 2;

NSInteger dropTag = 3;

CompletionsController *instance;

@implementation CompletionsController

    - (id)init
    {
        if (instance) {
            return instance;
        }
        self = [super init];
        if (self) {
            self.manager = [CompletionManager sharedInstance];
            instance = self;
        }
        return self;
    }

    + (CompletionsController *)sharedCompletionsController
    {
        if (!instance) {
            instance = [CompletionsController new];
        }
        return instance;
    }

- (BOOL)tableView:(TMTTableView *)tableView editColumn:(NSInteger)column row:(NSInteger)row withEvent:(NSEvent *)theEvent select:(BOOL)select {
    NSTableColumn *tableColumn = tableView.tableColumns[column];
    if (![self shouldShowPopoverFor:tableView column:tableColumn]) {
        return NO;
    }
    [self showPopoverForTable:tableView column:tableColumn row:row];

    return YES;
}


- (BOOL)shouldShowPopoverFor:(NSTableView *)tableView column:(NSTableColumn *)column {
    if ([column.identifier isEqualToString:@"extension"]) {
        return YES;
    }
    return NO;
}

- (void)showPopoverForTable:(NSTableView *)tableView column:(NSTableColumn *)column row:(NSInteger)row {
    
    NSArray *completions = [self completionsForTable:tableView];
    if (row < 0 || (NSUInteger)row >= completions.count) {
        return;
    }
    
    if (!popover) {
        popover = [NSPopover new];
        popover.behavior = NSPopoverBehaviorTransient;
        popover.animates = YES;
    }
    
    Completion * c = completions[row];
    
    
    MultiLineCellEditorViewController *vc = [[MultiLineCellEditorViewController alloc] initWithCompletion:c andKeyPath:column.identifier];
    popover.contentViewController = vc;
    vc.popover = popover;
    
    NSRect rect = [tableView frameOfCellAtColumn:[tableView columnWithIdentifier:column.identifier] row:row];
    [popover showRelativeToRect:rect ofView:tableView preferredEdge:NSMaxYEdge];
}

- (NSArray *)completionsForTable:(NSTableView *)tableView {
    if (tableView == self.environmentView) {
        return self.environmentsController.arrangedObjects;
    } else if(tableView == self.commandsView) {
        return self.commandsController.arrangedObjects;
    } else if(tableView == self.dropView) {
        return self.dropsController.arrangedObjects;
    } else {
        return nil;
    }
}
@end
