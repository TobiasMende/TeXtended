//
//  TMTLatexTableView.m
//  TMTLatexTable
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTLatexTableView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
@interface TMTLatexTableView ()
- (void)executeSelector:(SEL)aSelector;
@end
@implementation TMTLatexTableView

- (void)keyDown:(NSEvent *)theEvent {
    if (theEvent.modifierFlags & NSCommandKeyMask) {
        switch (theEvent.keyCode) {
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
                break;
        }
    } else if(theEvent.modifierFlags & NSAlternateKeyMask) {
        switch (theEvent.keyCode) {
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
                break;
        }
    }
}

- (void)executeSelector:(SEL)aSelector {
    if (self.target && aSelector && [self.target respondsToSelector:aSelector]) {
        [self.target performSelector:aSelector withObject:self];
    }
}

@end
#pragma clang diagnostic pop
