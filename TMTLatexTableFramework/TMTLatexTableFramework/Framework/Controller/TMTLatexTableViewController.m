//
//  TMTLatexTableViewController.m
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTLatexTableViewController.h"
#import "TMTLatexTableModel.h"
#import "TMTLatexTableCellModel.h"
#import "TMTLatexTableView.h"
#import "TMTLatexTableCellView.h"



@interface TMTLatexTableViewController ()
- (BOOL)rowIsValid:(NSInteger) rowIndex;
- (BOOL)columnIsValid:(NSInteger)columnIndex;
@end

@implementation TMTLatexTableViewController

- (id)init {
    self = [super initWithNibName:@"TMTLatexTableViewController" bundle:[NSBundle bundleForClass:[TMTLatexTableViewController class]]];
    if (self) {
        _model = [TMTLatexTableModel new];
        _model.numberOfColumns = 5;
        _model.numberOfRows = 5;
    }
    return self;
}



- (void)awakeFromNib {
    _tableView.target = self;
    _tableView.cmdArrowDownAction = @selector(addRowBelow:);
    _tableView.cmdArrowUpAction = @selector(addRowAbove:);
    _tableView.cmdArrowLeftAction = @selector(addColumnLeft:);
    _tableView.cmdArrowRightAction = @selector(addColumnRight:);
}

#pragma mark - Data Source Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (NSInteger)self.model.numberOfRows;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    if (![self rowIsValid:rowIndex]) {
        return nil;
    }
    if ([aTableColumn.identifier isEqualToString:@"rowNumber"]) {
        return [NSString stringWithFormat:@"%li", rowIndex+1];
    }
    NSUInteger columnIndex = [aTableView.tableColumns indexOfObject:aTableColumn]-1;
    if (![self columnIsValid:columnIndex]) {
        return nil;
    }
    return [self.model cellForRow:rowIndex andColumn:columnIndex];
    
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    TMTLatexTableCellModel *cellModel;
    if ([aTableColumn.identifier isEqualToString:@"rowNumber"]) {
        return;
    }
    if ([anObject isKindOfClass:[NSString class]]) {
        cellModel = [TMTLatexTableCellModel new];
        cellModel.content = anObject;
    } else if([anObject isKindOfClass:[TMTLatexTableCellModel class]]) {
        cellModel = anObject;
    } else {
        return;
    }
    NSUInteger columnIndex = [aTableView.tableColumns indexOfObject:aTableColumn]-1;
    if ([self rowIsValid:rowIndex] && [self columnIsValid:columnIndex]) {
        [self.model setCell:cellModel forRow:rowIndex andColumn:columnIndex];
    }
}

#pragma mark - Delegate Methods

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSUInteger columnIndex = [tableView.tableColumns indexOfObject:tableColumn];
    if (columnIndex == 0) {
        NSTableCellView *view = [tableView makeViewWithIdentifier:@"TMTLineNumberCellView" owner:self];
        view.objectValue = [NSString stringWithFormat:@"%li", row+1];
        return view;
    }
    
    // Get an existing cell with the MyView identifier if it exists
    TMTLatexTableCellView *result = [tableView makeViewWithIdentifier:@"TMTLatexTableCellView" owner:self];
    result.objectValue = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
    // Return the result
    return result;
    
}

#pragma mark - Table Actions

- (void)addRowBelow:(TMTLatexTableView *)sender {
    NSInteger selectedRow = [sender selectedRow];
    if (![self rowIsValid:selectedRow]) {
        NSBeep();
        return;
    }
    [self.model addRowAtIndex:selectedRow+1];
    [sender reloadData];
    [sender selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow+1] byExtendingSelection:NO];
}

- (void)addRowAbove:(TMTLatexTableView *)sender {
    NSInteger selectedRow = [sender selectedRow];
    if (![self rowIsValid:selectedRow]) {
        NSBeep();
        return;
    }
    [self.model addRowAtIndex:selectedRow];
    [sender reloadData];
    [sender selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
}

- (void)addColumnLeft:(TMTLatexTableView *)sender {
    NSInteger selectedColumn = sender.selectedColumn;
    if (![self columnIsValid:selectedColumn] || selectedColumn == 0) {
        NSBeep();
        return;
    }
    [self.model addColumnAtIndex:selectedColumn-1];
    [sender addTableColumnAtIndex:selectedColumn];
    [sender reloadData];
}

- (void)addColumnRight:(TMTLatexTableView *)sender {
    NSInteger selectedColumn = sender.selectedColumn;
    if (![self columnIsValid:selectedColumn] || selectedColumn >= self.model.numberOfColumns-1) {
        NSBeep();
        return;
    }
    
    [self.model addColumnAtIndex:selectedColumn];
    [sender addTableColumnAtIndex:selectedColumn+1];
    [sender reloadData];
}

#pragma mark - Private Methods

- (BOOL)rowIsValid:(NSInteger)rowIndex {
    return rowIndex >= 0 && rowIndex < self.model.numberOfRows;
}

- (BOOL)columnIsValid:(NSInteger)columnIndex {
    return columnIndex >= 0 && columnIndex < self.model.numberOfColumns && columnIndex != NSNotFound;
}




@end
