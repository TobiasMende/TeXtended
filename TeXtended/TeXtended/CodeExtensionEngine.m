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
NSRegularExpression *TEXDOC_LINKS;
NSString *TEXDOC_PREFIX = @"texdoc://";
@interface CodeExtensionEngine()

- (void) removeTexdocAttributesForRange:(NSRange) range;
- (void) invalidateTexdocLinks;

@end

@implementation CodeExtensionEngine


+(void)initialize {
    NSString *backslash = [NSRegularExpression escapedPatternForString:@"\\"];
    NSString *pattern = [NSString stringWithFormat:@"%@(usepackage|RequirePackage)\\{(.*)\\}", backslash];
    NSError *error;
    TEXDOC_LINKS = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        NSLog(@"Error!");
    }
}

- (id)initWithTextView:(HighlightingTextView *)tv {
    self = [super initWithTextView:tv];
    if (self) {
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        
        /*
         Initial setup of the highlighting colors
         */
        
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
    
    NSArray *texdocRanges = [TEXDOC_LINKS matchesInString:view.string options:0 range:range];
    for (NSTextCheckingResult *match in texdocRanges) {
        if ([match numberOfRanges] > 2) {
            NSRange mRange = [match rangeAtIndex:2];
            NSString *package = [view.string substringWithRange:mRange];
            NSString *link = [NSString stringWithFormat:@"%@%@", TEXDOC_PREFIX, package];
            [self removeTexdocAttributesForRange:mRange];
            if (self.shouldLinkTexdoc) {
                
                [view.textStorage addAttribute:NSLinkAttributeName value:link range:mRange];
                [view.textStorage addAttribute:NSToolTipAttributeName value:[@"Open documentation for " stringByAppendingString:package] range:mRange];
                [view.textStorage addAttribute:NSForegroundColorAttributeName value:self.texdocColor range:mRange];
                if (self.shouldUnderlineTexdoc) {
                    [view.textStorage addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:mRange];
                }
            }
        }
    }
}

- (void)invalidateTexdocLinks {
    [self addTexdocLinksForRange:[view visibleRange]];
}

- (void)removeTexdocAttributesForRange:(NSRange)range {
    [view.textStorage removeAttribute:NSLinkAttributeName range:range];
    [view.textStorage removeAttribute:NSToolTipAttributeName range:range];
    [view.textStorage removeAttribute:NSForegroundColorAttributeName range:range];
    [view.textStorage removeAttribute:NSUnderlineStyleAttributeName range:range];
}

- (BOOL)clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    NSString *url = (NSString*) link;
    if ([[url substringToIndex:TEXDOC_PREFIX.length] isEqualToString:TEXDOC_PREFIX]) {
        NSString *packageName = [url substringFromIndex:TEXDOC_PREFIX.length];
        NSLog(@"texdoc for Package: %@", packageName);
        NSTask *task = [[NSTask alloc] init];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        
        NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
        NSString *command = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_PATH_TO_TEXDOC]];
        //FIXME: Don't hard code!
        [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pathVariables, @"PATH",  nil]];
        [task setLaunchPath:command];
        NSArray	*args = [NSArray arrayWithObjects:@"-q", @"-M", packageName,
                         nil];
        [task setArguments: args];
        [task launch];
        return YES;
    }
    return NO;
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

@end
