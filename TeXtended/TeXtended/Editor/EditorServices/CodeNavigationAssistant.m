//
//  CodeNavigationAssistent.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 11.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CodeNavigationAssistant.h"
#import "HighlightingTextView.h"
#import "Constants.h"
NSSet *WHITESPACES;
NSRegularExpression *SPACE_REGEX;
NSRegularExpression *SPACE_AT_LINE_BEGINNING;
@implementation CodeNavigationAssistant

+ (void)initialize {
    WHITESPACES = [NSSet setWithObjects:@" ",@"\t", nil];
    NSError *error;
    SPACE_AT_LINE_BEGINNING = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\p{z}|\\t)*" options:NSRegularExpressionAnchorsMatchLines error:&error];
    SPACE_REGEX = [NSRegularExpression regularExpressionWithPattern:@"(?:\\t| )+" options:0 error:&error];
    if (error) {
        NSLog(@"Error!!!");
    }
    if(error) {
        NSLog(@"Regex Error");
    }
}

- (id)initWithTextView:(HighlightingTextView *)tv {
    self= [super initWithTextView:tv];
    if (self) {
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        self.currentLineColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_CURRENT_LINE_COLOR]];
        [self bind:@"currentLineColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_CURRENT_LINE_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
        self.shouldHighlightCurrentLine = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_CURRENT_LINE] boolValue];
        [self bind:@"shouldHighlightCurrentLine" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_CURRENT_LINE] options:NULL];
        
        self.currentLineTextColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_CURRENT_LINE_TEXT_COLOR]];
        [self bind:@"currentLineTextColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_CURRENT_LINE_TEXT_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
        self.shouldHighlightCurrentLineText = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT] boolValue];
        [self bind:@"shouldHighlightCurrentLineText" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_CURRENT_LINE_TEXT] options:NULL];
        
        
        self.carretColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_CARRET_COLOR]];
        [self bind:@"carretColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_CARRET_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
        self.shouldHighlightCarret = [[[defaults values] valueForKey:TMT_SHOULD_HIGHLIGHT_CARRET] boolValue];
        [self bind:@"shouldHighlightCarret" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_HIGHLIGHT_CARRET] options:NULL];
        
        self.shouldUseSpacesAsTabs = [[[defaults values] valueForKey:TMT_SHOULD_USE_SPACES_AS_TABS] boolValue];
        [self bind:@"shouldUseSpacesAsTabs" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_USE_SPACES_AS_TABS] options:NULL];
        
        self.shouldAutoIndentLines = [[[defaults values] valueForKey:TMT_SHOULD_AUTO_INDENT_LINES] boolValue];
        [self bind:@"shouldAutoIndentLines" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_AUTO_INDENT_LINES] options:NULL];
        
        self.numberOfSpacesForTab = [[defaults values] valueForKey:TMT_EDITOR_NUM_TAB_SPACES];
        [self bind:@"numberOfSpacesForTab" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_NUM_TAB_SPACES] options:NULL];


    }
    return self;
}


#pragma mark -
#pragma mark Current Line Highlighting
- (void) highlightCurrentLine {
    [self highlightCurrentLineBackground];
    [self highlightCurrentLineForegroundWithRange:[view selectedRange]];
    
}

- (void)highlightCurrentLineBackground {
    if(self.shouldHighlightCurrentLine && [view.selectedRanges count] == 1 && view.selectedRange.length == 0) {
    NSRange range = [view selectedRange];
        if (range.location > view.string.length) {
            return;
        }
    NSRect lineRect = [self lineRectforRange:range];
    if (lineRect.size.width == 0) {
        return;
    }
    if ([view lockFocusIfCanDraw]) {
        [self.currentLineColor set];
        [NSBezierPath fillRect:lineRect];
        [view unlockFocus];
    }
    }
}

