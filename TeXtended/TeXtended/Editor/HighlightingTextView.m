//
//  HighlightingTextView.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "HighlightingTextView.h"
#import "LatexSyntaxHighlighter.h"
#import "BracketHighlighter.h"
#import "CodeNavigationAssistant.h"
#import "NSString+LatexExtension.h"
#import "PlaceholderServices.h"
#import "EditorPlaceholder.h"
#import "CompletionHandler.h"
#import "CodeExtensionEngine.h"
#import "UndoSupport.h"
#import "SpellCheckingService.h"
#import "LineNumberView.h"
#import "GoToLineSheetController.h"
static const NSSet *DEFAULT_KEYS_TO_OBSERVE;
@interface HighlightingTextView()
- (NSRange) firstRangeAfterSwapping:(NSRange)first and:(NSRange)second;
- (void)swapTextIn:(NSRange)first and:(NSRange)second;
- (void) registerUserDefaultsObserver;
- (void) unregisterUserDefaultsObserver;
@end
@implementation HighlightingTextView

+ (void)initialize {
    if (self == [HighlightingTextView class]) {
        DEFAULT_KEYS_TO_OBSERVE = [NSSet setWithObjects:TMT_EDITOR_SELECTION_BACKGROUND_COLOR,TMT_EDITOR_SELECTION_FOREGROUND_COLOR,TMT_EDITOR_LINE_WRAP_MODE,TMT_EDITOR_HARD_WRAP_AFTER, nil];
    }
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

- (void)registerUserDefaultsObserver {
    for(NSString *key in DEFAULT_KEYS_TO_OBSERVE) {
         [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:key] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    }
}

- (void)unregisterUserDefaultsObserver {
    for(NSString *key in DEFAULT_KEYS_TO_OBSERVE) {
        [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:[@"values." stringByAppendingString:key]];
    }
}

- (void)awakeFromNib {
    
     NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:NSUnarchiveFromDataTransformerName,NSValueTransformerNameBindingOption, nil];
    [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FOREGROUND_COLOR] options:option];
    [self bind:@"backgroundColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_BACKGROUND_COLOR] options:option];
    
    
    [self bind:@"font" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FONT] options:option];
    _syntaxHighlighter = [[LatexSyntaxHighlighter alloc] initWithTextView:self];
    bracketHighlighter = [[BracketHighlighter alloc] initWithTextView:self];
    _codeNavigationAssistant = [[CodeNavigationAssistant alloc] initWithTextView:self];
    placeholderService = [[PlaceholderServices alloc] initWithTextView:self];
    completionHandler = [[CompletionHandler alloc] initWithTextView:self];
    _codeExtensionEngine = [[CodeExtensionEngine alloc] initWithTextView:self];
    _undoSupport = [[UndoSupport alloc] initWithTextView:self];
    _spellCheckingService = [[SpellCheckingService alloc] initWithTextView:self];
    if(self.string.length > 0) {
        [self.syntaxHighlighter highlightEntireDocument];
    }
    [self registerUserDefaultsObserver];
    [self setRichText:NO];
    [self setDisplaysLinkToolTips:YES];
    [self setAutomaticSpellingCorrectionEnabled:NO];
    [self setHorizontallyResizable:YES];
    [self setVerticallyResizable:YES];
    [self setSmartInsertDeleteEnabled:NO];
    self.servicesOn = YES;
    
    
    
}


- (NSRange) visibleRange
{
    NSRect visibleRect = [self visibleRect];
    NSLayoutManager *lm = [self layoutManager];
    NSTextContainer *tc = [self textContainer];
    
    NSRange glyphVisibleRange = [lm glyphRangeForBoundingRect:visibleRect inTextContainer:tc];;
    NSRange charVisibleRange = [lm characterRangeForGlyphRange:glyphVisibleRange  actualGlyphRange:nil];
    return charVisibleRange;
}


- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    if (!self.servicesOn) {
        return nil;
    }
    if ([completionHandler willHandleCompletionForPartialWordRange:charRange]) {
        [self.undoManager beginUndoGrouping];
        NSArray *completions =[completionHandler completionsForPartialWordRange:charRange indexOfSelectedItem:index];
        [self.undoManager endUndoGrouping];
        return completions;
    }
    return nil;
    //return [super completionsForPartialWordRange:charRange indexOfSelectedItem:index];
}

- (void)complete:(id)sender {
    [super complete:sender];
    
    
}

- (void)insertCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    if (!self.servicesOn) {
        return;
    }
    [completionHandler insertCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
    
}

- (void)insertFinalCompletion:(NSString *)word forPartialWordRange:(NSRange)charRange movement:(NSInteger)movement isFinal:(BOOL)flag {
    if (movement == NSCancelTextMovement || movement == NSLeftTextMovement) {
        [self delete:nil];
        return;
    }
    [super insertCompletion:word forPartialWordRange:charRange movement:movement isFinal:flag];
}

- (void)jumpToNextPlaceholder {
    if (!self.servicesOn) {
        return;
    }
    [placeholderService handleInsertTab];
}

- (void)jumpToPreviousPlaceholder {
    if (!self.servicesOn) {
        return;
    }
    [placeholderService handleInsertBacktab];
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (!self.servicesOn) {
        return;
    }
    [self updateSyntaxHighlighting];
    [self.codeNavigationAssistant highlight];
    [self.codeExtensionEngine addTexdocLinksForRange:[self visibleRange]];
}

- (void)updateSyntaxHighlighting {
    if (!self.servicesOn) {
        return;
    }
    [self.syntaxHighlighter highlightRange:[self extendedVisibleRange]];
    [self.codeExtensionEngine addTexdocLinksForRange:[self visibleRange]];
}


- (NSRange) extendedVisibleRange {
    NSRange range = [self.codeNavigationAssistant lineTextRangeWithRange:self.visibleRange];
    for (NSUInteger iteration = 0; iteration < 10; iteration++) {
        BOOL update = NO;
        if (range.location >0) {
            range.location -= 1;
            range.length +=1;
            update = YES;
        }
        if (NSMaxRange(range) < self.string.length-1 && NSMaxRange(range) >0) {
            range.length += 1;
            update = YES;
        }
        if (update) {
            range = [self.codeNavigationAssistant lineTextRangeWithRange:range];
        } else {
            break;
        }
    }
    return range;
}

- (void)insertText:(id)str {
    if (!self.servicesOn) {
        [super insertText:str];
        return;
    }
    if (![bracketHighlighter shouldInsert:str]) {
        return;
    }
    [super insertText:str];
    if ([str isKindOfClass:[NSAttributedString class]]) {
        return;
    }
    NSUInteger position = [self selectedRange].location;
    // Some services should not run if a latex linebreak occures befor the current position
    if (![self.string latexLineBreakPreceedingPosition:position]) {
        if ([completionHandler shouldCompleteForInsertion:str]) {
            [self complete:self];
        }
    } else {
        NSLog(@"Latex LineBreak");
    }
    [bracketHighlighter handleBracketsOnInsertWithInsertion:str];
    [self.codeExtensionEngine addTexdocLinksForRange:[self visibleRange]];
    NSRange lineRange = [self.string lineRangeForRange:self.selectedRange];
    if([self.codeNavigationAssistant handleWrappingInLine:lineRange]) {
        [self scrollRangeToVisible:self.selectedRange];
    }

}

- (void)goToLine:(id)sender {
    if (!goToLineSheet) {
        goToLineSheet = [[GoToLineSheetController alloc] init];
    }
    goToLineSheet.line = [NSNumber numberWithInteger:self.currentRow];
    goToLineSheet.max = [NSNumber numberWithInteger:self.lineRanges.count];
    [NSApp beginSheet:[goToLineSheet window]
       modalForWindow: [self window]
        modalDelegate: self
       didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo: nil];
    [NSApp runModalForWindow:[self window]];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)context {
    if (returnCode == NSRunStoppedResponse) {
        [self showLine:[goToLineSheet.line integerValue]];
    }
}

