//
//  TMTOutlineView.m
//  TeXtended
//
//  Created by Tobias Mende on 26.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTOutlineView.h"

@implementation TMTOutlineView

    - (NSRect)frameOfOutlineCellAtRow:(NSInteger)row
    {
        return NSZeroRect;
    }

    - (BOOL)isItemExpanded:(id)item
    {
        return YES;
    }

    - (BOOL)isExpandable:(id)item
    {
        return YES;
    }

    - (void)awakeFromNib
    {
        [super awakeFromNib];
        [self expandItem:nil expandChildren:YES];
    }
@end
