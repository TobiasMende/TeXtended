//
//  TMTLatexTableModel.m
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTLatexTableModel.h"
#import "TMTLatexTableCellModel.h"

@interface TMTLatexTableModel ()

- (NSMutableArray *)emptyRow;
@end

@implementation TMTLatexTableModel

- (id)init {
    self = [super init];
    if (self) {
        _rows = [NSMutableArray new];
    }
    return self;
}


#pragma mark - Getter & Setter

- (TMTLatexTableCellModel *)cellForRow:(NSUInteger)rowIndex andColumn:(NSUInteger)columnIndex {
    if (self.rows.count <= rowIndex) {
        return nil;
    }
    NSArray *row = self.rows[rowIndex];
    if (row.count <= columnIndex) {
        return nil;
    }
    return row[columnIndex];
}

- (BOOL)setCell:(TMTLatexTableCellModel *)cell forRow :(NSUInteger)rowIndex andColumn:(NSUInteger)columnIndex {
    if (rowIndex >= self.rows.count || columnIndex >= [self.rows[rowIndex] count]) {
        return NO;
    }
    self.rows[rowIndex][columnIndex] = cell;
    return  YES;
}

- (void)setNumberOfRows:(NSUInteger)numberOfRows {
    if (numberOfRows == _numberOfRows) {
        return;
    }
    while (numberOfRows > _numberOfRows) {
        [self addRowAtIndex:_numberOfRows];
    }
    while (numberOfRows < _numberOfRows) {
        [self removeRowAtIndex:_numberOfRows];
    }
}

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns {
    if (numberOfColumns == _numberOfColumns) {
        return;
    }
    while (numberOfColumns > _numberOfColumns) {
        [self addColumnAtIndex:_numberOfColumns];
    }
    
    while (numberOfColumns < _numberOfColumns) {
        [self removeColumnAtIndex:_numberOfColumns];
    }
}

+ (BOOL)automaticallyNotifiesObserversOfNumberOfColumns {
    return NO;
}

+ (BOOL)automaticallyNotifiesObserversOfNumberOfRows {
    return NO;
}

- (void)addRowAtIndex:(NSUInteger)index {
    [self.rows insertObject:self.emptyRow atIndex:index];
    [self willChangeValueForKey:@"numberOfRows"];
    _numberOfRows++;
    [self didChangeValueForKey:@"numberOfRows"];
}

- (void)removeRowAtIndex:(NSUInteger)index {
    [self.rows removeObjectAtIndex:index];
    [self willChangeValueForKey:@"numberOfRows"];
    _numberOfRows--;
    [self didChangeValueForKey:@"numberOfRows"];
}

- (void)addColumnAtIndex:(NSUInteger)index {
    for (NSMutableArray *row in self.rows) {
        [row insertObject:[TMTLatexTableCellModel new] atIndex:index];
    }
    [self willChangeValueForKey:@"numberOfColumns"];
    _numberOfColumns++;
    [self didChangeValueForKey:@"numberOfColumns"];
}

- (void)removeColumnAtIndex:(NSUInteger)index {
    for (NSMutableArray *row in self.rows) {
        [row removeObjectAtIndex:index];
    }
    [self willChangeValueForKey:@"numberOfColumns"];
    _numberOfColumns--;
    [self didChangeValueForKey:@"numberOfColumns"];
}


#pragma mark - Private Methods
- (NSMutableArray *)emptyRow {
    NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:self.numberOfColumns];
    for(NSUInteger i = 0; i < self.numberOfColumns; i++) {
        [row addObject:[TMTLatexTableCellModel new]];
    }
    return row;
}

@end
