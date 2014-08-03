//
//  TMTLatexTableView.m
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTLatexTableView.h"


static const NSArray *LETTERS;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
@interface TMTLatexTableView ()
- (void)executeSelector:(SEL)aSelector;
- (NSString *)identifierForColumn:(NSUInteger) column;
@end
@implementation TMTLatexTableView

+ (void)initialize {
    LETTERS = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString*   const   character   =   [theEvent charactersIgnoringModifiers];
    unichar     const   code        =   [character characterAtIndex:0];
    if (theEvent.modifierFlags & NSCommandKeyMask) {
        switch (code) {
            case NSUpArrowFunctionKey:
                [self executeSelector:self.cmdArrowUpAction];
                break;
            case NSDownArrowFunctionKey:
                [self executeSelector:self.cmdArrowDownAction];
                break;
            case NSLeftArrowFunctionKey:
                [self executeSelector:self.cmdArrowLeftAction];
                break;
            case NSRightArrowFunctionKey:
                [self executeSelector:self.cmdArrowRightAction];
                break;
            default:
                [super keyDown:theEvent];
                break;
        }
    } else if(theEvent.modifierFlags & NSAlternateKeyMask) {
        switch (code) {
            case NSUpArrowFunctionKey:
                [self executeSelector:self.altArrowUpAction];
                break;
            case NSDownArrowFunctionKey:
                [self executeSelector:self.altArrowDownAction];
                break;
            case NSLeftArrowFunctionKey:
                [self executeSelector:self.altArrowLeftAction];
                break;
            case NSRightArrowFunctionKey:
                [self executeSelector:self.altArrowRightAction];
                break;
            default:
                [super keyDown:theEvent];
                break;
        }
    } else {
        [super keyDown:theEvent];
    }
}

- (void)executeSelector:(SEL)aSelector {
    if (self.target && aSelector && [self.target respondsToSelector:aSelector]) {
        [self.target performSelector:aSelector withObject:self];
    }
}


- (void)addTableColumnAtIndex:(NSUInteger)index {
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"DefaultColumn"];
    [column.headerCell setAlignment:NSCenterTextAlignment];
    [self addTableColumn:column];
    for (NSUInteger i = index; i < self.numberOfColumns; i++) {
        [[self.tableColumns[i] headerCell] setStringValue:[self identifierForColumn:i]];
    }
}

- (void)removeTableColumnAtIndex:(NSUInteger)index {
    [self removeTableColumnAtIndex:index];
    for (NSUInteger i = index; i < self.numberOfColumns; i++) {
        [[self.tableColumns[i] headerCell] setStringValue:[self identifierForColumn:i]];
    }
}


- (void)setNumberOfColumns:(NSInteger)num {
    while (num > self.tableColumns.count) {
        [self addTableColumnAtIndex:self.tableColumns.count];
    }
    while (num < self.tableColumns.count) {
        [self removeTableColumnAtIndex:self.tableColumns.count-1];
    }
}

- (NSString *)identifierForColumn:(NSUInteger)column {
    NSMutableString *string = [NSMutableString new];
    while (column > 0) {
        column--;
        NSUInteger mod = column % LETTERS.count;
        [string appendString:LETTERS[mod]];
        column -= mod;
        column /= LETTERS.count;
    }
    NSMutableString *reversedString = [NSMutableString stringWithCapacity:[string length]];
    
    [string enumerateSubstringsInRange:NSMakeRange(0,[string length])
                               options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                [reversedString appendString:substring];
                            }];
    return reversedString;
}


@end
#pragma clang diagnostic pop
