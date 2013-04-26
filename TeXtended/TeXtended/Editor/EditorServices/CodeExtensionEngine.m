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
NSRegularExpression *TEXDOC_LINKS;
NSString *TEXDOC_PREFIX = @"texdoc://";
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
 Callback method for the texdoc task is called after the texdoc command has finished returning a list of possible documents.
 
 @param notification A `NSFileHandleReadToEndOfFileCompletionNotification` after the command output is available as data.
 @param package The package name which was clicked
 @param rect a rect for specifing the position where to show the documents
 */
- (void) texdocReadComplete:(NSNotification *)notification withPackageName:(NSString*)package andBoundingRect:(NSRect) rect;

/** 
 This methods parses the provided answer of the texdoc command into an array of [TexdocEntry] objects
 @param texdocList the texdoc command machine readable answer
 */
- (NSMutableArray*) parseTexdocList:(NSString *)texdocList;

@end

@implementation CodeExtensionEngine


+(void)initialize {
    NSString *pattern = [NSString stringWithFormat:@"(?>\\\\usepackage|\\\\RequirePackage)+(?>\\[[[\\S|\\s]&&[^[\\]|\\[]]]*\\])?\\{(.*)\\}"];
    NSError *error;
    TEXDOC_LINKS = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (error) {
        NSLog(@"Error! %@", error);
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
        if ([match numberOfRanges] > 1) {
            NSRange mRange = [match rangeAtIndex:1];
            [self removeTexdocAttributesForRange:mRange];
            NSArray *matches = [split matchesInString:view.string options:0 range:mRange];
            for (NSTextCheckingResult *r in matches) {
                NSRange finalRange = [r rangeAtIndex:0];
                NSString *package = [view.string substringWithRange:finalRange];
                [view.spellCheckingService addWordToIgnore:package];
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
    if (texdocRanges.count > 0) {
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

        [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            [self texdocReadComplete:note withPackageName:packageName andBoundingRect:boundingRect];
        }];
        [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
        [task setArguments: args];
        [task launch];
        return YES;
    }
    return NO;
}

- (void)texdocReadComplete:(NSNotification *)notification withPackageName:(NSString*) package andBoundingRect:(NSRect)rect{
    NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *texdocArray = [self parseTexdocList:string];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];
    
    TexdocViewController *texdocView = [[TexdocViewController alloc] init];
    [texdocView setContent:texdocArray];
    [texdocView setPackage:package];
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
