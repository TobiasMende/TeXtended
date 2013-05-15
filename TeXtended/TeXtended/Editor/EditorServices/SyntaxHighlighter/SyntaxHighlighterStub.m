//
//  SyntaxHighlighterStub.m
//  TeXtended
//
//  Created by Tobias Mende on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "SyntaxHighlighterStub.h"

@implementation SyntaxHighlighterStub
- (void)highlightEntireDocument {
    NSLog(@"Highlighting entire Document");
}

- (void)highlightVisibleArea {
    NSLog(@"Highlighting visible area");
}

- (void)highlightNarrowArea {
    NSLog(@"Highlighting narrow area");
}

- (void)highlightRange:(NSRange)range {
    NSLog(@"Highlighting range %@", NSStringFromRange(range));
}

@end
