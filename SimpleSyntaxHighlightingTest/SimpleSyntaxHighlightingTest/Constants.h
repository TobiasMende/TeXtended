//
//  Constants.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 10.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 KVC keys for NSColor objects (used for user defaults)
 */
#define TMT_INLINE_MATH_COLOR @"TMTInlineMathColor"
#define TMT_COMMAND_COLOR @"TMTCommandColor"
#define TMT_COMMENT_COLOR @"TMTCommentColor"
#define TMT_BRACKET_COLOR @"TMTBracketColor"
#define TMT_ARGUMENT_COLOR @"TMTArgumentColor"

/*
 KVC keys for boolean flags (used for user defaults) 
 */
#define TMT_SHOULD_HIGHLIGHT_INLINE_MATH @ "TNTShouldHighlightInlineMath"
#define TMT_SHOULD_HIGHLIGHT_COMMANDS @ "TMTShouldHighlightCommand"
#define TMT_SHOULD_HIGHLIGHT_COMMENTS @ "TMTShouldHighlightComment"
#define TMT_SHOULD_HIGHLIGHT_BRACKETS @ "TMTShouldHighlightBracket"
#define TMT_SHOULD_HIGHLIGHT_ARGUMENTS @ "TMTShouldHighlightArgument"

/**
    This class is our common place for constants and other global definitions.
    E.g. keys used in the user defaults are defined here as global macros.
 
 \author Tobias Mende
 */
@interface Constants : NSObject

@end
