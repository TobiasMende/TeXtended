//
//  CodeExtensionEngine.m
//  TeXtended
//
//  Created by Tobias Mende on 22.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "CodeExtensionEngine.h"
#import "HighlightingTextView.h"
#import "Constants.h"
#import "TexdocViewController.h"
#import "TexdocEntry.h"
#import "SpellCheckingService.h"
#import "TexdocController.h"

#define BOUNDING_RECT_KEY @"TMTBoundingRectKey"
static const NSRegularExpression *TEXDOC_LINKS;
static NSString *TEXDOC_PREFIX = @"texdoc://";
static const NSSet *KEYS_TO_UNBIND;
@interface CodeExtensionEngine()
/**
 Removes all texdoc attributes for all texdoc links within the given range
 
 @param range the range to update
 */
- (void) removeTexdocAttributesForRange:(NSRange) range;

/**
 Deletes all texdoc links from the document
 */
- (void) invalidateTexdocLinks;

/**
 Adds texdoc links if some are found within the given range
 
 @param range the range to update
 */
- (void) addTexdocLinksForRange:(NSRange) range;


/** 
 This methods parses the provided answer of the texdoc command into an array of [TexdocEntry] objects
 @param texdocList the texdoc command machine readable answer
 */
- (NSMutableArray*) parseTexdocList:(NSString *)texdocList;

- (void)unbindAll;

@end

@implementation CodeExtensionEngine


+(void)initialize {
    KEYS_TO_UNBIND = [NSSet setWithObjects:@"texdocColor",@"shouldLinkTexdoc", @"shouldUnderlineTexdoc", nil];
    
    NSString *pattern = [NSString stringWithFormat:@"(?:\\\\usepackage|\\\\RequirePackage)[\\s\\S]*?\\{(.*)\\}"];
    NSError *error;
    TEXDOC_LINKS = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        NSLog(@"CodeExtensionEngine: %@", error.userInfo);
    }
}

- (id)initWithTextView:(HighlightingTextView *)tv {
    self = [super initWithTextView:tv];
    if (self) {
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        
        popover = [[NSPopover alloc] init];
        popover.animates = YES;
        popover.behavior = NSPopoverBehaviorTransient;
        
        self.texdocColor = [NSUnarchiver unarchiveObjectWithData:[[defaults values] valueForKey:TMT_TEXDOC_LINK_COLOR]];
        [self bind:@"texdocColor" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_TEXDOC_LINK_COLOR] options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:NSValueTransformerNameBindingOption]];
        
        self.shouldLinkTexdoc = [[[defaults values] valueForKey:TMT_SHOULD_LINK_TEXDOC] boolValue];
        [self bind:@"shouldLinkTexdoc" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_LINK_TEXDOC] options:NULL];
        
        self.shouldUnderlineTexdoc = [[[defaults values] valueForKey:TMT_SHOULD_UNDERLINE_TEXDOC_LINKS] boolValue];
        [self bind:@"shouldUnderlineTexdoc" toObject:defaults withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_UNDERLINE_TEXDOC_LINKS] options:NULL];
    }
    return self;
}


- (void)addLinksForRange:(NSRange)range {
    if (self.shouldLinkTexdoc) {
        [self addTexdocLinksForRange:range];
    }
    
}

