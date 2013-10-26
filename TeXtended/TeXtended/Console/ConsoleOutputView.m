//
//  ConsoleView.m
//  TeXtended
//
//  Created by Tobias Mende on 06.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "ConsoleOutputView.h"
#import "Constants.h"
#import "PathFactory.h"
#import "DocumentCreationController.h"
#import "SimpleDocument.h"
#import "DocumentModel.h"
#import "ConsoleViewController.h"
#import "DocumentController.h"
#import "TMTLog.h"
#import "TMTNotificationCenter.h"

static const NSRegularExpression *ERROR_LINES_EXPRESSION;
static const NSSet *KEYS_TO_UNBIND;
@interface ConsoleOutputView ()
- (void) stringDidChange;
- (void) makeLinkFor:(NSRange)pathRange andLine:(NSRange)lineRange;
- (void) handleLinkAt:(NSUInteger) position;
- (void) clearAttachments;
@end



@implementation ConsoleOutputView


+ (void)initialize {
    if (self == [ConsoleOutputView class]) {
        KEYS_TO_UNBIND = [NSSet setWithObjects:@"shouldUnderlineLinks",@"linkColor", nil];
        NSString *regex = @"^([.|/].*?):(.*?): (.*)(?:\\n|.)*?^(l\\.(?:.*))$";
        NSError *error;
        ERROR_LINES_EXPRESSION = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionAnchorsMatchLines error:&error];
        if (error) {
            DDLogError(@"Error while generating log file parser regex: %@", [error userInfo]);
        }
    }
}



- (void)awakeFromNib {
    NSDictionary *option = [NSDictionary dictionaryWithObjectsAndKeys:NSUnarchiveFromDataTransformerName,NSValueTransformerNameBindingOption, nil];
    [self bind:@"textColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FOREGROUND_COLOR] options:option];
    [self bind:@"backgroundColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_BACKGROUND_COLOR] options:option];
    [self bind:@"font" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_EDITOR_FONT] options:option];
    [self bind:@"linkColor" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:TMT_TEXDOC_LINK_COLOR] options:option];
    [self bind:@"shouldUnderlineLinks" toObject:[NSUserDefaultsController sharedUserDefaultsController]  withKeyPath:[@"values." stringByAppendingString:TMT_SHOULD_UNDERLINE_TEXDOC_LINKS] options:NULL];
    [self addObserver:self forKeyPath:@"string" options:NSKeyValueObservingOptionNew context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqualTo:self] && [keyPath isEqualToString:@"string"]) {
        [self stringDidChange];
    }
}


- (void)stringDidChange {
    NSString *content = self.string;
    [self clearAttachments];
    NSArray *matches = [ERROR_LINES_EXPRESSION matchesInString:self.string options:0 range:NSMakeRange(0, content.length)];
    for (NSTextCheckingResult *match in matches) {
        if (match.numberOfRanges < 5) {
            continue;
        }
        
        NSRange pathRange = [match rangeAtIndex:1];
        NSRange lineRange = [match rangeAtIndex:2];
        NSRange descriptionRange = [match rangeAtIndex:3];
        NSRange infoRange = [match rangeAtIndex:4];
        [self makeLinkFor:pathRange andLine:lineRange];
        [self.layoutManager addTemporaryAttribute:NSObliquenessAttributeName value:[NSNumber numberWithFloat:0.25] forCharacterRange:descriptionRange];
        NSShadow* shadw = [[NSShadow alloc] init];
        [shadw setShadowColor:[NSColor grayColor]];
        [shadw setShadowOffset:NSMakeSize( 0, -1 )];
        [shadw setShadowBlurRadius:2.0];
        
        NSDictionary *highlightingAttributes = [NSDictionary dictionaryWithObjectsAndKeys:shadw, NSShadowAttributeName,[NSNumber numberWithFloat:0.25], NSObliquenessAttributeName, nil];
        
        [self.layoutManager addTemporaryAttributes:highlightingAttributes forCharacterRange:descriptionRange];
        [self.layoutManager addTemporaryAttributes:highlightingAttributes forCharacterRange:infoRange];
    }
    
}

