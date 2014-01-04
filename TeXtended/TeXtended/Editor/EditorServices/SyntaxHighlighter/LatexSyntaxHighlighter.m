//
//  RegexHighlighter.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "LatexSyntaxHighlighter.h"
#import "HighlightingTextView.h"
#import "CodeExtensionEngine.h"
#import "CodeNavigationAssistant.h"
#import <TMTHelperCollection/TMTLog.h>

static NSString *INLINE_MATH_PATTERN, *COMMAND_PATTERN, *CURLY_BRACKET_PATTERN, *COMMENT_PATTERN, *BRACKET_PATTERN;
static NSRegularExpression *INLINE_MATH_REGEX, *COMMAND_REGEX, *CURLY_BRACKET_REGEX, *COMMENT_REGEX, *BRACKET_REGEX;
static NSSet *USER_DEFAULTS_BINDING_KEYS;

@interface LatexSyntaxHighlighter ()
- (void) unbindFromUserDefaults;
- (void) highlightAtSelectionChange;
@end

@implementation LatexSyntaxHighlighter


#pragma mark Initialization

+ (void)initialize {
        // In this section,
    COMMAND_PATTERN = @"\\\\[a-zA-Z0-9@_]+|\\\\\\\\";
    
    INLINE_MATH_PATTERN = @"(?<![\\\\])(?:\\$(?:[^\\$]+)\\$)|(\\\\\\[(?:[^\\$]+)\\\\\\])|(\\$\\$(?:[^\\$]+)\\$\\$)";
    
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
    
    USER_DEFAULTS_BINDING_KEYS = [NSSet setWithObjects:@"inlineMathColor",@"commandColor",@"bracketColor",@"curlyBracketColor",@"commentColor",@"shouldHighlightArguments",@"shouldHighlightCommands",@"shouldHighlightComments",@"shouldHighlightBrackets",@"shouldHighlightInlineMath", nil];
    if (error) {
        DDLogError(@"Syntax Highlighter Error: %@", error.userInfo);
    }
    
}


- (id)initWithTextView:(HighlightingTextView *)tv {
    self = [super initWithTextView:tv];
    if(self) {
        [self registerDefaults];
        
         [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(highlightAtSelectionChange) name:NSTextViewDidChangeSelectionNotification object:view];
    }
    return self;
}



- (void) registerDefaults {
    backgroundQueue = [NSOperationQueue new];
    NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
    
    /*
        Initial setup of the highlighting colors
     */
    
    self.inlineMathColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_INLINE_MATH_COLOR]];
    [self bind:@"inlineMathColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_INLINE_MATH_COLOR] options:@{NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName}];
    
    self.commandColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMAND_COLOR]];
    [self bind:@"commandColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_COMMAND_COLOR] options:@{NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName}];
    
    self.bracketColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_BRACKET_COLOR]];
    [self bind:@"bracketColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_BRACKET_COLOR] options:@{NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName}];
    
    self.curlyBracketColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_ARGUMENT_COLOR]];
    [self bind:@"curlyBracketColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_ARGUMENT_COLOR] options:@{NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName}];
    
    self.commentColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMENT_COLOR]];
    [self bind:@"commentColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_COMMENT_COLOR] options:@{NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName}];
    
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
- (void)highlightAtSelectionChange {
    if (!view.servicesOn) {
        return;
    }
    [self highlightNarrowArea];
    
}

- (void)highlightEntireDocument {
    NSRange textRange = NSMakeRange(0, [[view textStorage] length]);
    [self highlightRange:textRange];
}

- (void)highlightNarrowArea {
    //TODO: online highlight +- 5 lines;
    [self highlightRange:[view extendRange:view.selectedRange byLines:20]];
}

- (void)highlightVisibleArea {
    [self highlightRange:[view extendedVisibleRange]];
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
    //[view.codeNavigationAssistant highlightCurrentLineForegroundWithRange:view.selectedRange];
    
    if(textRange.length == 0) {
        return;
    }
    [self highlightMathBracketsInRange:textRange];
    [self highlightCommandInRange:textRange];
    [self highlightCurlyBracketsInRange:textRange];
    [self highlightCommentInRange:textRange];
    [self highlightInlineMathInRange:textRange];
    [view.codeExtensionEngine addLinksForRange:textRange];
}

- (void) highlightCommandInRange:(NSRange) totalRange {
    if (self.shouldHighlightCommands) {
        NSLayoutManager *lm = [view layoutManager];
        
        NSString *str = view.string;
        NSArray *matches = [COMMAND_REGEX matchesInString:str options:0 range:totalRange];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match range];
            [lm addTemporaryAttribute:NSForegroundColorAttributeName value:self.commandColor forCharacterRange:range];
           
        }
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
        NSString *str = view.string;
        NSArray *matches = [COMMENT_REGEX matchesInString:str options:0 range:totalRange];
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match range];
            if (range.location > 0 && [[str substringWithRange:NSMakeRange(range.location-1, 1)] isEqualToString:@"\\"]) {
                continue;
            }
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

- (void)unbindFromUserDefaults {
    for(NSString *key in USER_DEFAULTS_BINDING_KEYS) {
        [self unbind:key];
    }
}

-(void)dealloc {
    DDLogVerbose(@"LatexSyntaxHighlighter dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextViewDidChangeSelectionNotification object:view];
    [self unbindFromUserDefaults];
}


#pragma mark -
#pragma mark Regex Getter

+ (NSRegularExpression *)commandExpression {
    return COMMAND_REGEX;
}


@end
