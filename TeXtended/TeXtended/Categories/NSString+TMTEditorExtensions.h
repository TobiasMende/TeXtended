//
//  NSString+TMTEditorExtensions.h
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TMTEditorExtensions)

/**
 Builds a string representing a single tab
 @return a string containing \t if ![self shouldUseSpacesAsTabs] or a string containing [self numberOfSpacesForTab] spaces otherwise.
 */
+ (NSString *)singleTab;

/**
 Builds a string representing a line break at the current cursor position in the text view
 @return a string containing whitespaces for the line break and for preserving the indention
 */
- (NSString *)lineBreakForPosition:(NSUInteger)position;
@end