- (void)highlightCurrentLineForegroundWithRange:(NSRange)range {
    if (range.location > view.string.length) {
        return;
    }
    NSLayoutManager *lm = [view layoutManager];
    if (self.shouldHighlightCurrentLineText) {
        NSRange lineRange = [self lineTextRangeWithRange:range];
        
        [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:lastLineRange];
        [lm addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.currentLineTextColor, NSForegroundColorAttributeName, nil] forCharacterRange:lineRange];
        [view updateSyntaxHighlighting];
        lastLineRange = lineRange;
    } else {
        if (lastLineRange.location != NSNotFound) {
            [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:lastLineRange];
            lastLineRange = NSMakeRange(NSNotFound, 0);
        }
    }
}

- (void)highlight {
    [self highlightCurrentLine];
    [self highlightCarret];
}

- (NSRect)lineRectforRange:(NSRange) range {
    NSRange totalLineRange = NSMakeRange(view.selectedRange.location, 0);
    NSLayoutManager *lm = view.layoutManager;
    NSRange glyphRange = [lm glyphRangeForCharacterRange:totalLineRange actualCharacterRange:NULL];
    NSRect boundingRect = [lm boundingRectForGlyphRange:glyphRange inTextContainer:view.textContainer];
    NSRect totalRect = NSMakeRect(0, boundingRect.origin.y, view.bounds.size.width, boundingRect.size.height);
    NSRect lineRect = NSOffsetRect(totalRect, view.textContainerOrigin.x, view.textContainerOrigin.y);
    return lineRect;
}


- (NSRange) lineTextRangeWithRange:(NSRange) range {
    NSUInteger rangeStartPosition = range.location;
    NSRange startLineRange = [view.string lineRangeForRange:NSMakeRange(rangeStartPosition, 0)];
    
    NSUInteger rangeEndPosition = NSMaxRange(range);
    if (rangeEndPosition > view.string.length) {
        return NSMakeRange(NSNotFound, 0);
    }
    if (rangeEndPosition < rangeStartPosition) {
        rangeEndPosition = rangeStartPosition;
    }
    NSRange endLineRange = [view.string lineRangeForRange:NSMakeRange(rangeEndPosition, 0)];
    
    NSRange totalLineRange = NSMakeRange(startLineRange.location, NSMaxRange(endLineRange)-startLineRange.location);
    return totalLineRange;
}

#pragma mark -
#pragma mark Carret Highlighting

- (void)highlightCarret {
    NSLayoutManager *lm = [view layoutManager];
    if (!self.shouldHighlightCarret) {
        if(lastCarretRange.location != NSNotFound) {
            // Make sure that the visible carret gets deleted.
            [lm removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:view.visibleRange];
            lastCarretRange = NSMakeRange(NSNotFound, 0);
        }
        return;
    }
    [lm removeTemporaryAttribute:NSBackgroundColorAttributeName forCharacterRange:view.visibleRange];
    if(view.selectedRanges.count > 1 || view.selectedRange.length >0 || !self.carretColor) {
        return;
    }
    
    NSUInteger currentPosition = view.selectedRange.location;
    NSRange carretRange = NSMakeRange(currentPosition, 1);
    [lm addTemporaryAttribute:NSBackgroundColorAttributeName value:self.carretColor forCharacterRange:carretRange];
    lastCarretRange = carretRange;
}

#pragma mark -
#pragma mark Auto Indention and Tab Spacing
- (BOOL)handleTabInsertion {
    if (view.selectedRanges.count > 1 || view.selectedRange.length > 0) {
        return NO;
    }
    NSRange lineRange = [self lineTextRangeWithRange:view.selectedRange];
    if (lineRange.location != NSNotFound) {
        NSRange totalRange = NSUnionRange(lineRange
                                          , view.selectedRange);
        if (view.selectedRange.length > 0 && view.selectedRange.location == totalRange.location) {
            [self handleMultiLineIndent];
            return YES;
        }
    }
    
        NSString *tab = [self singleTab];
        [view insertText:tab];
    return YES;
}

