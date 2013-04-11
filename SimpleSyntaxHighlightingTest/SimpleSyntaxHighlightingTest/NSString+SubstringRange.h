//
//  NSTextStorage+SubstringRange.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
/**
 This category extends a NSString to provide a substringWithRange method. 
 \author Tobias Mende
 */
@interface NSString (SubstringRange)
/**
 Method for getting a substring bei range.
 
 \param range the range to get the substring for
 \return the substring
 \throw <Invalid substring range> if the provided range is out of bounds.
 */
- (NSString *) substringWithRange:(NSRange) range;
@end
