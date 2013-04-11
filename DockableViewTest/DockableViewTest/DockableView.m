//
//  DockableView.m
//  DockableViewTest
//
//  Created by Tobias Mende on 06.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DockableView.h"
@implementation DockableView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView setAutoresizesSubviews:YES];
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor lightGrayColor] set];
    NSRectFill([self frame]);
}

- (void)addContentView:(NSView *)view {
    NSLog(@"addContentView");
    [self.contentView setSubviews:[NSArray arrayWithObject:view]];
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:views]];
    [self setNeedsUpdateConstraints:YES];
    
}

- (IBAction)showDebugOutput:(id)sender {
    
    NSLog(@"Subviews in content view: %ld", [[self.contentView subviews] count]);
    NSLog(@"Content View: %@ with frame: %@", self.contentView, NSStringFromRect([self.contentView frame]));
  
}
@end