- (BOOL)handleBacktabInsertion {
    if (view.selectedRanges.count > 1 || view.selectedRange.length > 0) {
        return NO;
    }
    NSString *tab = [self singleTab];
    NSUInteger position = view.selectedRange.location;
    if (position < tab.length) {
        return NO;
    }
    NSRange possibleTabRange = NSMakeRange(position-tab.length, tab.length);
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
- (NSString *) singleTab {
    NSString *tab = @"\t";
    if (self.shouldUseSpacesAsTabs) {
        tab = @"";
        for (NSUInteger i = 0; i < [self.numberOfSpacesForTab integerValue]; i++) {
            tab = [tab stringByAppendingString:@" "];
        }
    }
    return tab;
}

/**
 Indents multiple lines at once.
 */
- (void) handleMultiLineIndent {
    NSString *tab = [self singleTab];
    NSRange totalRange = NSUnionRange([self lineTextRangeWithRange:view.selectedRange], view.selectedRange);
    NSError *error;
    NSRegularExpression *beginOfLine = [NSRegularExpression regularExpressionWithPattern:@"^" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:&error];
    NSString *string = [view.string substringWithRange:totalRange];
    NSMutableString *mString = [string mutableCopy];
    NSRange newRange = NSMakeRange(0, mString.length-1);
    [beginOfLine replaceMatchesInString:mString options:0 range:newRange withTemplate:tab];
    [view insertText:mString replacementRange:totalRange];
    [view setSelectedRange:totalRange];
    
}

- (void)handleNewLineInsertion {
    NSUInteger position = view.selectedRange.location;
    NSString *lineBreak = @"\n";
    if (self.shouldAutoIndentLines) {
        NSRange lineRange = [view.string lineRangeForRange:NSMakeRange(position, 0)];
        lineBreak = [lineBreak stringByAppendingString:[self whiteSpacesAtLineBeginning:lineRange]];
        
    } 
[view insertText:lineBreak];
}

- (NSString *)whiteSpacesAtLineBeginning:(NSRange)lineRange {
    NSRange rangeOfFirstMatch = [SPACE_AT_LINE_BEGINNING rangeOfFirstMatchInString:[view string] options:0 range:lineRange];
    if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
        return [view.string substringWithRange:rangeOfFirstMatch];
    
    }
    return @"";
}

