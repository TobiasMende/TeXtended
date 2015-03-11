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
#import <TMTHelperCollection/NSTextView+LatexExtensions.h>
#import <TMTHelperCollection/NSString+TMTExtensions.h>

@implementation LightHighlightingTextView


- (void)awakeFromNib {

    NSDictionary *option = @{NSValueTransformerNameBindingOption : NSUnarchiveFromDataTransformerName};
    [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FOREGROUND_COLOR] options:option];
    [self bind:@"backgroundColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_BACKGROUND_COLOR] options:option];
    [self bind:@"automaticSpellingCorrectionEnabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMTAutomaticSpellingCorrection] options:nil];


    _syntaxHighlighter = [[LatexSyntaxHighlighter alloc] initWithTextView:self];
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

- (void)dealloc {
    [self unbind:@"textColor"];
    [self unbind:@"backgroundColor"];
    [self unbind:@"automaticSpellingCorrectionEnabled"];
}

- (BOOL)becomeFirstResponder {
    BOOL become = [super becomeFirstResponder];
    if (!viewStateInitialized) {
        [self.syntaxHighlighter highlightEntireDocument];
        [[NSNotificationCenter defaultCenter] addObserver:self.syntaxHighlighter selector:@selector(highlightAtSelectionChange) name:NSTextViewDidChangeSelectionNotification object:self];
        viewStateInitialized = YES;
    }
    return become;
}

- (void)paste:(id)sender {
    [super paste:sender];
    [self.syntaxHighlighter highlightEntireDocument];
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


#pragma mark - Syntax Highlighting

- (void)updateSyntaxHighlighting {
    [self.syntaxHighlighter highlightRange:[self extendedVisibleRange]];
}

- (NSRange)extendedVisibleRange {
    return NSMakeRange(0, self.string.length);
}


#pragma mark - Getter & Setter

- (NSRange)rangeForLine:(NSUInteger)index {
    return [self.string rangeForLine:index - 1];
}


#pragma mark - Commenting Text

- (IBAction)commentSelection:(id)sender {
    [self commentSelectionInRange:self.selectedRange];
}

- (IBAction)uncommentSelection:(id)sender {
    [self uncommentSelectionInRange:self.selectedRange];
}

- (IBAction)toggleComment:(id)sender {
    [self toggleCommentInRange:self.selectedRange];
}


#pragma mark - Moving Lines

- (IBAction)moveLinesUp:(id)sender {
    if (self.selectedRanges.count != 1) {
        return;
    }
    NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange];
    if (totalRange.location > 0) {
        stopTextDidChangeNotifications = YES;
        NSString *actionName = NSLocalizedString(@"Move Lines", @"moving lines");
        NSRange lineBefore = [self.string lineTextRangeWithRange:NSMakeRange(totalRange.location - 1, 0)];
        [self.undoManager beginUndoGrouping];
        [self swapTextIn:lineBefore and:totalRange];
        [self setSelectedRange:NSMakeRange(lineBefore.location, totalRange.length)];
        [self.undoManager setActionName:actionName];
        [self.undoManager endUndoGrouping];
        stopTextDidChangeNotifications = NO;
        [self didChangeText];
    }
}

- (IBAction)moveLinesDown:(id)sender {
    if (self.selectedRanges.count != 1) {
        return;
    }
    NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange];
    if (NSMaxRange(totalRange) < self.string.length) {
        stopTextDidChangeNotifications = YES;
        NSString *actionName = NSLocalizedString(@"Move Lines", @"moving lines");
        NSRange nextLine = [self.string lineTextRangeWithRange:NSMakeRange(NSMaxRange(totalRange) + 1, 0)];
        [self.undoManager beginUndoGrouping];
        [self swapTextIn:totalRange and:nextLine];
        [self setSelectedRange:[self firstRangeAfterSwapping:totalRange and:nextLine]];
        [self.undoManager setActionName:actionName];
        [self.undoManager endUndoGrouping];
        stopTextDidChangeNotifications = NO;
        [self didChangeText];
    }
}

- (IBAction)deleteLines:(id)sender {
    if (self.selectedRanges.count != 1) {
        return;
    }
    NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange withLineTerminator:YES];

    [self deleteTextInRange:[NSValue valueWithRange:totalRange] withActionName:NSLocalizedString(@"Delete Lines", @"line deletion")];


}


#pragma mark - Responder Chain & Notifications


- (void)didChangeText {
    if (!stopTextDidChangeNotifications) {
        [super didChangeText];
    }
}


- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(moveLinesUp:)) {
        NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange];
        return totalRange.location != 0;
    } else if (aSelector == @selector(moveLinesDown:)) {
        NSRange totalRange = [self.string lineTextRangeWithRange:self.selectedRange];
        return NSMaxRange(totalRange) < self.string.length;
    } else {
        return [super respondsToSelector:aSelector];
    }
}


#pragma mark - Debugging

- (id)debugQuickLookObject {
    return self.attributedString;
}
@end
