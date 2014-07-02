//
//  NSString+TMTExtension.h
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TMTExtensions)

    - (NSArray *)tmplineRanges;

    - (NSUInteger)lineNumberForRange:(NSRange)range;

    - (NSUInteger)numberOfLines;

    - (NSRange)rangeForLine:(NSUInteger)index;

    - (NSRange)lineRangeForPosition:(NSUInteger)position;

/**
 Getter for the line range for a provided range
 
 @param range the range to get the entire line range without line terminator.
 
 @return the containing line range or a range of multiple lines if the provided range was bigger than a single line.
 */
- (NSRange)lineTextRangeWithRange:(NSRange)range;


/**
 Getter for the line range for a provided range
 
 @param range the range to get the entire line range.
 @param flag if `YES`, the range contains the line termiantor at the end.
 
 @return the containing line range or a range of multiple lines if the provided range was bigger than a single line.
 */
- (NSRange)lineTextRangeWithRange:(NSRange)range withLineTerminator:(BOOL)flag;

/**
 Method returns the white space at the beginning of a given line (Usefull for auto-indention)
 
 @param lineRange the line
 
 @return The whitespaces at the line beginning.
 */
- (NSString *)whiteSpacesAtLineBeginning:(NSRange)lineRange;

- (NSRange)extendRange:(NSRange)range byLines:(NSUInteger)numLines;
@end
