//
//  CodeNavigationAssistent.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CodeNavigationAssistant.h"
#import "UndoSupport.h"
#import "HighlightingTextView.h"
#import <TMTHelperCollection/TMTLog.h>
#import "NSString+LatexExtension.h"

static const NSSet *WHITESPACES;

static const NSRegularExpression *SPACE_REGEX;


static const NSRegularExpression *SPACE_AT_LINE_BEGINNING;

static const NSRegularExpression *FIRST_NONWHITESPACE_IN_LINE;

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
        SPACE_AT_LINE_BEGINNING = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\p{z}|\\t)*" options:NSRegularExpressionAnchorsMatchLines error:&error];
        SPACE_REGEX = [NSRegularExpression regularExpressionWithPattern:@"\\w((?:\\t| )+(?!$))\\w" options:NSRegularExpressionAnchorsMatchLines error:&error];
        
        FIRST_NONWHITESPACE_IN_LINE = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\s*)(\\S)(?:.*)$" options:NSRegularExpressionAnchorsMatchLines error:&error];
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

            self.shouldUseSpacesAsTabs = [[[defaults values] valueForKey:TMT_SHOULD_USE_SPACES_AS_TABS] boolValue];
            [self bind:@"shouldUseSpacesAsTabs" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_USE_SPACES_AS_TABS] options:NULL];

            self.shouldAutoIndentLines = [[[defaults values] valueForKey:TMT_SHOULD_AUTO_INDENT_LINES] boolValue];
            [self bind:@"shouldAutoIndentLines" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_AUTO_INDENT_LINES] options:NULL];

            self.numberOfSpacesForTab = [[defaults values] valueForKey:TMT_EDITOR_NUM_TAB_SPACES];
            [self bind:@"numberOfSpacesForTab" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_NUM_TAB_SPACES] options:NULL];

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
            NSRect lineRect = [self lineRectforRange:range];
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
            NSRange lineRange = [self lineTextRangeWithRange:range];

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
#pragma mark Line Getter

    - (NSRect)lineRectforRange:(NSRange)aRange
    {
        NSRange r = aRange;
        NSRange startLineRange = [[view string] lineRangeForRange:NSMakeRange(r.location, 0)];
        NSInteger er = NSMaxRange(r) - 1;
        NSString *text = [view string];

        if (er >= [text length]) {
            return NSZeroRect;
        }
        if (er < r.location) {
            er = r.location;
        }

        NSRange endLineRange = [[view string] lineRangeForRange:NSMakeRange(er, 0)];

        NSRange gr = [[view layoutManager] glyphRangeForCharacterRange:NSMakeRange(startLineRange.location, NSMaxRange(endLineRange) - startLineRange.location - 1)
                                                  actualCharacterRange:NULL];
        NSRect br = [[view layoutManager] boundingRectForGlyphRange:gr inTextContainer:[view textContainer]];
        NSRect b = [view bounds];
        CGFloat h = br.size.height;
        CGFloat w = b.size.width;
        CGFloat y = br.origin.y;
        NSPoint containerOrigin = [view textContainerOrigin];
        NSRect aRect = NSMakeRect(0, y, w, h);
        // Convert from view coordinates to container coordinates
        aRect = NSOffsetRect(aRect, containerOrigin.x, containerOrigin.y);
        return aRect;
    }


    - (NSRange)lineTextRangeWithRange:(NSRange)range
    {
        return [self lineTextRangeWithRange:range withLineTerminator:NO];
    }

    - (NSRange)lineTextRangeWithRange:(NSRange)range withLineTerminator:(BOOL)flag
    {
        NSUInteger rangeStart, contentsEnd, rangeEnd;
        NSRange result;
        if (range.location != NSNotFound && NSMaxRange(range) <= view.string.length) {
            [view.string getLineStart:&rangeStart end:&rangeEnd contentsEnd:&contentsEnd forRange:range];


            if (flag) {
                NSUInteger length = rangeEnd - rangeStart;
                result = NSMakeRange(rangeStart, length);

            } else {
                NSUInteger length = contentsEnd - rangeStart;
                result = NSMakeRange(rangeStart, length);
            }
        } else {
            result = NSMakeRange(NSNotFound, 0);
            DDLogError(@"Error for provided range: %@", NSStringFromRange(range));
        }
        return result;
    }

