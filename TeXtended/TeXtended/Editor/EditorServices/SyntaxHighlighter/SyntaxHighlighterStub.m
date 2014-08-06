//
//  SyntaxHighlighterStub.m
//  TeXtended
//
//  Created by Tobias Mende on 15.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "SyntaxHighlighterStub.h"
#import <TMTHelperCollection/TMTLog.h>

LOGGING_DEFAULT

@implementation SyntaxHighlighterStub

    - (id)initWithTextView:(HighlightingTextView *)tv
    {
        self = [super initWithTextView:tv];
        if (self) {
            DDLogInfo(@"Init with text view %@", tv);
        }
        return self;
    }

    - (void)highlightEntireDocument
    {
        DDLogInfo(@"Highlighting entire Document");
    }

    - (void)highlightVisibleArea
    {
        DDLogInfo(@"Highlighting visible area");
    }

    - (void)highlightNarrowArea
    {
        DDLogInfo(@"Highlighting narrow area");
    }

    - (void)highlightRange:(NSRange)range
    {
        DDLogInfo(@"Highlighting range %@", NSStringFromRange(range));
    }

    - (void)dealloc
    {
        DDLogDebug(@"dealloc");
    }

@end
