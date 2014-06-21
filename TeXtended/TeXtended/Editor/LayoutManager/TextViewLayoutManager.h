//
//  TextViewLayoutManager.h
//  TeXtended
//
//  Created by Tobias Hecht on 16.11.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TextViewLayoutManager : NSLayoutManager
    {
        NSGlyph space;

        NSGlyph bulletspace;

        NSGlyph lb;

        NSGlyph arrowlb;
    }

    @property NSColor *symbolColor;

    @property BOOL shouldReplaceInvisibleSpaces;

    @property BOOL shouldReplaceInvisibleLineBreaks;

@end
