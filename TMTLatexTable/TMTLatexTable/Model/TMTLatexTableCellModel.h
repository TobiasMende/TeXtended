//
//  TMTLatexTableCellModel.h
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _TMTLatexTableCellAlignment {
    LEFT,
    RIGHT,
    CENTER
} TMTLatexTableCellAlignment;

typedef enum _TMTLatexTableCellBorder {
    NONE,
    SINGLE,
    DOUBLE
} TMTLatexTableCellBorder;

@interface TMTLatexTableCellModel : NSObject

@property NSString *content;


#pragma mark - Cell Merging
@property NSUInteger numberOfRightCells;
@property NSUInteger numberOfBelowCells;


#pragma mark - Cell Borders

@property TMTLatexTableCellBorder leftBorder;
@property TMTLatexTableCellBorder rightBorder;
@property TMTLatexTableCellBorder bottomBorder;
@property TMTLatexTableCellBorder topBorder;

#pragma mark - Cell Appearence

@property TMTLatexTableCellAlignment alignment;
@property NSColor *backgroundColor;

@end
