//
//  CodeNavigationAssistent.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CodeNavigationAssistant.h"
#import "HighlightingTextView.h"
#import <TMTHelperCollection/TMTLog.h>
#import <TMTHelperCollection/NSString+LatexExtensions.h>
#import <TMTHelperCollection/NSTextView+TMTExtensions.h>
#import <TMTHelperCollection/NSString+TMTExtensions.h>
#import "NSString+TMTEditorExtensions.h"
#import "SettingsHelper.h"
static const NSSet *WHITESPACES;

static const NSRegularExpression *SPACE_REGEX;


static const NSSet *KEYS_TO_UNBIND;

static const NSSet *KEYS_TO_OBSERVE;


@interface CodeNavigationAssistant ()

    - (void)unbindAll;

    - (void)handleMultiLineIndent;

    - (void)handleMultiLineUnindent;

@end

@implementation CodeNavigationAssistant

    + (void)initialize
    {
        KEYS_TO_UNBIND = [NSSet setWithObjects:@"currentLineColor", @"shouldHighlightCurrentLine", @"currentLineTextColor", @"shouldHighlightCurrentLineText", @"carretColor", @"shouldHighlightCarret", @"shouldUseSpacesAsTabs", @"shouldAutoIndentLines", @"numberOfSpacesForTab", nil];
        KEYS_TO_OBSERVE = [NSSet setWithObjects:@"currentLineColor", @"shouldHighlightCurrentLine", @"currentLineTextColor", @"shouldHighlightCurrentLineText", @"carretColor", @"shouldHighlightCarret", nil];

        WHITESPACES = [NSSet setWithObjects:@" ", @"\t", nil];
        NSError *error;
        
        SPACE_REGEX = [NSRegularExpression regularExpressionWithPattern:@"\\w((?:\\t| )+(?!$))\\w" options:NSRegularExpressionAnchorsMatchLines error:&error];
        
      
        if (error) {
            DDLogError(@"Error!!!");
        }
        if (error) {
            DDLogError(@"Regex Error");
        }
    }

    - (id)initWithTextView:(HighlightingTextView *)tv
    {
        self = [super initWithTextView:tv];
        if (self) {
            NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
            self.currentLineColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_CURRENT_LINE_COLOR]];
            [self bind:@"currentLineColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_CURRENT_LINE_COLOR] options:@{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName}];
            self.shouldHighlightCurrentLine = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_CURRENT_LINE] boolValue];
            [self bind:@"shouldHighlightCurrentLine" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_CURRENT_LINE] options:NULL];

            self.currentLineTextColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_CURRENT_LINE_TEXT_COLOR]];
            [self bind:@"currentLineTextColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_CURRENT_LINE_TEXT_COLOR] options:@{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName}];
            self.shouldHighlightCurrentLineText = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT] boolValue];
            [self bind:@"shouldHighlightCurrentLineText" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT] options:NULL];


            self.carretColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_CARRET_COLOR]];
            [self bind:@"carretColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_CARRET_COLOR] options:@{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName}];
            self.shouldHighlightCarret = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_CARRET] boolValue];
            [self bind:@"shouldHighlightCarret" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_CARRET] options:NULL];


            for (NSString *key in KEYS_TO_OBSERVE) {
                [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
            }


        }
        return self;
    }


