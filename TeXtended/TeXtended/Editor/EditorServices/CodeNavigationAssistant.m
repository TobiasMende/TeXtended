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
#import "Constants.h"
static const NSSet *WHITESPACES;
static const NSRegularExpression *SPACE_REGEX;
static const NSRegularExpression *SPACE_AT_LINE_BEGINNING;
static const NSRegularExpression *FIRST_NONWHITESPACE_IN_LINE;
static const NSSet *KEYS_TO_UNBIND;
static const NSSet *KEYS_TO_OBSERVE;


@interface CodeNavigationAssistant ()
- (void) unbindAll;

- (void) handleMultiLineIndent;

- (void) handleMultiLineUnindent;

- (NSString *) singleTab;
@end

@implementation CodeNavigationAssistant

+ (void)initialize {
    KEYS_TO_UNBIND = [NSSet setWithObjects:@"currentLineColor",@"shouldHighlightCurrentLine",@"currentLineTextColor",@"shouldHighlightCurrentLineText",@"carretColor",@"shouldHighlightCarret",@"shouldUseSpacesAsTabs",@"shouldAutoIndentLines",@"numberOfSpacesForTab", nil];
    KEYS_TO_OBSERVE = [NSSet setWithObjects:@"currentLineColor",@"shouldHighlightCurrentLine",@"currentLineTextColor",@"shouldHighlightCurrentLineText",@"carretColor",@"shouldHighlightCarret", nil];
    
    WHITESPACES = [NSSet setWithObjects:@" ",@"\t", nil];
    NSError *error;
    SPACE_AT_LINE_BEGINNING = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\p{z}|\\t)*" options:NSRegularExpressionAnchorsMatchLines error:&error];
    SPACE_REGEX = [NSRegularExpression regularExpressionWithPattern:@"(?:\\t| )+(?!$)" options:NSRegularExpressionAnchorsMatchLines error:&error];
    FIRST_NONWHITESPACE_IN_LINE = [NSRegularExpression regularExpressionWithPattern:@"^(?:\\s*)(\\S)(?:.*)$" options:NSRegularExpressionAnchorsMatchLines error:&error];
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
        
        for (NSString *key in KEYS_TO_OBSERVE) {
            [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
        }


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
    if (NSMaxRange(range) > view.string.length) {
        return;
    }
    NSLayoutManager *lm = [view layoutManager];
    if (self.shouldHighlightCurrentLineText) {
        NSRange lineRange = [self lineTextRangeWithRange:range];
        
        // [lm removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:lastLineRange];
        [lm addTemporaryAttributes:[NSDictionary dictionaryWithObjectsAndKeys:self.currentLineTextColor, NSForegroundColorAttributeName, nil] forCharacterRange:lineRange];
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

#pragma mark -
#pragma mark Line Getter

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
    return [self lineTextRangeWithRange:range withLineTerminator:NO];
}

- (NSRange)lineTextRangeWithRange:(NSRange)range withLineTerminator:(BOOL)flag {
    NSUInteger rangeStart, contentsEnd,rangeEnd;
    NSRange result;
    if (range.location != NSNotFound && NSMaxRange(range) <= view.string.length) {
        [view.string getLineStart:&rangeStart end:&rangeEnd contentsEnd:&contentsEnd forRange:range];
        
        
        if (flag) {
            NSUInteger length = rangeEnd-rangeStart;
            result =  NSMakeRange(rangeStart, length);
            
        } else {
            NSUInteger length = contentsEnd-rangeStart;
            result =  NSMakeRange(rangeStart, length);
        }
    } else {
        result = NSMakeRange(NSNotFound, 0);
        NSLog(@"Error for provided range: %@",NSStringFromRange(range));
    }
    return result;
}

#pragma mark -
#pragma mark Comment & Uncomment

- (void)commentSelectionInRange:(NSRange)range {
    NSRange lineRange = [self lineTextRangeWithRange:range];
    NSRange tmp = lineRange;
    NSMutableString *area = [[view.string substringWithRange:lineRange] mutableCopy];
    NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];
    for(NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
        NSRange match = [result rangeAtIndex:1];
        [area replaceCharactersInRange:NSMakeRange(match.location, 0) withString:@"%"];
        lineRange.length +=1;
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

- (void)uncommentSelectionInRange:(NSRange)range {
    NSRange lineRange = [self lineTextRangeWithRange:range];
    NSRange tmp = lineRange;
    NSMutableString *area = [[view.string substringWithRange:lineRange] mutableCopy];
     NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];
    BOOL actionDone = NO;
    for(NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
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


- (void)toggleCommentInRange:(NSRange)range {
    NSRange lineRange = [self lineTextRangeWithRange:range];
    NSRange tmp = lineRange;
    NSMutableString *area = [[view.string substringWithRange:lineRange] mutableCopy];
    NSArray *matches = [FIRST_NONWHITESPACE_IN_LINE matchesInString:area options:0 range:NSMakeRange(0, area.length)];

    BOOL actionDone = NO;
    for(NSTextCheckingResult *result in [matches reverseObjectEnumerator]) {
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

- (void)uncommentSelectionInRangeString:(NSString *)range {
    [self uncommentSelectionInRange:NSRangeFromString(range)];
}

- (void)commentSelectionInRangeString:(NSString *)range {
    [self commentSelectionInRange:NSRangeFromString(range)];
}

- (void)toggleCommentInRangeString:(NSString *)range {
    [self toggleCommentInRange:NSRangeFromString(range)];
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
    if (view.selectedRanges.count > 1 ) {
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
    if (view.selectedRanges.count > 1) {
        return NO;
    }
    NSRange lineRange = [self lineTextRangeWithRange:view.selectedRange];
    if (lineRange.location != NSNotFound) {
        NSRange totalRange = NSUnionRange(lineRange
                                          , view.selectedRange);
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
    totalRange.length = mString.length;
    [view setSelectedRange:totalRange];
    
}

- (void) handleMultiLineUnindent {
    NSString *pattern = [NSString stringWithFormat:@"^(\\t| {%li})", self.numberOfSpacesForTab.integerValue];
    NSRange totalRange = NSUnionRange([self lineTextRangeWithRange:view.selectedRange], view.selectedRange);
    NSError *error;
    NSRegularExpression *beginOfLine = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:&error];
    NSString *string = [view.string substringWithRange:totalRange];
    NSMutableString *mString = [string mutableCopy];
    NSRange newRange = NSMakeRange(0, mString.length-1);
    [beginOfLine replaceMatchesInString:mString options:0 range:newRange withTemplate:@""];
    [view insertText:mString replacementRange:totalRange];
    totalRange.length = mString.length;
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
    NSMutableString *content = [[NSMutableString alloc] initWithString:view.string];
    NSUInteger wrapAfter = [view.hardWrapAfter integerValue];
    NSError *error;
    NSString *longLinesPattern = [NSString stringWithFormat:@"^(?:.{%ld,})$", wrapAfter+1];
    NSRegularExpression *longLineRegex = [NSRegularExpression regularExpressionWithPattern:longLinesPattern options:NSRegularExpressionAnchorsMatchLines error:&error];
    
    if (error) {
        NSLog(@"regex error in long line regex: %@", error);
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

- (BOOL)handleWrappingInLine:(NSRange)lineRange {
    NSUInteger wrapAfter = [view.hardWrapAfter integerValue];
    if (view.lineWrapMode != HardWrap || lineRange.length <= wrapAfter) {
        return NO;
    }
    [view.undoManager beginUndoGrouping];
    NSString *newLineInsertion = @"\n";
    if (self.shouldAutoIndentLines) {
        newLineInsertion = [newLineInsertion stringByAppendingString:[self whiteSpacesAtLineBeginning:lineRange]];
    }
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
        if ((currentPosition-lastBreakLocation >= wrapAfter || (counter == spaces.count && NSMaxRange(lineRange)-lastBreakLocation >= wrapAfter) ) && goodPositionToBreak != NSNotFound ) {
            [view.undoSupport insertText:insertion atIndex:goodPositionToBreak withActionName:NSLocalizedString(@"Line Wrap", "wrap undo")];
         
            offset += insertion.length;
            lastBreakLocation = goodPositionToBreak+1;
            goodPositionToBreak = NSNotFound;
        }
    }

    [view.undoManager endUndoGrouping];
    return YES;
}

- (BOOL)handleWrappingInLine:(NSRange)lineRange ofString:(NSMutableString *)string {
    NSUInteger wrapAfter = [view.hardWrapAfter integerValue];
    if (view.lineWrapMode != HardWrap || lineRange.length <= wrapAfter) {
        return NO;
    }
    NSString *newLineInsertion = @"\n";
    if (self.shouldAutoIndentLines) {
        newLineInsertion = [newLineInsertion stringByAppendingString:[self whiteSpacesAtLineBeginning:lineRange]];
    }

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
            [string insertString:newLineInsertion atIndex:goodPositionToBreak];
            
            offset += newLineInsertion.length;
            lastBreakLocation = goodPositionToBreak+1;
            goodPositionToBreak = NSNotFound;
        }
    }
    return YES;
}





- (void) updateViewDrawing {
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self] && [KEYS_TO_OBSERVE containsObject:keyPath]) {
        if ([keyPath isEqualToString:@"carretColor"]) {
            [view setInsertionPointColor:self.carretColor];
            [self highlightCarret];
        } else if([keyPath isEqualToString:@"shouldHighlightCarret"]) {
            [self highlightCarret];
        } else {
            [self highlightCurrentLine];
        }
    }
}


- (void)dealloc {
#ifdef DEBUG
    NSLog(@"CodeNavigationAssistant dealloc");
#endif
    [self unbindAll];
}

- (void)unbindAll {
    for(NSString *key in KEYS_TO_UNBIND) {
        [self unbind:key];
    }
    for(NSString *key in KEYS_TO_OBSERVE) {
        [self removeObserver:self forKeyPath:key];
    }
}

@end
