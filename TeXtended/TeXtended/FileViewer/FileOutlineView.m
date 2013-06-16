//
//  FileOutLineView.m
//  TeXtended
//
//  Created by Tobias Hecht on 01.05.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "FileOutlineView.h"

@implementation FileOutlineView

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    return self;
}

@end
