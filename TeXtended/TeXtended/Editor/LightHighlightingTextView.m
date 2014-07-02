//
//  LightHighlightingTextView.m
//  TeXtended
//
//  Created by Tobias Mende on 02.07.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "LightHighlightingTextView.h"
#import "LatexSyntaxHighlighter.h"
#import "TextViewLayoutManager.h"
#import "Constants.h"
@implementation LightHighlightingTextView



- (void)awakeFromNib
{
    
    NSDictionary *option = @{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName};
    [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FOREGROUND_COLOR] options:option];
    [self bind:@"backgroundColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_BACKGROUND_COLOR] options:option];
    
    
    _syntaxHighlighter = [[LatexSyntaxHighlighter alloc] initWithTextView:self];
    if (self.string.length > 0) {
        [self.syntaxHighlighter highlightEntireDocument];
    }
    [self setRichText:NO];
    [self setDisplaysLinkToolTips:YES];
    [self setHorizontallyResizable:YES];
    [self setVerticallyResizable:YES];
    [self setSmartInsertDeleteEnabled:NO];
    [self setAutomaticTextReplacementEnabled:NO];
    [self setAutomaticDashSubstitutionEnabled:NO];
    [self setAutomaticQuoteSubstitutionEnabled:NO];
    [self setUsesFontPanel:NO];
    
    
    [self.textContainer replaceLayoutManager:[TextViewLayoutManager new]];
    
}


- (void)insertLineBreak:(id)sender {
    [self.undoManager beginUndoGrouping];
    [self insertText:@"\\\\"];
    [self insertNewline:self];
    [self.undoManager endUndoGrouping];
}

- (void)insertNewlineIgnoringFieldEditor:(id)sender {
    [self.undoManager beginUndoGrouping];
    [self insertNewline:self];
    [self insertText:@"\\item"];
    [self.undoManager endUndoGrouping];
}

- (void)updateSyntaxHighlighting
{
    [self.syntaxHighlighter highlightRange:[self extendedVisibleRange]];
}

- (NSRange)extendedVisibleRange {
    return NSMakeRange(0, self.string.length);
}

- (void)paste:(id)sender {
    [super paste:sender];
    [self.syntaxHighlighter highlightEntireDocument];
}

- (void)setString:(NSString *)string
{
    [super setString:string];
    [self.syntaxHighlighter highlightEntireDocument];
}


@end
