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
        
    }
    
    return self;
}

- (void) drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(NSPoint)origin
{
    NSFont* font = [NSFont fontWithName:[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:TMT_EDITOR_FONT_NAME] size:[[[[NSUserDefaultsController sharedUserDefaultsController]defaults] valueForKey:TMT_EDITOR_FONT_SIZE] floatValue]];
    NSGlyph space = [font glyphWithName:@"space"];
    NSGlyph bulletspace = [font glyphWithName:@"bullet"];
    
    for (NSUInteger i = glyphsToShow.location; i != glyphsToShow.location + glyphsToShow.length; i++)
    {
        NSUInteger charIndex = [self characterIndexForGlyphAtIndex:i];
        
        unichar c =[[[self textStorage] string] characterAtIndex:charIndex];
        
        if (c == ' ')
        {
            if ([[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:TMT_REPLACE_INVISIBLE_SPACES] boolValue]) {
                [self replaceGlyphAtIndex:charIndex withGlyph:bulletspace];
                //NSColor color = [[NSColor alloc] init];
                NSRange range = NSMakeRange(i, 1);
                [self addTemporaryAttribute:NSForegroundColorAttributeName value:[NSColor brownColor] forCharacterRange:range];
            }
            else
            {
                [self replaceGlyphAtIndex:charIndex withGlyph:space];
            }
        }
        
        /*if (c == '\n') {
            [self insertGlyph:[font glyphWithName:@"A"] atGlyphIndex:0 characterIndex:charIndex];
        }*/
    }
    
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
}

@end