- (BOOL)handleWrappingInRange:(NSRange)textRange {
    if (view.lineWrapMode != HardWrap && !view.hardWrapAfter) {
        return NO;
    }
    NSUInteger wrapAfter = [view.hardWrapAfter integerValue];
    NSError *error;
    NSString *longLinesPattern = [NSString stringWithFormat:@"^(?:.{%ld,})$", wrapAfter+1];
    NSRegularExpression *longLineRegex = [NSRegularExpression regularExpressionWithPattern:longLinesPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    
    if (error) {
        NSLog(@"regex error in long line regex: %@", error);
        return NO;
    }
    [view.undoManager beginUndoGrouping];
    NSArray *longLines = [longLineRegex matchesInString:view.string options:0 range:textRange];
    BOOL result = NO;
    for (NSTextCheckingResult *line in [longLines reverseObjectEnumerator]) {
        NSRange lineRange = [line range];
        result = result || [self handleWrappingInLine:lineRange];
    }
    [view.undoManager endUndoGrouping];
    return result;
}

- (BOOL)handleWrappingInLine:(NSRange)lineRange {
    NSUInteger wrapAfter = [view.hardWrapAfter integerValue];
    if (view.lineWrapMode != HardWrap || lineRange.length <= wrapAfter) {
        return NO;
    }
    [view.undoManager beginUndoGrouping];
    NSString *newLineInsertion = [@"\n" stringByAppendingString:[self whiteSpacesAtLineBeginning:lineRange]];
    NSDictionary *attributes = [view.textStorage attributesAtIndex:lineRange.location effectiveRange:NULL];
    NSAttributedString *insertion = [[NSAttributedString alloc]initWithString:newLineInsertion attributes:attributes];


NSArray *spaces = [SPACE_REGEX matchesInString:view.string options:0 range:lineRange];
    NSUInteger goodPositionToBreak = NSNotFound;
    NSUInteger lastBreakLocation = lineRange.location;
    NSUInteger offset = 0;
    NSUInteger counter = 0;
    for (NSTextCheckingResult *match in spaces) {
        counter++;
        NSRange matchRange = [match range];
        matchRange.location += offset;
        NSUInteger currentPosition = NSMaxRange(matchRange);
        
        if (matchRange.location-lastBreakLocation <= wrapAfter || currentPosition-lastBreakLocation <= wrapAfter || goodPositionToBreak == NSNotFound) {
            // Break after the spaces:
            goodPositionToBreak = currentPosition;
        }
        if ((currentPosition-lastBreakLocation >= wrapAfter || (counter == spaces.count && NSMaxRange(lineRange)-lastBreakLocation >= wrapAfter) ) && goodPositionToBreak != NSNotFound) {
            [view.textStorage insertAttributedString:insertion atIndex:goodPositionToBreak];
            [view.undoManager registerUndoWithTarget:self selector:@selector(deleteWrapping:) object:NSStringFromRange(NSMakeRange(goodPositionToBreak, insertion.length))];
            [view.undoManager setActionName:NSLocalizedString(@"Line Wrap", "wrap undo")];
            offset += insertion.length;
            lastBreakLocation = goodPositionToBreak+1;
            goodPositionToBreak = NSNotFound;
        }
    }
    [view.undoManager endUndoGrouping];
    return YES;
}

- (void)deleteWrapping:(NSString *)range {
    NSRange real = NSRangeFromString(range);
    NSString *newLineInsertion = [view.string substringWithRange:real];
    
    [view.textStorage deleteCharactersInRange:real];
    [[view.undoManager prepareWithInvocationTarget:self] insertWrapping:newLineInsertion atIndex:real.location];
    [view.undoManager setActionName:NSLocalizedString(@"Line Wrap", "wrap undo")];
    
}

- (void)insertWrapping:(NSString *)insertion atIndex:(NSUInteger)index {
    NSDictionary *attributes = [view.textStorage attributesAtIndex:index effectiveRange:NULL];
    NSAttributedString *final = [[NSAttributedString alloc]initWithString:insertion attributes:attributes];
    [view.textStorage insertAttributedString:final atIndex:index];
    [view.undoManager registerUndoWithTarget:self selector:@selector(deleteWrapping:) object:NSStringFromRange(NSMakeRange(index, insertion.length))];
    [view.undoManager setActionName:NSLocalizedString(@"Line Wrap", "wrap undo")];
}

#pragma mark -
#pragma mark Setter & Getter

- (void)setCurrentLineColor:(NSColor *)currentLineColor {
    _currentLineColor = currentLineColor;
    [self highlightCurrentLine];
}

- (void)setShouldHighlightCurrentLine:(BOOL)shouldHighlightCurrentLine {
    _shouldHighlightCurrentLine = shouldHighlightCurrentLine;
    [self highlightCurrentLine];
}

- (void)setCarretColor:(NSColor *)carretColor {
    _carretColor = carretColor;
    [view setInsertionPointColor:carretColor];
    [self highlightCarret];
}

- (void)setShouldHighlightCarret:(BOOL)shouldHighlightCarret {
    _shouldHighlightCarret = shouldHighlightCarret;
    [self highlightCarret];
}

- (void)setCurrentLineTextColor:(NSColor *)currentLineTextColor {
    _currentLineTextColor = currentLineTextColor;
    [self highlightCurrentLine];
}

- (void)setShouldHighlightCurrentLineText:(BOOL)shouldHighlightCurrentLineText{
    _shouldHighlightCurrentLineText = shouldHighlightCurrentLineText;
    [self highlightCurrentLine];
}


- (void) updateViewDrawing {
    if ([view lockFocusIfCanDraw]) {
        [view drawRect:view.visibleRect];
        [view unlockFocus];
    }
}

- (void)dealloc {
    [view.undoManager removeAllActionsWithTarget:self];
}

@end
