//
//  TMTLatexTableModel.h
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMTLatexTableCellModel;
@interface TMTLatexTableModel : NSObject

@property (readonly) NSMutableArray *rows;
@property (nonatomic) NSUInteger numberOfRows;
@property (nonatomic) NSUInteger numberOfColumns;

@property NSColor *rowColor1;
@property NSColor *rowColor2;


- (TMTLatexTableCellModel *) cellForRow:(NSUInteger)row andColumn:(NSUInteger)column;
- (BOOL)setCell:(TMTLatexTableCellModel *)cell forRow:(NSUInteger)rowIndex andColumn:(NSUInteger)columnIndex;

- (void)addRowAtIndex:(NSUInteger)index;
- (void)removeRowAtIndex:(NSUInteger)index;
- (void)addColumnAtIndex:(NSUInteger)index ;
- (void)removeColumnAtIndex:(NSUInteger)index;

@end
