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
NSRegularExpression *TEXDOC_LINKS;
NSString *TEXDOC_PREFIX = @"texdoc://";
@interface CodeExtensionEngine()

- (void) removeTexdocAttributesForRange:(NSRange) range;
- (void) invalidateTexdocLinks;
- (void) texdocReadComplete:(NSNotification *)notification andBoundingRect:(NSRect) rect;
- (NSMutableArray*) parseTexdocList:(NSString *)texdocList;

@end

@implementation CodeExtensionEngine


+(void)initialize {
    NSString *backslash = [NSRegularExpression escapedPatternForString:@"\\"];
    NSString *pattern = [NSString stringWithFormat:@"%@(usepackage|RequirePackage)(\\[.*\\]|\\s)*\\{(.*)\\}", backslash];
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
    
    NSArray *texdocRanges = [TEXDOC_LINKS matchesInString:view.string options:0 range:range];
    NSString *pattern = @"(\\w|@|_)+";
    NSError *error;
    NSRegularExpression *split = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    for (NSTextCheckingResult *match in texdocRanges) {
       
        if ([match numberOfRanges] > 3) {
            NSRange mRange = [match rangeAtIndex:3];
            [self removeTexdocAttributesForRange:mRange];
            NSArray *matches = [split matchesInString:view.string options:0 range:mRange];
            for (NSTextCheckingResult *r in matches) {
                NSRange finalRange = [r rangeAtIndex:0];
                NSString *package = [view.string substringWithRange:finalRange];
                NSString *link = [NSString stringWithFormat:@"%@%@", TEXDOC_PREFIX, package];
                if (self.shouldLinkTexdoc) {
                    
                    [view.layoutManager addTemporaryAttribute:NSLinkAttributeName value:link forCharacterRange:finalRange];
                    [view.layoutManager addTemporaryAttribute:NSToolTipAttributeName value:[@"Open documentation for " stringByAppendingString:package] forCharacterRange:finalRange];
                    [view.layoutManager addTemporaryAttribute:NSForegroundColorAttributeName value:self.texdocColor forCharacterRange:finalRange];
                    if (self.shouldUnderlineTexdoc) {
                        [view.layoutManager addTemporaryAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] forCharacterRange:finalRange];
                    }
                }
            }
        }
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
        NSLog(@"texdoc for Package: %@", packageName);
        NSTask *task = [[NSTask alloc] init];
        NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
        
        NSString *pathVariables = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_ENVIRONMENT_PATH]];
        NSString *command = [defaults valueForKeyPath:[@"values." stringByAppendingString:TMT_PATH_TO_TEXDOC]];
        //FIXME: Don't hard code!
        [task setEnvironment:[NSDictionary dictionaryWithObjectsAndKeys:pathVariables, @"PATH",  nil]];
        [task setLaunchPath:command];
        NSArray	*args = [NSArray arrayWithObjects:@"-l", @"-M", packageName,
                         nil];
        NSPipe *outputPipe = [NSPipe pipe];
        NSRect boundingRect = [view.layoutManager boundingRectForGlyphRange:NSMakeRange(charIndex, 1) inTextContainer:view.textContainer];
        [task setStandardOutput:outputPipe];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(texdocReadComplete:andBoundingRect:) name:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading]];
        [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self texdocReadComplete:note andBoundingRect:boundingRect];
        }];
        [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
        [task setArguments: args];
        [task launch];
        return YES;
    }
    return NO;
}

- (void)texdocReadComplete:(NSNotification *)notification andBoundingRect:(NSRect)rect{
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *texdocArray = [self parseTexdocList:string];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];
    
    TexdocViewController *texdocView = [[TexdocViewController alloc] init];
    [texdocView setContent:texdocArray];
    popover.contentViewController = texdocView;
    [popover showRelativeToRect:rect ofView:view preferredEdge:NSMaxXEdge];
    
}

- (NSMutableArray *)parseTexdocList:(NSString *)texdocList {
    if (texdocList.length == 0) {
        return nil;
    }
    NSArray *lines = [texdocList componentsSeparatedByString:@"\n"];
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:lines.count];
    for (NSString *line in lines) {
        NSArray *entry = [line componentsSeparatedByString:@"\t"];
        TexdocEntry *e = [[TexdocEntry alloc] initWithArray:entry];
        if (e) {
            [result addObject:e];
        }
    }
    
    
    return result;
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
