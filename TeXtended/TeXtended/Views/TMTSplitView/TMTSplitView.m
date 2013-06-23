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
        relativePosition = [NSMutableArray array];
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
    
    [self calculateRelativePositions];
}

- (void)setSubviews:(NSArray *)newSubviews {
    [super setSubviews:newSubviews];
    [self refreshSubviews];
}

- (void)refreshSubviews {
    collapseState = [NSMutableArray arrayWithCapacity:self.subviews.count];
    defaultPosition = [NSMutableArray arrayWithCapacity:self.subviews.count];
    relativePosition = [NSMutableArray arrayWithCapacity:self.subviews.count];
    for (NSView *view in self.subviews) {
        [collapseState addObject:[NSNumber numberWithBool:[super isSubviewCollapsed:view]]];
        [defaultPosition addObject:[NSNumber numberWithFloat:0]];
        [relativePosition addObject:[NSNumber numberWithFloat:0]];
    }
    
    [self calculateRelativePositions];
}

- (void)calculateRelativePositions
{
    CGFloat sum = 0;
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        if (self.isVertical) {
            CGFloat sizeOfSuperview = self.bounds.size.width;
            NSView *view = [self.subviews objectAtIndex:i];
            CGFloat sizeOfView = view.bounds.size.width;
            sum += sizeOfView/sizeOfSuperview;
            [relativePosition replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:sum]];
        } else {
            CGFloat sizeOfSuperview = self.bounds.size.height;
            NSView *view = [self.subviews objectAtIndex:i];
            CGFloat sizeOfView = view.bounds.size.height;
            sum += sizeOfView/sizeOfSuperview;
            [relativePosition replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:sum]];
        }
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
    CGFloat positionOfNextDivider;
    CGFloat positionOfPreviousDivider;
    CGFloat sizeOfView;
    
    if (self.isVertical) {
        sizeOfView = self.bounds.size.width;
    } else {
        sizeOfView = self.bounds.size.height;
    }
    
    if (index == self.subviews.count -1) {
        oldPosition = [self positionOfDividerAtIndex:index-1];
        [self setPosition:[self maxPossiblePositionOfDividerAtIndex:index-1] ofDividerAtIndex:index-1];
        positionOfPreviousDivider = [self positionOfPreviousDividerAtIndex:index-2];
        oldPosition = (oldPosition-positionOfPreviousDivider)/(sizeOfView-positionOfPreviousDivider);
    } else {
        oldPosition = [self positionOfDividerAtIndex:index];
        [self setPosition:[self minPossiblePositionOfDividerAtIndex:index] ofDividerAtIndex:index];
        positionOfPreviousDivider = [self positionOfPreviousDividerAtIndex:index-1];
        positionOfNextDivider = [self positionOfNextDividerAtIndex:index+1];
        oldPosition = 1-(positionOfNextDivider-oldPosition)/(positionOfNextDivider-positionOfPreviousDivider);
    }
    
    [collapseState replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:YES]];
    if (defaultPosition.count > index) {
        [defaultPosition replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:oldPosition]];
    } else {
        [defaultPosition insertObject:[NSNumber numberWithFloat:oldPosition] atIndex:index];
    }
}

- (void)uncollapse:(NSUInteger)index {
    CGFloat relPosition = [[defaultPosition objectAtIndex:index] floatValue];
    CGFloat positionOfNextDivider;
    CGFloat positionOfPreviousDivider;
    CGFloat position;
    
    if (index == self.subviews.count -1) {
        positionOfPreviousDivider = [self positionOfPreviousDividerAtIndex:index-2];
        positionOfNextDivider = [self positionOfNextDividerAtIndex:index];
        position = (positionOfNextDivider-positionOfPreviousDivider)*relPosition+ positionOfPreviousDivider;
        [self setPosition:position ofDividerAtIndex:index-1];
    } else {
        positionOfPreviousDivider = [self positionOfPreviousDividerAtIndex:index-1];
        positionOfNextDivider = [self positionOfNextDividerAtIndex:index];
        position = (positionOfNextDivider-positionOfPreviousDivider)*relPosition+ positionOfPreviousDivider;
        [self setPosition:position ofDividerAtIndex:index];
    }
    
    [collapseState replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
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
    
    NSRect priorViewFrame = [[[self subviews] objectAtIndex:dividerIndex] frame];
    return [self isVertical] ? NSMaxX(priorViewFrame) : NSMaxY(priorViewFrame);
}

- (CGFloat)positionOfPreviousDividerAtIndex:(NSInteger)dividerIndex {
    // It looks like NSSplitView relies on its subviews being ordered left->right or top->bottom so we can too.
    // It also raises w/ array bounds exception if you use its API with dividerIndex > count of subviews.
    while (dividerIndex >= 0 && [self isSubviewCollapsed:[[self subviews] objectAtIndex:dividerIndex]])
        dividerIndex--;
    if (dividerIndex < 0)
        return 0.0f;
    
    NSRect priorViewFrame = [[[self subviews] objectAtIndex:dividerIndex] frame];
    return [self isVertical] ? NSMaxX(priorViewFrame) : NSMaxY(priorViewFrame);
}

- (CGFloat)positionOfNextDividerAtIndex:(NSInteger)dividerIndex {
    // It looks like NSSplitView relies on its subviews being ordered left->right or top->bottom so we can too.
    // It also raises w/ array bounds exception if you use its API with dividerIndex > count of subviews.
    while (dividerIndex < [[self subviews] count]-1 && [self isSubviewCollapsed:[[self subviews] objectAtIndex:dividerIndex]])
        dividerIndex++;
    if (dividerIndex >= [[self subviews] count]-1)
        return [self isVertical] ? self.bounds.size.width : self.bounds.size.height;
    
    NSRect priorViewFrame = [[[self subviews] objectAtIndex:dividerIndex] frame];
    return [self isVertical] ? NSMaxX(priorViewFrame) : NSMaxY(priorViewFrame);
}

@end
