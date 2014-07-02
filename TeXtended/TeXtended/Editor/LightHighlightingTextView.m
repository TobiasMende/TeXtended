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


- (void)cancelOperation:(id)sender {
    if (self.delegate && self.cancelOpSelector) {
        [self.delegate performSelector:self.cancelOpSelector withObject:sender];
    } else if(self.nextResponder && [self.nextResponder respondsToSelector:@selector(cancelOperation:)]){
        [self.nextResponder cancelOperation:sender];
    }
}
- (void)updateSyntaxHighlighting
{
    [self.syntaxHighlighter highlightRange:[self extendedVisibleRange]];
}

- (NSRange)extendedVisibleRange {
    return NSMakeRange(0, self.string.length);
}


- (NSRange)extendRange:(NSRange)range byLines:(NSUInteger)numLines {
    return [self extendedVisibleRange];
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