#pragma mark -
#pragma mark Current Line Highlighting
    - (void)highlightCurrentLine
    {
        [self highlightCurrentLineBackground];
        [self highlightCurrentLineForegroundWithRange:[view selectedRange]];

    }

    - (void)highlightCurrentLineBackground
    {
        if (self.shouldHighlightCurrentLine && [view.selectedRanges count] == 1 && view.selectedRange.length == 0) {
            NSRange range = [view selectedRange];
            if (range.location > view.string.length) {
                return;
            }
            NSRect lineRect = [view lineRectforRange:range];
            if (lineRect.size.width == 0) {
                return;
            }
            [self.currentLineColor set];
            [NSBezierPath fillRect:lineRect];
        }
    }

    - (void)highlightCurrentLineForegroundWithRange:(NSRange)range
    {
        if (NSMaxRange(range) > view.string.length) {
            return;
        }
        NSLayoutManager *lm = [view layoutManager];
        if (self.shouldHighlightCurrentLineText) {
            NSRange lineRange = [view.string lineTextRangeWithRange:range];

            // [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:lastLineRange];
            [lm addTemporaryAttributes:@{NSForegroundColorAttributeName : self.currentLineTextColor} forCharacterRange:lineRange];
            lastLineRange = lineRange;
        } else {
            if (lastLineRange.location != NSNotFound) {
                [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:lastLineRange];
                lastLineRange = NSMakeRange(NSNotFound, 0);
            }
        }
    }

    - (void)highlight
    {
        [self highlightCurrentLine];
        [self highlightCarret];
    }

#pragma mark -
#pragma mark Carret Highlighting

    - (void)highlightCarret
    {
        NSLayoutManager *lm = [view layoutManager];
        if (!self.shouldHighlightCarret) {
            if (lastCarretRange.location != NSNotFound) {
                // Make sure that the visible carret gets deleted.
                [lm removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:view.visibleRange];
                lastCarretRange = NSMakeRange(NSNotFound, 0);
            }
            return;
        }
        [lm removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:view.visibleRange];
        if (view.selectedRanges.count > 1 || view.selectedRange.length > 0 || !self.carretColor) {
            return;
        }
        NSRange lineRange = [view.string lineTextRangeWithRange:view.selectedRange];
        NSUInteger currentPosition = view.selectedRange.location < view.string.length ? view.selectedRange.location : 0;
        if (currentPosition < lineRange.location) {
            return;
        }
        NSRange carretRange = NSMakeRange(currentPosition, 1);
        [lm addTemporaryAttribute:NSBackgroundColorAttributeName value:self.carretColor forCharacterRange:carretRange];
        lastCarretRange = carretRange;
    }

#pragma mark -
#pragma mark Auto Indention and Tab Spacing
    - (BOOL)handleTabInsertion
    {
        if (view.selectedRanges.count > 1) {
            return NO;
        }
        NSRange lineRange = [view.string lineTextRangeWithRange:view.selectedRange];
        if (lineRange.location != NSNotFound) {
            NSRange totalRange = NSUnionRange(lineRange, view.selectedRange);
            if (view.selectedRange.length > 0 && view.selectedRange.location == totalRange.location) {
                [self handleMultiLineIndent];
                return YES;
            }
        }

        NSString *tab = [NSString singleTab];
        [view insertText:tab];
        return YES;
    }

    - (BOOL)handleBacktabInsertion
    {
        if (view.selectedRanges.count > 1) {
            return NO;
        }
        NSRange lineRange = [view.string lineTextRangeWithRange:view.selectedRange];
        if (lineRange.location != NSNotFound) {
            NSRange totalRange = NSUnionRange(lineRange, view.selectedRange);
            if (view.selectedRange.length > 0 && view.selectedRange.location == totalRange.location) {
                [self handleMultiLineUnindent];
                return YES;
            }
        }
        NSString *tab = [NSString singleTab];
        NSUInteger position = view.selectedRange.location;
        if (position < tab.length) {
            return NO;
        }
        NSRange possibleTabRange = NSMakeRange(position - tab.length, tab.length);
        if ([[view.string substringWithRange:possibleTabRange] isEqualToString:tab]) {
            [view.undoManager beginUndoGrouping];
            [view setSelectedRange:possibleTabRange];
            [view delete:nil];
            [view.undoManager endUndoGrouping];
            return YES;
        }
        return NO;

    }