- (void)showLine:(NSUInteger)line {
    NSArray *ranges = [self lineRanges];
    if (line <= ranges.count && line > 0) {
        NSTextCheckingResult *r = [ranges objectAtIndex:line-1];
        [self scrollRangeToVisible:r.range];
        [self setSelectedRange:NSMakeRange(r.range.location, 0)];
    } else {
        NSBeep();
    }
    
}

- (NSArray *)lineRanges {
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^.*$" options:NSRegularExpressionAnchorsMatchLines error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error userInfo]);
        return nil;
    }
    
    NSArray *ranges = [regex matchesInString:self.string options:0 range:NSMakeRange(0, self.string.length)];
    return ranges;
    
}


- (void)insertTab:(id)sender {
    if (!self.servicesOn) {
        [super insertTab:sender];
        return;
    }
    BOOL senderIsCompletionHandler = [sender isKindOfClass:[CompletionHandler class]];
    BOOL placeholderServicesHandles = NO;
    if (!senderIsCompletionHandler) {
        placeholderServicesHandles = [placeholderService handleInsertTab];
    }
    if ( senderIsCompletionHandler|| !placeholderServicesHandles) {
        [self.codeNavigationAssistant handleTabInsertion];
    } else if (!placeholderServicesHandles) {
        [super insertTab:sender];
    }
    
}

- (void)insertBacktab:(id)sender {
    if (!self.servicesOn) {
         [super insertBacktab:sender];
        return;
    }
    if (![self.codeNavigationAssistant handleBacktabInsertion] && ![placeholderService handleInsertBacktab]) {
        [super insertBacktab:sender];
    }
}

- (void)insertNewline:(id)sender {
    if (!self.servicesOn) {
        [super insertNewline:sender];
        return;
    }
    [self.codeNavigationAssistant handleNewLineInsertion];
}

- (void)paste:(id)sender {
    [super paste:sender];
    if (!self.servicesOn) {
        return;
    }
    [self.syntaxHighlighter highlightEntireDocument];
    [self.codeExtensionEngine addTexdocLinksForRange:NSMakeRange(0, self.string.length)];
}

-(void)setString:(NSString *)string {
    [super setString:string];
    if (!self.servicesOn) {
        return;
    }
    [self.syntaxHighlighter highlightEntireDocument];
    [self.codeExtensionEngine addTexdocLinksForRange:NSMakeRange(0, self.string.length)];
}


#pragma mark -
#pragma mark Setter & Getter

- (void)setLineWrapMode:(TMTLineWrappingMode)lineWrapMode {
    _lineWrapMode = lineWrapMode;
    
        if (lineWrapMode == SoftWrap) {
            [[self textContainer] setWidthTracksTextView:YES];
            [self setMaxSize:NSMakeSize(self.superview.visibleRect.size.width, FLT_MAX)];
            [self.textContainer setContainerSize:NSMakeSize(self.superview.visibleRect.size.width, FLT_MAX)];
        } else {
            [[self textContainer]
             setContainerSize:NSMakeSize(FLT_MAX   , FLT_MAX)];
            [[self textContainer] setWidthTracksTextView:NO];
            [self setAutoresizingMask:NSViewNotSizable];
            [self setMaxSize:NSMakeSize(FLT_MAX,
                                        FLT_MAX)];
            
        }
}



- (NSUInteger)currentCol {
    return [self colForRange:self.selectedRange];
}

- (NSUInteger)colForRange:(NSRange)range {
    NSUInteger location = 0;
    
    NSRange window = NSMakeRange(range.location, 1);
    while (window.location > 0 && NSMaxRange(window) < self.string.length) {
        if ([[self.string substringWithRange:window] isEqualToString:@"\n"]) {
            return location;
        } else {
            location ++;
            window.location --;
        }
    }
    return location;
}


#pragma mark -
#pragma mark Input Actions

- (void)moveLeft:(id)sender {
    [super moveLeft:sender];
    if (!self.servicesOn) {
        return;
    }
    [bracketHighlighter highlightOnMoveLeft];
    
}

