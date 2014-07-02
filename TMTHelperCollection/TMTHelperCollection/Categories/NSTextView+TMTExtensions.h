//
//  NSTextView+TMTExtensions.h
//  TMTHelperCollection
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (TMTExtensions)
/**
 Getter for the visible range
 @return the visible range
 */
- (NSRange)visibleRange;


/** Getter for the currently selected column
 
 @return the selected column
 */
- (NSUInteger)currentCol;

/** Getter for the column for the selected range
 @param range the range to get the column for.
 
 @return the column of the provided ranges location
 */
- (NSUInteger)colForRange:(NSRange)range;

- (NSUInteger)characterIndexOfPoint:(NSPoint)aPoint;

- (void)skipClosingBracket;
#pragma mark - Line Getter
- (NSRect)lineRectforRange:(NSRange)r;


@end