/**
 Indents multiple lines at once.
 */
    - (void)handleMultiLineIndent
    {
        NSString *tab = [NSString singleTab];
        NSRange totalRange = NSUnionRange([view.string lineTextRangeWithRange:view.selectedRange], view.selectedRange);
        NSError *error;
        NSRegularExpression *beginOfLine = [NSRegularExpression regularExpressionWithPattern:@"^" options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines error:&error];
        NSString *string = [view.string substringWithRange:totalRange];
        NSMutableString *mString = [string mutableCopy];
        NSRange newRange = NSMakeRange(0, mString.length - 1);
        [beginOfLine replaceMatchesInString:mString options:0 range:newRange withTemplate:tab];
        [view insertText:mString replacementRange:totalRange];
        totalRange.length = mString.length;
        [view setSelectedRange:totalRange];

    }

    - (void)handleMultiLineUnindent
    {
        NSString *pattern = [NSString stringWithFormat:@"^(\\t| {%li})", [SettingsHelper sharedInstance].numberOfSpacesForTab];
        NSRange totalRange = NSUnionRange([view.string lineTextRangeWithRange:view.selectedRange], view.selectedRange);
        NSError *error;
        NSRegularExpression *beginOfLine = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines error:&error];
        NSString *string = [view.string substringWithRange:totalRange];
        NSMutableString *mString = [string mutableCopy];
        NSRange newRange = NSMakeRange(0, mString.length - 1);
        [beginOfLine replaceMatchesInString:mString options:0 range:newRange withTemplate:@""];
        [view insertText:mString replacementRange:totalRange];
        totalRange.length = mString.length;
        [view setSelectedRange:totalRange];

    }

    - (void)handleNewLineInsertion
    {

        [view insertText:[view.string lineBreakForPosition:view.selectedRange.location]];
    }

    - (BOOL)handleWrappingInRange:(NSRange)textRange
    {
        if (view.lineWrapMode != HardWrap && !view.hardWrapAfter) {
            return NO;
        }
        NSMutableString *content = [[NSMutableString alloc] initWithString:view.string];
        NSUInteger wrapAfter = [view.hardWrapAfter unsignedIntegerValue];
        NSError *error;
        NSString *longLinesPattern = [NSString stringWithFormat:@"^(?:.{%ld,})$", wrapAfter + 1];
        NSRegularExpression *longLineRegex = [NSRegularExpression regularExpressionWithPattern:longLinesPattern options:NSRegularExpressionAnchorsMatchLines error:&error];

        if (error) {
            DDLogError(@"regex error in long line regex: %@", error);
            return NO;
        }

        NSArray *longLines = [longLineRegex matchesInString:content options:0 range:textRange];
        BOOL result = NO;
        for (NSTextCheckingResult *line in [longLines reverseObjectEnumerator]) {
            NSRange lineRange = [line range];
            result = [self handleWrappingInLine:lineRange ofString:content] || result;
        }
        [view.undoManager beginUndoGrouping];
        [view setString:view.string withActionName:NSLocalizedString(@"Line Wrap", "wrap undo")];
        [view setString:content];
        [view.undoManager endUndoGrouping];
        return result;
    }

    - (BOOL)handleWrappingInLine:(NSRange)lineRange
    {
        NSUInteger wrapAfter = [view.hardWrapAfter unsignedIntegerValue];
        NSUInteger cursorPositionInLine = view.selectedRange.location - lineRange.location;
        if (view.lineWrapMode != HardWrap || cursorPositionInLine < wrapAfter) {
            return NO;
        }
        
        NSRange firstLinePart = NSMakeRange(lineRange.location, cursorPositionInLine);
        NSArray *ranges = [view.string goodPositionsToBreakInRange:firstLinePart];
        if (ranges.count > 0) {
            [view.undoManager beginUndoGrouping];
            NSString *newLineInsertion = @"\n";
            if ([SettingsHelper sharedInstance].shouldAutoIndentLines) {
                newLineInsertion = [newLineInsertion stringByAppendingString:[view.string whiteSpacesAtLineBeginning:lineRange]];
            }
            NSTextCheckingResult *result = ranges.lastObject;
            
            NSDictionary *attributes = [view.textStorage attributesAtIndex:lineRange.location effectiveRange:NULL];
            NSAttributedString *insertion = [[NSAttributedString alloc] initWithString:newLineInsertion attributes:attributes];
            
            [view insertText:insertion atIndex:NSMaxRange([result rangeAtIndex:1]) withActionName:NSLocalizedString(@"Line Wrap", "wrap undo")];
            
            [view.undoManager endUndoGrouping];
            return YES;
        }
        return NO;
    }


    - (BOOL)handleWrappingInLine:(NSRange)lineRange ofString:(NSMutableString *)string
    {
        NSUInteger wrapAfter = [view.hardWrapAfter unsignedIntegerValue];
        if (view.lineWrapMode != HardWrap || lineRange.length < wrapAfter) {
            return NO;
        }
        NSString *newLineInsertion = @"\n";
        if ([SettingsHelper sharedInstance].shouldAutoIndentLines) {
            newLineInsertion = [newLineInsertion stringByAppendingString:[view.string whiteSpacesAtLineBeginning:lineRange]];
        }

        NSArray *spaces = [SPACE_REGEX matchesInString:view.string options:0 range:lineRange];
        NSUInteger goodPositionToBreak = NSNotFound;
        NSUInteger lastBreakLocation = lineRange.location;
        NSUInteger counter = 0;
        NSMutableArray *wrapPositions = [NSMutableArray new];
        for (NSTextCheckingResult *match in spaces) {
            counter++;
            NSRange matchRange = [match rangeAtIndex:1];
            NSUInteger currentPosition = NSMaxRange(matchRange);
            
            if (currentPosition-lastBreakLocation >= wrapAfter) {
                
                if (goodPositionToBreak != NSNotFound) {
                    [wrapPositions addObject:@(goodPositionToBreak)];
                    lastBreakLocation = goodPositionToBreak;
                    goodPositionToBreak = currentPosition;
                } else {
                    [wrapPositions addObject:@(currentPosition)];
                    lastBreakLocation = currentPosition;
                }
            } else {
                goodPositionToBreak = currentPosition;
            }

        }
        if (goodPositionToBreak != NSNotFound && NSMaxRange(lineRange)-lastBreakLocation >= wrapAfter) {
            [wrapPositions addObject:@(goodPositionToBreak)];
        }
        
        NSUInteger commentPosition = NSNotFound;
        NSRange commentSearchRange = lineRange;
        while (commentPosition == NSNotFound) {
            NSRange r = [string rangeOfString:@"%" options:0 range:commentSearchRange];
            if (r.location == NSNotFound) {
                break;
            }
            if ([string numberOfBackslashesBeforePositionIsEven:r.location]) {
                commentPosition = r.location;
            } else {
                commentSearchRange = NSMakeRange(NSMaxRange(r), NSMaxRange(commentSearchRange)-NSMaxRange(r));
            }
            
        }
        
        [view.undoManager beginUndoGrouping];
        for (NSNumber *pos in wrapPositions.reverseObjectEnumerator) {
            NSUInteger position = pos.unsignedIntegerValue;
            [string insertString:newLineInsertion atIndex:position];
            if (commentPosition != NSNotFound && position > commentPosition) {
                [string insertString:@"% " atIndex:position+newLineInsertion.length];
            }
        }
        [view.undoManager endUndoGrouping];
        return YES;
    }


    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
    {
        if ([object isEqualTo:self] && [KEYS_TO_OBSERVE containsObject:keyPath]) {
            if ([keyPath isEqualToString:@"carretColor"]) {
                [view setInsertionPointColor:self.carretColor];
            }
            [view setNeedsDisplay:YES];
        }
    }


    - (void)dealloc
    {
        [self unbindAll];
    }

    - (void)unbindAll
    {
        for (NSString *key in KEYS_TO_UNBIND) {
            [self unbind:key];
        }
        for (NSString *key in KEYS_TO_OBSERVE) {
            [self removeObserver:self forKeyPath:key];
        }
    }

@end
