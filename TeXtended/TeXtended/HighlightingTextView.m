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
    if(self.string.length > 0) {
        [regexHighlighter highlightEntireDocument];
    }
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_BACKGROUND_COLOR] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_SELECTION_FOREGROUND_COLOR] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:NULL];
    [self setDelegate:self];


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
}

- (void)updateSyntaxHighlighting {
    [regexHighlighter highlightVisibleArea];
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
}

-(void)setString:(NSString *)string {
    [super setString:string];
    [regexHighlighter highlightEntireDocument];
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


- (void)keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
    [codeNavigationAssistant highlightCarret];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    [codeNavigationAssistant highlightCarret];
}

#pragma mark -
#pragma mark Drawing Actions

- (void) drawViewBackgroundInRect:(NSRect)rect
{
    [super drawViewBackgroundInRect:rect];
    [codeNavigationAssistant highlightCurrentLine];
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

@end