- (void)addTexdocLinksForRange:(NSRange)range {
    if (lastUpdate && lastUpdate.timeIntervalSinceNow > -1) {
        //  return;
    }
    lastUpdate = [NSDate new];
    NSString *str = view.string;
    NSLayoutManager *lm = view.layoutManager;

    NSArray *texdocRanges = [TEXDOC_LINKS matchesInString:str options:0 range:range];
    NSString *pattern = @"(\\w|@|_|-)+";
    NSError *error;
    NSRegularExpression *split = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    for (NSTextCheckingResult *match in texdocRanges) {
        if ([match numberOfRanges] > 1) {
            NSRange mRange = [match rangeAtIndex:1];
            // [self removeTexdocAttributesForRange:mRange];
            NSArray *matches = [split matchesInString:str options:0 range:mRange];
            for (NSTextCheckingResult *r in matches) {
                NSRange finalRange = [r rangeAtIndex:0];
                NSString *package = [str substringWithRange:finalRange];
                [view.spellCheckingService addWordToIgnore:package];
                NSString *link = [NSString stringWithFormat:@"%@%@", TEXDOC_PREFIX, package];
                if (self.shouldLinkTexdoc) {
                    
                    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:3];
                    [attributes setObject:link forKey:NSLinkAttributeName];
                    [attributes setObject:[@"Open documentation for " stringByAppendingString:package] forKey:NSToolTipAttributeName];
                    [attributes setObject:self.texdocColor forKey:NSForegroundColorAttributeName];
                    if (self.shouldUnderlineTexdoc) {
                        [attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
                    }
                    [lm addTemporaryAttributes:attributes forCharacterRange:finalRange];
                }
            }
        }
    }
    if (texdocRanges.count > 0 && self.shouldLinkTexdoc) {
        [view.spellCheckingService updateSpellChecker];
    }
}

- (void)invalidateTexdocLinks {
    [self addTexdocLinksForRange:[view visibleRange]];
}

- (void)removeTexdocAttributesForRange:(NSRange)range {
    [view.layoutManager removeTemporaryAttribute:NSLinkAttributeName forCharacterRange:range];
    [view.layoutManager removeTemporaryAttribute:NSToolTipAttributeName forCharacterRange:range];
    [view.layoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:range];
    [view.layoutManager removeTemporaryAttribute:NSUnderlineStyleAttributeName forCharacterRange:range];
}

- (void)handleLinkAt:(NSUInteger)position {
    NSRange effective;
    NSDictionary *attributes = [view.layoutManager temporaryAttributesAtCharacterIndex:position effectiveRange:&effective];
    NSString *attribute = [attributes objectForKey:NSLinkAttributeName];
    if (attribute) {
        [self clickedOnLink:attribute atIndex:position];
    }
    
}

- (BOOL)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    NSString *url = (NSString*) link;
    if ([[url substringToIndex:TEXDOC_PREFIX.length] isEqualToString:TEXDOC_PREFIX]) {
        NSString *packageName = [url substringFromIndex:TEXDOC_PREFIX.length];
        NSRect boundingRect = [view.layoutManager boundingRectForGlyphRange:NSMakeRange(charIndex, 1) inTextContainer:view.textContainer];
        TexdocController *tc = [[TexdocController alloc] init];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromRect(boundingRect),BOUNDING_RECT_KEY, nil];
        [tc executeTexdocForPackage:packageName withInfo:dict andHandler:self];
        return YES;
    }
    return NO;
}

- (void)texdocReadComplete:(NSMutableArray *)texdocArray withPackageName:(NSString *)package andInfo:(NSDictionary *)info {
   TexdocViewController *texdocView = [[TexdocViewController alloc] init];
   [texdocView setContent:texdocArray];
   [texdocView setPackage:package];
   popover.contentViewController = texdocView;
    NSRect rect = NSRectFromString([info objectForKey:BOUNDING_RECT_KEY]);
   [popover showRelativeToRect:rect ofView:view preferredEdge:NSMaxXEdge];
}

#pragma mark -
#pragma mark Setter & Getter

- (void)setShouldLinkTexdoc:(BOOL)shouldLinkTexdoc {
    _shouldLinkTexdoc = shouldLinkTexdoc;
    [self invalidateTexdocLinks];
}

- (void)setShouldUnderlineTexdoc:(BOOL)shouldUnderlineTexdoc {
    _shouldUnderlineTexdoc = shouldUnderlineTexdoc;
    [self invalidateTexdocLinks];
}

- (void)setTexdocColor:(NSColor *)texdocColor {
    _texdocColor = texdocColor;
    [self invalidateTexdocLinks];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"CodeExtensionEngine dealloc");
#endif
    [self unbindAll];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)unbindAll {
    for(NSString *key in KEYS_TO_UNBIND) {
        [self unbind:key];
    }
}
@end
