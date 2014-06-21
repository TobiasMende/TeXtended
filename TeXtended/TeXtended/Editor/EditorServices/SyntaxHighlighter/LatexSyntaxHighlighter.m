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
#import "NSString+LatexExtension.h"
#import <TMTHelperCollection/TMTLog.h>

static NSSet *USER_DEFAULTS_BINDING_KEYS;
static const NSCharacterSet *ALL_SYMBOLS;
static const NSCharacterSet *CURLY_BRACKETS, *ROUND_BRACKETS, *RECT_BRACKETS;

static NSString *COMMAND_PATTERN;

static NSRegularExpression *COMMAND_REGEX;

@interface LatexSyntaxHighlighter ()

    - (void)unbindFromUserDefaults;

    - (void)highlightAtSelectionChange;
@end

@implementation LatexSyntaxHighlighter


#pragma mark Initialization


    + (void)initialize
    {

        USER_DEFAULTS_BINDING_KEYS = [NSSet setWithObjects:@"inlineMathColor", @"commandColor", @"bracketColor", @"curlyBracketColor", @"commentColor", @"shouldHighlightArguments", @"shouldHighlightCommands", @"shouldHighlightComments", @"shouldHighlightBrackets", @"shouldHighlightInlineMath", nil];
        ALL_SYMBOLS = [NSCharacterSet characterSetWithCharactersInString:@"()[]{}%$\\"];
        CURLY_BRACKETS = [NSCharacterSet characterSetWithCharactersInString:@"{}"];
        ROUND_BRACKETS = [NSCharacterSet characterSetWithCharactersInString:@"()"];
        RECT_BRACKETS = [NSCharacterSet characterSetWithCharactersInString:@"[]"];
        
        COMMAND_PATTERN = @"\\\\[a-zA-Z0-9@_]+|\\\\\\\\";

    }


    - (id)initWithTextView:(HighlightingTextView *)tv
    {
        self = [super initWithTextView:tv];
        if (self) {
            [self registerDefaults];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(highlightAtSelectionChange) name:NSTextViewDidChangeSelectionNotification object:view];
        }
        return self;
    }


    - (void)registerDefaults
    {
        backgroundQueue = [NSOperationQueue new];
        [backgroundQueue setName:@"LatexSyntaxHighlighter-BackgroundQueue"];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];

        /*
            Initial setup of the highlighting colors
         */

        self.inlineMathColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_INLINE_MATH_COLOR]];
        [self bind:@"inlineMathColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_INLINE_MATH_COLOR] options:@{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName}];

        self.commandColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMAND_COLOR]];
        [self bind:@"commandColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_COMMAND_COLOR] options:@{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName}];

        self.bracketColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_BRACKET_COLOR]];
        [self bind:@"bracketColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_BRACKET_COLOR] options:@{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName}];

        self.curlyBracketColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_ARGUMENT_COLOR]];
        [self bind:@"curlyBracketColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_ARGUMENT_COLOR] options:@{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName}];

        self.commentColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_COMMENT_COLOR]];
        [self bind:@"commentColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_COMMENT_COLOR] options:@{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName}];

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

    - (void)handleColorChange
    {
        [self invalidateHighlighting];
        [self highlightVisibleArea];
    }

    - (void)invalidateHighlighting
    {
        NSLayoutManager *lm = [view layoutManager];
        NSRange textRange = NSMakeRange(0, [[view textStorage] length]);
        [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:textRange];
    }


# pragma mark -
# pragma mark Highlighting Methods
    - (void)highlightAtSelectionChange
    {
        if (!view.servicesOn) {
            return;
        }
        [self highlightNarrowArea];

    }

    - (void)highlightEntireDocument
    {
        NSRange textRange = NSMakeRange(0, [[view textStorage] length]);
        [self highlightRange:textRange];
    }

    - (void)highlightNarrowArea
    {
        [self highlightRange:[view extendRange:view.selectedRange byLines:20]];
    }

    - (void)highlightVisibleArea
    {
        [self highlightRange:[view extendedVisibleRange]];
    }

    - (void)highlightRange:(NSRange)range
    {
        [self performHighlightingInRange:range];
    }

# pragma mark Private Highlighting Methods


/**
 Method for calling all highlighting methods in a proper order
 
 */
    - (void)performHighlightingInRange:(NSRange)textRange
    {
        
        //[view.codeNavigationAssistant highlightCurrentLineForegroundWithRange:view.selectedRange];

        if (textRange.length == 0) {
            return;
        }
        
        NSScanner *scanner = [NSScanner scannerWithString:view.string];
        scanner.scanLocation = textRange.location;
        NSUInteger rangeStart = textRange.location;
        
        while (scanner.scanLocation < NSMaxRange(textRange) && !scanner.isAtEnd) {
            [scanner scanUpToCharactersFromSet:ALL_SYMBOLS intoString:NULL];
                // Found Begin of Something
                // Uncolor normal text
                [self highlightFrom:rangeStart to:scanner.scanLocation withColor:nil andFlag:NO];
                
                rangeStart = scanner.scanLocation;
                if ([scanner scanCharactersFromSet:ROUND_BRACKETS intoString:NULL] ) {
                    // color round brackets
                    [self highlightFrom:rangeStart to:scanner.scanLocation withColor:self.bracketColor andFlag:self.shouldHighlightBrackets];
                } else if ([scanner scanCharactersFromSet:CURLY_BRACKETS intoString:NULL]) {
                    // color curly brackets
                     [self highlightFrom:rangeStart to:scanner.scanLocation withColor:self.curlyBracketColor andFlag:self.shouldHighlightArguments];
                } else if ([scanner scanCharactersFromSet:RECT_BRACKETS intoString:NULL]) {
                    // color rect brackets
                     [self highlightFrom:rangeStart to:scanner.scanLocation withColor:self.bracketColor andFlag:self.shouldHighlightBrackets];
                } else if([scanner scanString:@"\\" intoString:NULL]) {
                    // color commands
                    NSMutableCharacterSet *charactersInCommand = [NSMutableCharacterSet characterSetWithCharactersInString:@"{}[]"];
                    [charactersInCommand formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [scanner scanUpToCharactersFromSet:charactersInCommand  intoString:NULL];
                    [self highlightFrom:rangeStart to:scanner.scanLocation withColor:self.commandColor andFlag:self.shouldHighlightCommands];
                } else if([scanner scanString:@"$" intoString:NULL]) {
                    if ([scanner scanString:@"$" intoString:NULL]) {
                        // Start is $$
                        if ([scanner scanUpToString:@"$$" intoString:NULL]) {
                            // Found end for $$
                            [scanner scanString:@"$$" intoString:NULL];
                        }
                    } else if ([scanner scanUpToString:@"$" intoString:NULL]) {
                        // Found end for $
                        [scanner scanString:@"$" intoString:NULL];
                    }
                    
                    [self highlightFrom:rangeStart to:scanner.scanLocation withColor:self.inlineMathColor andFlag:self.shouldHighlightInlineMath];
                } else if([scanner scanString:@"%" intoString:NULL]) {
                    // color comment
                    NSCharacterSet *tmp = scanner.charactersToBeSkipped;
                    scanner.charactersToBeSkipped = nil;
                    [scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
                    
                    [self highlightFrom:rangeStart to:scanner.scanLocation withColor:self.commentColor andFlag:self.shouldHighlightComments];
                    [scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
                    scanner.charactersToBeSkipped = tmp;
                } else if (scanner.isAtEnd) {
                    // ignore this case. no special symbols in content
                } else {
                    DDLogError(@"Unexpected Case!! Seeing: %@", [view.string substringToIndex:rangeStart]);
                }
                rangeStart = scanner.scanLocation;
         
        }
        
    }


+ (void) logCharacterSet:(NSCharacterSet*)characterSet
{
    unichar unicharBuffer[20];
    int index = 0;
    
    for (unichar uc = 0; uc < (0xFFFF); uc ++)
    {
        if ([characterSet characterIsMember:uc])
        {
            unicharBuffer[index] = uc;
            
            index ++;
            
            if (index == 20)
            {
                NSString * characters = [NSString stringWithCharacters:unicharBuffer length:index];
                NSLog(@"%@", characters);
                
                index = 0;
            }
        }
    }
    
    if (index != 0)
    {
        NSString * characters = [NSString stringWithCharacters:unicharBuffer length:index];
        NSLog(@"%@", characters);
    }
}

- (void)highlightFrom:(NSUInteger)start to:(NSUInteger)end withColor:(NSColor *)color andFlag:(BOOL)shouldHighlight {
    NSRange range = NSMakeRange(start, end-start);
    if (range.length == 0) {
        return;
    }
            NSLayoutManager *lm = [view layoutManager];
    if (shouldHighlight) {
        [lm addTemporaryAttribute:NSForegroundColorAttributeName value:color forCharacterRange:range];
    } else {
        [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
    }
}


/**
 Highlights the foreground font of substrings matching the given regular expression in the given range with the given foreground color. 
 */

    - (void)highlightForegroundWithExpression:(NSRegularExpression *)regex andColor:(NSColor *)color inRange:(NSRange)totalRange
    {
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

    - (void)setInlineMathColor:(NSColor *)inlineMathColor
    {
        _inlineMathColor = inlineMathColor;
        [self handleColorChange];
    }

    - (void)setCommandColor:(NSColor *)commandColor
    {
        _commandColor = commandColor;
        [self handleColorChange];
    }

    - (void)setBracketColor:(NSColor *)bracketColor
    {
        _bracketColor = bracketColor;
        [self handleColorChange];
    }


    - (void)setCurlyBracketColor:(NSColor *)curlyBracketColor
    {
        _curlyBracketColor = curlyBracketColor;
        [self handleColorChange];
    }

    - (void)setCommentColor:(NSColor *)commentColor
    {
        _commentColor = commentColor;
        [self handleColorChange];
    }

#pragma mark Flag Setter

    - (void)setShouldHighlightArguments:(BOOL)shouldHighlightArguments
    {
        _shouldHighlightArguments = shouldHighlightArguments;
        [self handleColorChange];
    }

    - (void)setShouldHighlightBrackets:(BOOL)shouldHighlightBrackets
    {
        _shouldHighlightBrackets = shouldHighlightBrackets;
        [self handleColorChange];
    }

    - (void)setShouldHighlightCommands:(BOOL)shouldHighlightCommands
    {
        _shouldHighlightCommands = shouldHighlightCommands;
        [self handleColorChange];
    }

    - (void)setShouldHighlightComments:(BOOL)shouldHighlightComments
    {
        _shouldHighlightComments = shouldHighlightComments;
        [self handleColorChange];
    }

    - (void)setShouldHighlightInlineMath:(BOOL)shouldHighlightInlineMath
    {
        _shouldHighlightInlineMath = shouldHighlightInlineMath;
        [self handleColorChange];
    }


#pragma mark -
#pragma mark Dealloc

    - (void)unbindFromUserDefaults
    {
        for (NSString *key in USER_DEFAULTS_BINDING_KEYS) {
            [self unbind:key];
        }
    }

    - (void)dealloc
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTextViewDidChangeSelectionNotification object:view];
        [self unbindFromUserDefaults];
    }


#pragma mark -
#pragma mark Regex Getter

    + (NSRegularExpression *)commandExpression
    {
        return COMMAND_REGEX;
    }


@end
