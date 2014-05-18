//
//  DefaultCompletionView.m
//  TeXtended
//
//  Created by Tobias Mende on 19.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DefaultCompletionView.h"

@implementation DefaultCompletionView

    - (id)initWithFrame:(NSRect)frame
    {
        self = [super initWithFrame:frame];
        if (self) {
            // Initialization code here.
        }
        return self;
    }

    - (void)drawRect:(NSRect)dirtyRect
    {
        [super drawRect:dirtyRect];

        // Drawing code here.
    }

    + (NSInteger)defaultViewHeight
    {
        return 16;
    }

@end