#pragma mark -
#pragma mark Comment & Uncomment

    - (void)commentSelectionInRange:(NSRange)range
    {
        NSRange lineRange = [self lineTextRangeWithRange:range];
        NSRange tmp = lineRange;
        NSMutableString *area = [[view.string substringWithRange:lineRange] mutableCopy];
        NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];
        for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
            NSRange match = [result rangeAtIndex:1];
            [area replaceCharactersInRange:NSMakeRange(match.location, 0) withString:@"%"];
            lineRange.length += 1;
        }
        if (matches.count == 0) {
            NSBeep();
        }
        [view.undoManager beginUndoGrouping];
        [view.undoManager registerUndoWithTarget:self selector:@selector(uncommentSelectionInRangeString:) object:NSStringFromRange(lineRange)];
        [view replaceCharactersInRange:tmp withString:area];
        [view setSelectedRange:[self lineTextRangeWithRange:lineRange]];
        [view.undoManager endUndoGrouping];
        [view didChangeText];

    }

    - (void)uncommentSelectionInRange:(NSRange)range
    {
        NSRange lineRange = [self lineTextRangeWithRange:range];
        NSRange tmp = lineRange;
        NSMutableString *area = [[view.string substringWithRange:lineRange] mutableCopy];
        NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];
        BOOL actionDone = NO;
        for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
            NSRange match = [result rangeAtIndex:1];
            if ([[area substringWithRange:match] isEqualToString:@"%"]) {
                [area replaceCharactersInRange:match withString:@""];
                lineRange.length -= 1;
                actionDone = YES;
            }
        }
        [view.undoManager beginUndoGrouping];
        [view.undoManager registerUndoWithTarget:self selector:@selector(commentSelectionInRangeString:) object:NSStringFromRange(lineRange)];
        [view replaceCharactersInRange:tmp withString:area];
        [view setSelectedRange:[self lineTextRangeWithRange:lineRange]];
        [view.undoManager endUndoGrouping];
        if (!actionDone) {
            NSBeep();
        } else {
            [view setSelectedRange:lineRange];
        }
        [view didChangeText];
    }


    - (void)toggleCommentInRange:(NSRange)range
    {
        NSRange lineRange = [self lineTextRangeWithRange:range];
        NSRange tmp = lineRange;
        NSMutableString *area = [[view.string substringWithRange:lineRange] mutableCopy];
        NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];

        BOOL actionDone = NO;
        for (NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
            NSRange match = [result rangeAtIndex:1];
            if ([[area substringWithRange:match] isEqualToString:@"%"]) {
                [area replaceCharactersInRange:match withString:@""];
                lineRange.length -= 1;
            } else {
                [area replaceCharactersInRange:NSMakeRange(match.location, 0) withString:@"%"];
                lineRange.length += 1;
            }
            actionDone = YES;
        }
        [view.undoManager beginUndoGrouping];
        [view.undoManager registerUndoWithTarget:self selector:@selector(toggleCommentInRangeString:) object:NSStringFromRange(lineRange)];
        [view replaceCharactersInRange:tmp withString:area];
        [view.undoManager endUndoGrouping];
        if (!actionDone) {
            NSBeep();
        } else {
            [view setSelectedRange:[self lineTextRangeWithRange:lineRange]];
        }
        [view didChangeText];
    }

    - (void)uncommentSelectionInRangeString:(NSString *)range
    {
        [self uncommentSelectionInRange:NSRangeFromString(range)];
    }

    - (void)commentSelectionInRangeString:(NSString *)range
    {
        [self commentSelectionInRange:NSRangeFromString(range)];
    }

    - (void)toggleCommentInRangeString:(NSString *)range
    {
        [self toggleCommentInRange:NSRangeFromString(range)];
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
        NSRange lineRange = [self lineTextRangeWithRange:view.selectedRange];
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
        NSRange lineRange = [self lineTextRangeWithRange:view.selectedRange];
        if (lineRange.location != NSNotFound) {
            NSRange totalRange = NSUnionRange(lineRange, view.selectedRange);
            if (view.selectedRange.length > 0 && view.selectedRange.location == totalRange.location) {
                [self handleMultiLineIndent];
                return YES;
            }
        }

        NSString *tab = [self singleTab];
        [view insertText:tab];
        return YES;
    }

    - (BOOL)handleBacktabInsertion
    {
        if (view.selectedRanges.count > 1) {
            return NO;
        }
        NSRange lineRange = [self lineTextRangeWithRange:view.selectedRange];
        if (lineRange.location != NSNotFound) {
            NSRange totalRange = NSUnionRange(lineRange, view.selectedRange);
            if (view.selectedRange.length > 0 && view.selectedRange.location == totalRange.location) {
                [self handleMultiLineUnindent];
                return YES;
            }
        }
        NSString *tab = [self singleTab];
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
 Method returns a single tab, meaning a \t or a user defined amount of spaces.
 */
    - (NSString *)singleTab
    {
        NSString *tab = @"\t";
        if (self.shouldUseSpacesAsTabs) {
            tab = @"";
            for (NSUInteger i = 0 ; i < [self.numberOfSpacesForTab integerValue] ; i++) {
                tab = [tab stringByAppendingString:@" "];
            }
        }
        return tab;
    }

/**
 Indents multiple lines at once.
 */
    - (void)handleMultiLineIndent
    {
        NSString *tab = [self singleTab];
        NSRange totalRange = NSUnionRange([self lineTextRangeWithRange:view.selectedRange], view.selectedRange);
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
        NSString *pattern = [NSString stringWithFormat:@"^(\\t| {%li})", self.numberOfSpacesForTab.integerValue];
        NSRange totalRange = NSUnionRange([self lineTextRangeWithRange:view.selectedRange], view.selectedRange);
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

    - (NSString *)lineBreak
    {
        NSUInteger position = view.selectedRange.location;
        NSString *lineBreak = @"\n";
        if (self.shouldAutoIndentLines) {
            NSRange lineRange = [view.string lineRangeForRange:NSMakeRange(position, 0)];
            lineBreak = [lineBreak stringByAppendingString:[self whiteSpacesAtLineBeginning:lineRange]];

        }
        return lineBreak;
    }

    - (void)handleNewLineInsertion
    {

        [view insertText:[self lineBreak]];
    }

    - (NSString *)whiteSpacesAtLineBeginning:(NSRange)lineRange
    {
        NSRange rangeOfFirstMatch = [SPACE_AT_LINE_BEGINNING rangeOfFirstMatchInString:[view string] options:0 range:lineRange];
        if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
            return [view.string substringWithRange:rangeOfFirstMatch];

        }
        return @"";
    }

    - (BOOL)handleWrappingInRange:(NSRange)textRange
    {
        if (view.lineWrapMode != HardWrap && !view.hardWrapAfter) {
            return NO;
        }
        NSMutableString *content = [[NSMutableString alloc] initWithString:view.string];
        NSUInteger wrapAfter = [view.hardWrapAfter integerValue];
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
        [view.undoSupport setString:view.string withActionName:NSLocalizedString(@"Line Wrap", "wrap undo")];
        [view setString:content];
        [view.undoManager endUndoGrouping];
        return result;
    }

    - (BOOL)handleWrappingInLine:(NSRange)lineRange
    {
        NSUInteger wrapAfter = [view.hardWrapAfter integerValue];
        NSUInteger cursorPositionInLine = view.selectedRange.location - lineRange.location;
        if (view.lineWrapMode != HardWrap || cursorPositionInLine < wrapAfter) {
            return NO;
        }
        
        NSRange firstLinePart = NSMakeRange(lineRange.location, cursorPositionInLine);
        NSArray *ranges = [view.string goodPositionsToBreakInRange:firstLinePart];
        if (ranges.count > 0) {
            [view.undoManager beginUndoGrouping];
            NSString *newLineInsertion = @"\n";
            if (self.shouldAutoIndentLines) {
                newLineInsertion = [newLineInsertion stringByAppendingString:[self whiteSpacesAtLineBeginning:lineRange]];
            }
            NSTextCheckingResult *result = ranges.lastObject;
            
            NSDictionary *attributes = [view.textStorage attributesAtIndex:lineRange.location effectiveRange:NULL];
            NSAttributedString *insertion = [[NSAttributedString alloc] initWithString:newLineInsertion attributes:attributes];
            
            [view.undoSupport insertText:insertion atIndex:NSMaxRange([result rangeAtIndex:1]) withActionName:NSLocalizedString(@"Line Wrap", "wrap undo")];
            
            [view.undoManager endUndoGrouping];
            return YES;
        }
        return NO;
    }


    - (BOOL)handleWrappingInLine:(NSRange)lineRange ofString:(NSMutableString *)string
    {
        NSUInteger wrapAfter = [view.hardWrapAfter integerValue];
        if (view.lineWrapMode != HardWrap || lineRange.length < wrapAfter) {
            return NO;
        }
        NSString *newLineInsertion = @"\n";
        if (self.shouldAutoIndentLines) {
            newLineInsertion = [newLineInsertion stringByAppendingString:[self whiteSpacesAtLineBeginning:lineRange]];
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
