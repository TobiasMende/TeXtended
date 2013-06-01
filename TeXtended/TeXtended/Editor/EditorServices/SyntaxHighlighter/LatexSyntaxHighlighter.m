//
//  RegexHighlighter.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "LatexSyntaxHighlighter.h"
#import "HighlightingTextView.h"
NSString *INLINE_MATH_PATTERN, *COMMAND_PATTERN, *CURLY_BRACKET_PATTERN, *COMMENT_PATTERN, *BRACKET_PATTERN;
NSRegularExpression *INLINE_MATH_REGEX, *COMMAND_REGEX, *CURLY_BRACKET_REGEX, *COMMENT_REGEX, *BRACKET_REGEX;


@implementation LatexSyntaxHighlighter


#pragma mark Initialization

+ (void)initialize {
        // In this section,
    COMMAND_PATTERN = @"\\\\[a-zA-Z0-9@_]+|\\\\\\\\";
    
    INLINE_MATH_PATTERN = @"(\\$(?:[^\\$]+)\\$)|(\\\\\\[(?:[^\\$]+)\\\\\\])|(\\$\\$(?:[^\\$]+)\\$\\$)";
    
    CURLY_BRACKET_PATTERN = @"(\\{|\\})";
    
    COMMENT_PATTERN = @"(?:%.*)";
    
    BRACKET_PATTERN = @"(?:\\(|\\)|\\[|\\]|\\\\\\{|\\\\\\})";
    
    NSError *error;
        //Regular Expression
    INLINE_MATH_REGEX = [NSRegularExpression regularExpressionWithPattern:INLINE_MATH_PATTERN options:NSRegularExpressionCaseInsensitive error:&error];
    COMMAND_REGEX = [NSRegularExpression regularExpressionWithPattern:COMMAND_PATTERN options:NSRegularExpressionCaseInsensitive error:&error];
    CURLY_BRACKET_REGEX = [NSRegularExpression regularExpressionWithPattern:CURLY_BRACKET_PATTERN options:NSRegularExpressionCaseInsensitive error:&error];
    COMMENT_REGEX = [NSRegularExpression regularExpressionWithPattern:COMMENT_PATTERN options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:&error];
    BRACKET_REGEX = [NSRegularExpression regularExpressionWithPattern:BRACKET_PATTERN options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        NSLog(@"Error!");
    }
    
}


- (id)initWithTextView:(HighlightingTextView *)tv {
    self = [super initWithTextView:tv];
    if(self) {
        [self registerDefaults];
        [[NSNotificationCenter defaultCenter] addObserverForName:NSTextViewDidChangeSelectionNotification object:view queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            if (!view.servicesOn) {
                return;
            }
            [self highlightVisibleArea];
        }];
    }
    return self;
}

- (void) registerDefaults {
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    /*
        Initial setup of the highlighting colors
     */
    
    self.inlineMathColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_INLINE_MATH_COLOR]];
    [self bind:@"inlineMathColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_INLINE_MATH_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
    
    self.commandColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMAND_COLOR]];
    [self bind:@"commandColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_COMMAND_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
    
    self.bracketColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_BRACKET_COLOR]];
    [self bind:@"bracketColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_BRACKET_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
    
    self.curlyBracketColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_ARGUMENT_COLOR]];
    [self bind:@"curlyBracketColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_ARGUMENT_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
    
    self.commentColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMENT_COLOR]];
    [self bind:@"commentColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_COMMENT_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
    
    /*
        Initial setup of the highlighting flags
     */
    self.shouldHighlightInlineMath = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_INLINE_MATH] boolValue];
    [self bind:@"shouldHighlightInlineMath" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_INLINE_MATH] options:NULL];
    
    self.shouldHighlightCommands = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_COMMANDS] boolValue];
    [self bind:@"shouldHighlightCommands" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_COMMANDS] options:NULL];
    
    self.shouldHighlightComments = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_COMMENTS] boolValue];
    [self bind:@"shouldHighlightComments" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_COMMENTS] options:NULL];
    
    self.shouldHighlightBrackets = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_BRACKETS] boolValue];
    [self bind:@"shouldHighlightBrackets" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_BRACKETS] options:NULL];
    
    self.shouldHighlightArguments = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_ARGUMENTS] boolValue];
    [self bind:@"shouldHighlightArguments" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_ARGUMENTS] options:NULL];
}


# pragma mark Change Handling

- (void) handleColorChange {
    [self invalidateHighlighting];
    [self highlightVisibleArea];
}

- (void)invalidateHighlighting {
    NSLayoutManager *lm = [view layoutManager];
    NSRange textRange = NSMakeRange(0, [[view textStorage] length]);
    [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:textRange];
}


# pragma mark -
# pragma mark Highlighting Methods


- (void)highlightEntireDocument {
    NSRange textRange = NSMakeRange(0, [[view textStorage] length]);
    [self highlightRange:textRange];
}

- (void)highlightNarrowArea {
    //TODO: online highlight +- 5 lines;
    [self highlightVisibleArea];
}

