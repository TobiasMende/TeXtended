//
//  TextViewLayoutManager.m
//  TeXtended
//
//  Created by Tobias Hecht on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "Constants.h"
#import "TextViewLayoutManager.h"

@implementation TextViewLayoutManager

- (id)init
{
    self = [super init];
    
    if (self) {
        NSDictionary *option = @{NSValueTransformerNameBindingOption: NSUnarchiveFromDataTransformerName};
        [self bind:@"symbolColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FOREGROUND_COLOR] options:option];
        [self bind:@"shouldReplaceInvisibleSpaces" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_REPLACE_INVISIBLE_SPACES] options:NULL];
        [self bind:@"shouldReplaceInvisibleLineBreaks" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_REPLACE_INVISIBLE_LINEBREAKS] options:NULL];
        
        [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FONT_NAME] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
    }
    
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSFont* font = [NSFont fontWithName:[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:TMT_EDITOR_FONT_NAME] size:[[[[NSUserDefaultsController sharedUserDefaultsController]defaults] valueForKey:TMT_EDITOR_FONT_SIZE] floatValue]];
    space = [font glyphWithName:@"space"];
    bulletspace = [font glyphWithName:@"bullet"];
    lb = [font glyphWithName:@"space"];
    arrowlb = [font glyphWithName:@"bullet"];
}

- (void) drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin
{
    for (NSUInteger i = glyphsToShow.location; i != glyphsToShow.location + glyphsToShow.length; i++)
    {
        NSUInteger charIndex = [self characterIndexForGlyphAtIndex:i];
        
        unichar c =[[[self textStorage] string] characterAtIndex:charIndex];
        
        if (c == ' ')
        {
            if (self.shouldReplaceInvisibleSpaces) {
                [self replaceGlyphAtIndex:charIndex withGlyph:bulletspace];
                NSRange range = NSMakeRange(i, 1);
                [self addTemporaryAttribute:NSForegroundColorAttributeName value:[self.symbolColor colorWithAlphaComponent:0.25] forCharacterRange:range];
            }
            else
            {
                [self replaceGlyphAtIndex:charIndex withGlyph:space];
            }
        }
        
        if (c == '\n') {
            if (self.shouldReplaceInvisibleLineBreaks) {
                [self replaceGlyphAtIndex:charIndex withGlyph:arrowlb];
                NSRange range = NSMakeRange(i, 1);
                [self addTemporaryAttribute:NSForegroundColorAttributeName value:[self.symbolColor colorWithAlphaComponent:0.25] forCharacterRange:range];
            }
            else
            {
                [self replaceGlyphAtIndex:charIndex withGlyph:lb];
            }
        }
    }
    
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

- (void)dealloc {
    [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FONT_NAME]];
}

@end
