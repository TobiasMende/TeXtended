//
//  BracketHighlighter.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 10.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EditorService.h"
/**
 This class contains some algorithms for finding matching brackets and highlighting them.
 @author Tobias Mende
 @warning Be aware, that all positions in this interface are ment to be behind the bracket.
 
 */
@interface BracketHighlighter : EditorService {
    
    NSDate *lastAutoinsert;
}
@property BOOL shouldHighlightMatchingBrackets;
@property BOOL shouldAutoInsertClosingBrackets;


- (BOOL) shouldInsert:(NSString*)str;
/**
 Method for analyze the given input and highlight brackets according to matching rules.
 @param str the current input
 
 */
- (void) handleBracketsOnInsertWithInsertion:(NSString *) str;


/**
 Method for highlighting matching brackets for the given input.
 
 @param str the input
 */
- (NSArray*) highlightOnInsertWithInsertion:(NSString *) str;

/**
 Method for analyzing the surounding of the current caret position and for highlighting matching brackets, when moving caret to the left.
 */
- (void) highlightOnMoveLeft;

/**
 Method for analyzing the surounding of the current caret position and for highlighting matching brackets, when moving caret to the right.
 */
- (void) highlightOnMoveRight;


/**
 Method for only finding, not highlighting the matching bracket for a given input and position
 @param bracket the current input
 @param position the position after the input
 @param range the range to search in
 @return `nil` if no matches where found, an array containing two range values otherwise. In the second case, the first entry is the range value for the input and the second range value is the range of the matching bracket.
 */
- (NSArray *) findMatchingBracketFor:(NSString *) bracket
                           withStart:(NSUInteger) position
                             inRange:(NSRange) range;
@end