- (void)highlightVisibleArea {
    NSLayoutManager *lm = [view layoutManager];
    NSRect visibleArea = [view visibleRect];
    NSRange visibleGlyphRange = [lm glyphRangeForBoundingRect:visibleArea inTextContainer:view.textContainer];
    NSRange visibleTextRange = [lm characterRangeForGlyphRange:visibleGlyphRange actualGlyphRange:NULL];
    
    [self highlightRange:visibleTextRange];
}

- (void) highlightRange:(NSRange)range {
    [[view layoutManager] removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
    [self performHighlightingInRange:range];
}

# pragma mark Private Highlighting Methods


/**
 Method for calling all highlighting methods in a proper order
 
 */
- (void) performHighlightingInRange:(NSRange) textRange {
    [self highlightMathBracketsInRange:textRange];
    [self highlightCommandInRange:textRange];
    [self highlightCurlyBracketsInRange:textRange];
    [self highlightCommentInRange:textRange];
    [self highlightInlineMathInRange:textRange];
}

- (void) highlightCommandInRange:(NSRange) totalRange {
    if (self.shouldHighlightCommands) {
        [self highlightForegroundWithExpression:COMMAND_REGEX andColor:self.commandColor inRange:totalRange];
    }
}

- (void) highlightMathBracketsInRange:(NSRange) totalRange {
    if (self.shouldHighlightBrackets) {
        [self highlightForegroundWithExpression:BRACKET_REGEX andColor:self.bracketColor inRange:totalRange];
    }
}

- (void) highlightCurlyBracketsInRange:(NSRange) totalRange {
    if (self.shouldHighlightArguments) {
        [self highlightForegroundWithExpression:CURLY_BRACKET_REGEX andColor:self.curlyBracketColor inRange:totalRange];
    }
}

- (void) highlightInlineMathInRange:(NSRange) totalRange {
    if (self.shouldHighlightInlineMath) {
        [self highlightForegroundWithExpression:INLINE_MATH_REGEX andColor:self.inlineMathColor inRange:totalRange];
    }
}

- (void) highlightCommentInRange:(NSRange) totalRange {
    if (self.shouldHighlightComments) {
         NSLayoutManager *lm = [view layoutManager];
        NSArray *matches = [COMMENT_REGEX matchesInString:[[view textStorage] string] options:0 range:totalRange];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match range];
            if (range.location > 0 && [[view.string substringWithRange:NSMakeRange(range.location-1, 1)] isEqualToString:@"\\"]) {
                continue;
            }
            [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
            [lm addTemporaryAttribute:NSForegroundColorAttributeName value:self.commentColor forCharacterRange:range];
        }
    }
    
}


/**
 Highlights the foreground font of substrings matching the given regular expression in the given range with the given foreground color. 
 */

- (void) highlightForegroundWithExpression:(NSRegularExpression*)regex andColor:(NSColor*) color inRange:(NSRange) totalRange {
    NSLayoutManager *lm = [view layoutManager];
    
        
        NSArray *matches = [regex matchesInString:[[view textStorage] string] options:0 range:totalRange];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match range];
            [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
            [lm addTemporaryAttribute:NSForegroundColorAttributeName value:color forCharacterRange:range];
        }
}




#pragma mark -
# pragma mark Setter & Getter

#pragma mark Color Setter

- (void)setInlineMathColor:(NSColor *)inlineMathColor {
    _inlineMathColor = inlineMathColor;
    [self handleColorChange];
}

- (void)setCommandColor:(NSColor *)commandColor {
    _commandColor = commandColor;
    [self handleColorChange];
}

- (void)setBracketColor:(NSColor *)bracketColor {
    _bracketColor = bracketColor;
    [self handleColorChange];
}


- (void)setCurlyBracketColor:(NSColor *)curlyBracketColor {
    _curlyBracketColor = curlyBracketColor;
    [self handleColorChange];
}

- (void)setCommentColor:(NSColor *)commentColor {
    _commentColor = commentColor;
    [self handleColorChange];
}

#pragma mark Flag Setter

- (void)setShouldHighlightArguments:(BOOL)shouldHighlightArguments {
    _shouldHighlightArguments = shouldHighlightArguments;
    [self handleColorChange];
}

- (void)setShouldHighlightBrackets:(BOOL)shouldHighlightBrackets {
    _shouldHighlightBrackets = shouldHighlightBrackets;
    [self handleColorChange];
}

- (void)setShouldHighlightCommands:(BOOL)shouldHighlightCommands {
    _shouldHighlightCommands = shouldHighlightCommands;
    [self handleColorChange];
}

- (void)setShouldHighlightComments:(BOOL)shouldHighlightComments {
    _shouldHighlightComments = shouldHighlightComments;
    [self handleColorChange];
}

- (void)setShouldHighlightInlineMath:(BOOL)shouldHighlightInlineMath {
    _shouldHighlightInlineMath = shouldHighlightInlineMath;
    [self handleColorChange];
}


#pragma mark -
#pragma mark Dealloc

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark -
#pragma mark Regex Getter

+ (NSRegularExpression *)commandExpression {
    return COMMAND_REGEX;
}


@end