- (void)makeLinkFor:(NSRange)pathRange andLine:(NSRange)lineRange {
    NSRange combined = NSMakeRange(pathRange.location, pathRange.length+lineRange.length+1);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithCapacity:3];
    NSString *link = [self.string substringWithRange:combined];
    [attributes setObject:link forKey:NSLinkAttributeName];
    [attributes setObject:self.linkColor forKey:NSForegroundColorAttributeName];
    if (self.shouldUnderlineLinks) {
        [attributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
    }
    [self.layoutManager addTemporaryAttributes:attributes forCharacterRange:combined];

}

- (void)mouseDown:(NSEvent *)theEvent {
    [super mouseDown:theEvent];
    
    if (self.selectedRanges.count== 1 || self.selectedRange.length==0) {
        NSUInteger position = self.selectedRange.location;
        [self handleLinkAt:position];
    }
    
}

-(void)clearAttachments {
    NSRange total = NSMakeRange(0, self.string.length);
    [self.layoutManager removeTemporaryAttribute:NSLinkAttributeName forCharacterRange:total];
    [self.layoutManager removeTemporaryAttribute:NSForegroundColorAttributeName forCharacterRange:total];
    [self.layoutManager removeTemporaryAttribute:NSUnderlineStyleAttributeName forCharacterRange:total];
}

- (void)handleLinkAt:(NSUInteger)position {
    NSRange effective;
    NSDictionary *attributes = [self.layoutManager temporaryAttributesAtCharacterIndex:position effectiveRange:&effective];
    NSString *attribute = [attributes objectForKey:NSLinkAttributeName];
    if (!attribute) {
        return;
    }
    NSArray *values = [attribute componentsSeparatedByString:@":"];
    NSString *path = [values objectAtIndex:0];
    NSUInteger line = [[values objectAtIndex:1] integerValue];
    DocumentModel *compiledModel = self.controller.model;
    DocumentModel *documentsModel = self.controller.documentController.model;
    path = [PathFactory absolutPathFor:path withBasedir:[compiledModel.texPath stringByDeletingLastPathComponent]];
    
    if ([path isEqualToString:compiledModel.texPath]) {
        [[TMTNotificationCenter centerForCompilable:compiledModel] postNotificationName:TMTShowLineInTextViewNotification object:documentsModel userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:line] forKey:TMTIntegerKey]];
    } else if(documentsModel.project){
        //TODO: Hanlde external path in project mode
        NSBeep();
    } else {
        // Open new single document:
        NSURL *url = [NSURL fileURLWithPath:path];
        [[DocumentCreationController sharedDocumentController] openDocumentWithContentsOfURL:url display:YES completionHandler:^(NSDocument *document, BOOL documentWasAlreadyOpen, NSError *error) {
            if (error) {
                [[NSWorkspace sharedWorkspace] openURL:url];
            } else {
                if ([document isKindOfClass:[SimpleDocument class]]) {
                    DocumentModel *m = [(SimpleDocument*) document model];
                    [[TMTNotificationCenter centerForCompilable:m] postNotificationName:TMTShowLineInTextViewNotification object:m userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:line] forKey:TMTIntegerKey]];
                    if (self.controller.consoleMessages) {
                        [[TMTNotificationCenter centerForCompilable:m] postNotificationName:TMTLogMessageCollectionChanged object:m userInfo:[NSDictionary dictionaryWithObject:self.controller.consoleMessages forKey:TMTMessageCollectionKey]];
                    }
                }
            }
        }];
    }
}


- (void)dealloc {
    DDLogError(@"dealloc");
    for (NSString *key in KEYS_TO_UNBIND) {
        [self unbind:key];
    }
    [self removeObserver:self forKeyPath:@"string"];
    
}

@end
