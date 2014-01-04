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
    }
    
    
    return self;
}

- (void) drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin
{
    NSFont* font = [NSFont fontWithName:[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:TMT_EDITOR_FONT_NAME] size:[[[[NSUserDefaultsController sharedUserDefaultsController]defaults] valueForKey:TMT_EDITOR_FONT_SIZE] floatValue]];
    NSGlyph space = [font glyphWithName:@"space"];
    NSGlyph bulletspace = [font glyphWithName:@"bullet"];
    NSGlyph lb = [font glyphWithName:@"space"];
    NSGlyph arrowlb = [font glyphWithName:@"bullet"];
    
    for (NSUInteger i = glyphsToShow.location; i != glyphsToShow.location + glyphsToShow.length; i++)
    {
        NSUInteger charIndex = [self characterIndexForGlyphAtIndex:i];
        
        unichar c =[[[self textStorage] string] characterAtIndex:charIndex];
        
        if (c == ' ')
        {
            if (self.shouldReplaceInvisibleSpaces) {
                [self replaceGlyphAtIndex:charIndex withGlyph:bulletspace];
                //NSColor color = [[NSColor alloc] init];
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
                //NSColor color = [[NSColor alloc] init];
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

-(void)dealloc
{
}

@end
