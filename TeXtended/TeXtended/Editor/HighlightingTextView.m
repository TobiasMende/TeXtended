//
//  HighlightingTextView.m
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "HighlightingTextView.h"
#import "SyntaxHighlighter.h"
#import "BracketHighlighter.h"
#import "CodeNavigationAssistant.h"
#import "NSString+LatexExtension.h"
#import "PlaceholderServices.h"
#import "EditorPlaceholder.h"
#import "CompletionHandler.h"
#import "CodeExtensionEngine.h"
@implementation HighlightingTextView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    
    return self;
}

- (void)awakeFromNib {
     NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:NSUnarchiveFromDataTransformerName,NSValueTransformerNameBindingOption, nil];
    [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FOREGROUND_COLOR] options:option];
    [self bind:@"backgroundColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_BACKGROUND_COLOR] options:option];
    
    [self bind:@"font" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FONT] options:option];
    regexHighlighter = [[SyntaxHighlighter alloc] initWithTextView:self];
    bracketHighlighter = [[BracketHighlighter alloc] initWithTextView:self];
    codeNavigationAssistant = [[CodeNavigationAssistant alloc] initWithTextView:self];
    placeholderService = [[PlaceholderServices alloc] initWithTextView:self];
    completionHandler = [[CompletionHandler alloc] initWithTextView:self];
    codeExtensionEngine = [[CodeExtensionEngine alloc] initWithTextView:self];
    if(self.string.length > 0) {
        [regexHighlighter highlightEntireDocument];
    }
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_BACKGROUND_COLOR] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_FOREGROUND_COLOR] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    [self setDelegate:self];

    [self setRichText:NO];
    [self setGrammarCheckingEnabled:NO];
    [self setDisplaysLinkToolTips:YES];
    [self setContinuousSpellCheckingEnabled:NO];
    [self setAutomaticSpellingCorrectionEnabled:NO];
    [self setWrappingEnabled:NO];
}


- (void) setWrappingEnabled:(BOOL)wrap {
    //TODO: Handle different wrap modi.
    if (wrap) {
        
    } else {
        [[self textContainer]
         setContainerSize:NSMakeSize(FLT_MAX   , FLT_MAX)];
        [[self textContainer] setWidthTracksTextView:NO];
        [[self textContainer] setHeightTracksTextView:NO];
        [self setAutoresizingMask:NSViewNotSizable];
        [self setMaxSize:NSMakeSize(FLT_MAX,
                                        FLT_MAX)];
        [self setHorizontallyResizable:YES];
        [self setVerticallyResizable:YES];
    }
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
    [placeholderService handleInsertTab];
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    [self updateSyntaxHighlighting];
    [codeNavigationAssistant highlight];
    [codeExtensionEngine addLinksForRange:[self visibleRange]];
}

- (void)updateSyntaxHighlighting {
    [regexHighlighter highlightVisibleArea];
    [codeExtensionEngine addLinksForRange:[self visibleRange]];
}

- (void)insertText:(id)str {
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
    NSRange lineRange = [self.string lineRangeForRange:self.selectedRange];
    [codeExtensionEngine addLinksForRange:lineRange];
}

- (void)insertTab:(id)sender {
    BOOL senderIsCompletionHandler = [sender isKindOfClass:[CompletionHandler class]];
    BOOL placeholderServicesHandles = NO;
    if (!senderIsCompletionHandler) {
        placeholderServicesHandles = [placeholderService handleInsertTab];
    }
    if ( senderIsCompletionHandler|| !placeholderServicesHandles) {
        [codeNavigationAssistant handleTabInsertion];
    } else if (!placeholderServicesHandles) {
        [super insertTab:sender];
    }
    
}

- (void)insertBacktab:(id)sender {
    if (![codeNavigationAssistant handleBacktabInsertion] && ![placeholderService handleInsertBacktab]) {
        [super insertBacktab:sender];
    }
}

- (void)insertNewline:(id)sender {
    [codeNavigationAssistant handleNewLineInsertion];
}

- (void)paste:(id)sender {
    [super paste:sender];
    [regexHighlighter highlightEntireDocument];
    [codeExtensionEngine addLinksForRange:NSMakeRange(0, self.string.length)];
}

-(void)setString:(NSString *)string {
    [super setString:string];
    [regexHighlighter highlightEntireDocument];
    [codeExtensionEngine addLinksForRange:NSMakeRange(0, string.length)];
}

#pragma mark -
#pragma mark Input Actions

- (void)moveLeft:(id)sender {
    [super moveLeft:sender];
    [bracketHighlighter highlightOnMoveLeft];
    
}

- (void)moveRight:(id)sender {
    [super moveRight:sender];
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
    [codeNavigationAssistant highlightCarret];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    [codeNavigationAssistant highlightCarret];
    if (self.selectedRanges.count== 1 || self.selectedRange.length==0) {
        NSUInteger position = self.selectedRange.location;
        [codeExtensionEngine handleLinkAt:position];
    }
    
}


#pragma mark -
#pragma mark Drawing Actions

- (void) drawViewBackgroundInRect:(NSRect)rect
{
    [[NSColor clearColor] set];
    NSRectFill(rect);
    [super drawViewBackgroundInRect:rect];
    [codeNavigationAssistant highlightCurrentLineBackground];
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_FOREGROUND_COLOR]] || [keyPath isEqualToString:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_BACKGROUND_COLOR]]) {
        NSColor *textColor = [NSUnarchiver unarchiveObjectWithData:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_SELECTION_FOREGROUND_COLOR]];
        NSColor *backgroundColor = [NSUnarchiver unarchiveObjectWithData:[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKeyPath:TMT_EDITOR_SELECTION_BACKGROUND_COLOR]];
        NSDictionary *selectionAttributes = [NSDictionary dictionaryWithObjectsAndKeys:textColor,NSForegroundColorAttributeName,backgroundColor,NSBackgroundColorAttributeName, nil];
        [self setSelectedTextAttributes:selectionAttributes];
    }
}

-(void)dealloc {
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self];
}


#pragma mark -
#pragma mark Delegate Methods

- (BOOL)textView:(NSTextView *)textView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    return [codeExtensionEngine clickedOnLink:link atIndex:charIndex];
}


- (NSRange)textView:(NSTextView *)textView willChangeSelectionFromCharacterRange:(NSRange)oldSelectedCharRange toCharacterRange:(NSRange)newSelectedCharRange{
    [codeNavigationAssistant highlightCurrentLineForegroundWithRange:newSelectedCharRange];
    return newSelectedCharRange;
}


@end