- (void)moveRight:(id)sender {
    [super moveRight:sender];
    if (!self.servicesOn) {
        return;
    }
    [bracketHighlighter highlightOnMoveRight];
}

- (void)moveUp:(id)sender {
    [super moveUp:sender];
    [self setNeedsDisplay:YES];
}

- (void)moveDown:(id)sender {
    [super moveDown:sender];
    [self setNeedsDisplay:YES];

}


- (void)keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
    if (!self.servicesOn) {
        return;
    }
    [self.codeNavigationAssistant highlightCarret];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    if (!self.servicesOn) {
        return;
    }
    [self.codeNavigationAssistant highlightCarret];
    if (self.selectedRanges.count== 1 || self.selectedRange.length==0) {
        NSUInteger position = self.selectedRange.location;
        [self.codeExtensionEngine handleLinkAt:position];
    }
    
}

- (void)hardWrapText:(id)sender {
    
    TMTLineWrappingMode current = self.lineWrapMode;
    self.lineWrapMode = HardWrap;
    [self.codeNavigationAssistant handleWrappingInRange:NSMakeRange(0, self.string.length)];
    self.lineWrapMode = current;
    
}

- (IBAction)deleteLines:(id)sender {
    if (self.selectedRanges.count != 1) {
        return;
    }
    NSRange totalRange = [self.codeNavigationAssistant lineTextRangeWithRange:self.selectedRange];
//    if (totalRange.location > 0) {
//        // Delete line-break before selection.
//        totalRange.location -= 1;
//        totalRange.length +=1;
//    }
    [self.undoSupport deleteTextInRange:[NSValue valueWithRange:totalRange] withActionName:NSLocalizedString(@"Delete Lines", @"line deletion")];


}

- (IBAction)moveLinesDown:(id)sender {
    if (self.selectedRanges.count != 1) {
        return;
    }
    NSRange totalRange = [self.codeNavigationAssistant lineTextRangeWithoutLineBreakWithRange:self.selectedRange];
    if(NSMaxRange(totalRange) < self.string.length) {
        NSString *actionName = NSLocalizedString(@"Move Lines", @"moving lines");
        NSRange nextLine = [self.codeNavigationAssistant lineTextRangeWithoutLineBreakWithRange:NSMakeRange(NSMaxRange(totalRange)+1, 0)];
        [self.undoManager beginUndoGrouping];
        [self swapTextIn:totalRange and:nextLine];
        [self setSelectedRange:[self firstRangeAfterSwapping:totalRange and:nextLine]];
        [self.undoManager setActionName:actionName];
        [self.undoManager endUndoGrouping];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(moveLinesUp:)) {
        NSRange totalRange = [self.codeNavigationAssistant lineTextRangeWithoutLineBreakWithRange:self.selectedRange];
        if (totalRange.location == 0 || totalRange.location == self.textStorage.length) {
            return NO;
        } else {
            return YES;
        }
    } else if(aSelector == @selector(moveLinesDown:)) {
        NSRange totalRange = [self.codeNavigationAssistant lineTextRangeWithoutLineBreakWithRange:self.selectedRange];
        if(NSMaxRange(totalRange) < self.string.length) {
            NSRange nextLine = [self.codeNavigationAssistant lineTextRangeWithoutLineBreakWithRange:NSMakeRange(NSMaxRange(totalRange)+1, 0)];
            if (nextLine.location == self.string.length) {
                return NO;
            } else {
                return YES;
            }
        }
        return NO;
    } else if (aSelector == @selector(commentSelection:) || aSelector == @selector(uncommentSelection:) || aSelector == @selector(toggleComment:)) {
        return self.selectedRanges.count == 1;
    }else {
        return [super respondsToSelector:aSelector];
    }
}


