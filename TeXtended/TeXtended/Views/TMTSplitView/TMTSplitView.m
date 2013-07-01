//
//  TMTSplitView.m
//  TeXtended
//
//  Created by Tobias Mende on 13.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTSplitView.h"
#import <Quartz/Quartz.h>

@interface TMTSplitView ()
- (void) refreshSubviews;
@end

@implementation TMTSplitView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        
        [self refreshSubviews];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        defaultPosition = [NSMutableArray array];
        collapseState = [NSMutableArray array];
        [self refreshSubviews];
    }
    return self;
}

- (void)addSubview:(NSView *)aView {
    [super addSubview:aView];
    [collapseState addObject:[NSNumber numberWithBool:NO]];
    [defaultPosition addObject:[NSNumber numberWithFloat:0]];
}

- (void)adjustSubviews {
    [super adjustSubviews];
}

- (void)setSubviews:(NSArray *)newSubviews {
    [super setSubviews:newSubviews];
    [self refreshSubviews];
}

- (void)refreshSubviews {
    collapseState = [NSMutableArray arrayWithCapacity:self.subviews.count];
    defaultPosition = [NSMutableArray arrayWithCapacity:self.subviews.count];
    for (NSView *view in self.subviews) {
        [collapseState addObject:[NSNumber numberWithBool:[super isSubviewCollapsed:view]]];
        [defaultPosition addObject:[NSNumber numberWithFloat:0]];
    }
}

- (void)toggleCollapseFor:(NSUInteger)index {
    if ([[collapseState objectAtIndex:index] boolValue]) {
        [self uncollapse:index];
    } else {
        [self collapse:index];
    }
    
}

- (void)collapse:(NSUInteger)index {
    CGFloat oldPosition;
    
    if (index == self.subviews.count -1) {
        oldPosition = [self positionOfDividerAtIndex:index-1];
        oldPosition /= self.isVertical ? self.bounds.size.width : self.bounds.size.height;
        [self setPosition:[self maxPossiblePositionOfDividerAtIndex:index-1] ofDividerAtIndex:index-1];
        //[self animateDividerToPosition:[self maxPossiblePositionOfDividerAtIndex:index-1] ofDividerAtIndex:index-1];
        [defaultPosition replaceObjectAtIndex:index-1 withObject:[NSNumber numberWithFloat:oldPosition]];
    } else {
        oldPosition = [self positionOfDividerAtIndex:index];
        oldPosition /= self.isVertical ? self.bounds.size.width : self.bounds.size.height;
        [self setPosition:[self minPossiblePositionOfDividerAtIndex:index] ofDividerAtIndex:index];
        //[self animateDividerToPosition:[self minPossiblePositionOfDividerAtIndex:index] ofDividerAtIndex:index-1];
        [defaultPosition replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:oldPosition]];
    }
    
    [collapseState replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
}

- (void)uncollapse:(NSUInteger)index {
    
    if (index == self.subviews.count -1) {
        CGFloat position = [[defaultPosition objectAtIndex:index-1] floatValue];
        position *= self.isVertical ? self.bounds.size.width : self.bounds.size.height;
        [self setPosition:position ofDividerAtIndex:index-1];
        //[self animateDividerToPosition:position ofDividerAtIndex:index-1];
    } else {
        CGFloat position = [[defaultPosition objectAtIndex:index] floatValue];
        position *= self.isVertical ? self.bounds.size.width : self.bounds.size.height;
        [self setPosition:position ofDividerAtIndex:index];
        //[self animateDividerToPosition:position ofDividerAtIndex:index];
    }
    
    [collapseState replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
}

- (void)animateDividerToPosition:(CGFloat)dividerPosition ofDividerAtIndex:(NSUInteger)index
{
    NSView *view0 = [[self subviews] objectAtIndex:index];
    NSView *view1 = [[self subviews] objectAtIndex:index+1];
    NSRect view0Rect = [view0 frame];
    NSRect view1Rect = [view1 frame];
    NSRect overalRect = [self frame];
    CGFloat dividerThickness = [self dividerThickness];

    if ([self isVertical]) {
        view0Rect.size.width = dividerPosition;
        view1Rect.origin.x = dividerPosition + dividerThickness;
        view1Rect.size.width = overalRect.size.width - view0Rect.size.width - dividerThickness;
    } else {
        view0Rect.size.height = dividerPosition;
        view1Rect.origin.y = dividerPosition + dividerThickness;
        view1Rect.size.height = overalRect.size.height - view0Rect.size.height - dividerThickness;
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.3];
    [[view0 animator] setFrame: view0Rect];
    [[view1 animator] setFrame: view1Rect];
    [NSAnimationContext endGrouping];
}


- (BOOL)isSubviewCollapsed:(NSView *)subview {
    NSUInteger index = [self indexForView:subview];
    return [self isCollapsed:index];// || [super isSubviewCollapsed:subview];
}

- (NSUInteger)indexForView:(NSView *)view {
    for (NSUInteger index = 0; index < self.subviews.count; index++) {
        if ([[self.subviews objectAtIndex:index] isEqualTo:view]) {
            return index;
        }
    }
    return NSNotFound;
}

- (id)viewForIndex:(NSUInteger)index {
    return index < self.subviews.count? [self.subviews objectAtIndex:index] : nil;
}

- (BOOL)isCollapsed:(NSUInteger)index {
    return index < collapseState.count && [collapseState objectAtIndex:index] &&[[collapseState objectAtIndex:index] boolValue];
}

- (CGFloat)positionOfDividerAtIndex:(NSInteger)dividerIndex {
    // It looks like NSSplitView relies on its subviews being ordered left->right or top->bottom so we can too.
    // It also raises w/ array bounds exception if you use its API with dividerIndex > count of subviews.
    //while (dividerIndex >= 0 && [self isSubviewCollapsed:[[self subviews] objectAtIndex:dividerIndex]])
    //    dividerIndex--;
    if (dividerIndex < 0) {
        return 0.0f;
    }
    
    NSRect priorViewFrame = [[[self subviews] objectAtIndex:dividerIndex] frame];
    return [self isVertical] ? NSMaxX(priorViewFrame) : NSMaxY(priorViewFrame);
}

@end
