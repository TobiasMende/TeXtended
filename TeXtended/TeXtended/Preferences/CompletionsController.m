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

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (![self shouldShowPopoverFor:tableView column:tableColumn]) {
        return YES;
    }
    NSLog(@"Should edit: %@, %li", tableColumn, row);
    if (popver) {
        [popver close];
    }
    popver = [self popoverForTable:tableView column:tableColumn row:row];
    NSCell *cell = [tableColumn dataCellForRow:row];
    NSRect rect = [tableView frameOfCellAtColumn:[tableView columnWithIdentifier:tableColumn.identifier] row:row];
    [popver showRelativeToRect:rect ofView:tableView preferredEdge:NSMaxYEdge];
    return NO;
}


- (BOOL)shouldShowPopoverFor:(NSTableView *)tableView column:(NSTableColumn *)column {
    if (tableView != self.environmentView) {
        return NO;
    }
    if ([column.identifier isEqualToString:@"extension"]) {
        return YES;
    }
    return NO;
}

- (NSPopover *)popoverForTable:(NSTableView *)tableView column:(NSTableColumn *)column row:(NSInteger)row {
    NSArray *completions = [self completionsForTable:tableView];
    if (row < 0 || row >= completions.count) {
        return nil;
    }
    NSPopover *popover = [NSPopover new];
    
    Completion * c = completions[row];
    
    
    MultiLineCellEditorViewController *vc = [[MultiLineCellEditorViewController alloc] initWithCompletion:c andKeyPath:column.identifier];
    popover.contentViewController = vc;
    popver.appearance =NSPopoverAppearanceHUD;
    popver.behavior = NSPopoverBehaviorTransient;
    popver.animates = YES;
    return popover;
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



    - (void)dealloc
    {
    }
@end