- (IBAction)moveLinesUp:(id)sender {
    if (self.selectedRanges.count != 1) {
        return;
    }
    NSRange totalRange = [self.codeNavigationAssistant lineTextRangeWithoutLineBreakWithRange:self.selectedRange];
    if(totalRange.location > 0) {
        NSString *actionName = NSLocalizedString(@"Move Lines", @"moving lines");
        NSRange lineBefore = [self.codeNavigationAssistant lineTextRangeWithoutLineBreakWithRange:NSMakeRange(totalRange.location-1, 0)];
        [self.undoManager beginUndoGrouping];
        [self swapTextIn:lineBefore and:totalRange];
        [self setSelectedRange:NSMakeRange(lineBefore.location, totalRange.length)];
        [self.undoManager setActionName:actionName];
        [self.undoManager endUndoGrouping];
    }
}
- (NSRange) firstRangeAfterSwapping:(NSRange)first and:(NSRange)second {
    if (second.length > first.length) {
        NSUInteger lengthDif = second.length - first.length;
        first.location = second.location + lengthDif;
        return first;
    } else if (first.length > second.length) {
        NSUInteger lengthDif = first.length-second.length;
        first.location = second.location -lengthDif;
        return first;
    }
    return second;
}

- (void)swapTextIn:(NSRange)first and:(NSRange)second {
    if (first.location > second.location) {
        // Ensure that first range ist before second range
        NSRange tmp = first;
        first = second;
        second = tmp;
    }

// NSLog(@"%@ %@", NSStringFromRange(first), NSStringFromRange(second));
    NSAttributedString *secondStr;
    if (second.length == 0) {
        NSDictionary *attr = [self.textStorage attributesAtIndex:second.location effectiveRange:NULL];
        secondStr = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    } else {
        
        secondStr = [self.textStorage attributedSubstringFromRange:second];
    }
    NSAttributedString *firstStr;
    if (first.length == 0) {
        NSDictionary *attr = [self.textStorage attributesAtIndex:first.location effectiveRange:NULL];
        firstStr = [[NSAttributedString alloc] initWithString:@"" attributes:attr];
    } else {
        
        firstStr = [self.textStorage attributedSubstringFromRange:first];
    }
    if (first.length == 0) {
        [self.undoSupport deleteTextInRange:[NSValue valueWithRange:second] withActionName:@""];
    } else {
        [self insertText:firstStr replacementRange:second];
    }
    if (second.length == 0) {
        [self.undoSupport deleteTextInRange:[NSValue valueWithRange:first] withActionName:@""];
    } else {
        [self insertText:secondStr replacementRange:first];
    }

}


- (void)commentSelection:(id)sender {
    [self.codeNavigationAssistant commentSelectionInRange:self.selectedRange];
}

- (void)uncommentSelection:(id)sender {
    [self.codeNavigationAssistant uncommentSelectionInRange:self.selectedRange];
}

- (void)toggleComment:(id)sender {
    [self.codeNavigationAssistant toggleCommentInRange:self.selectedRange];
}


#pragma mark -
#pragma mark Drawing Actions

- (void) drawViewBackgroundInRect:(NSRect)rect
{
    [[NSColor clearColor] set];
    NSRectFill(rect);
    [super drawViewBackgroundInRect:rect];
    if (!self.servicesOn) {
        return;
    }
     [self.codeNavigationAssistant highlightCurrentLineBackground];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_FOREGROUND_COLOR]] || [keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_BACKGROUND_COLOR]]) {
        NSColor *textColor = [NSUnarchiver unarchiveObjectWithData:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_SELECTION_FOREGROUND_COLOR]];
        NSColor *backgroundColor = [NSUnarchiver unarchiveObjectWithData:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_SELECTION_BACKGROUND_COLOR]];
        NSDictionary *selectionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:textColor,NSForegroundColorAttributeName,backgroundColor,NSBackgroundColorAttributeName, nil];
        [self setSelectedTextAttributes:selectionAttributes];
    } else if([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_LINE_WRAP_MODE]]) {
        self.lineWrapMode = [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_LINE_WRAP_MODE] intValue];
    } else if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_HARD_WRAP_AFTER]]) {
        self.hardWrapAfter = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_HARD_WRAP_AFTER];
    }
}

-(void)dealloc {
#ifdef DEBUG
    NSLog(@"HighlightingTextView dealloc");
#endif
    [self unregisterUserDefaultsObserver];
  
}

@end
