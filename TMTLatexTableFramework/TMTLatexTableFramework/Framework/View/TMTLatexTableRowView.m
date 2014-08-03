//
//  TMTLatexTableRowView.m
//  TMTLatexTableFramework
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "TMTLatexTableRowView.h"
#import "TMTLatexTableCellView.h"
#import "TMTLatexTableCellModel.h"

@implementation TMTLatexTableRowView

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

- (void)drawBackgroundInRect:(NSRect)dirtyRect {
    
    [super drawBackgroundInRect:dirtyRect];

}


- (NSBackgroundStyle)interiorBackgroundStyle {
    return NSBackgroundStyleLight;
}
@end
