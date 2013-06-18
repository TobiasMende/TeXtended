//
//  TMTSplitView.h
//  TeXtended
//
//  Created by Tobias Mende on 13.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TMTSplitView : NSSplitView {
    NSMutableArray *collapseState;
    NSMutableArray *defaultPosition;
}
- (BOOL) isCollapsed:(NSUInteger)index;
- (void) toggleCollapseFor:(NSUInteger)index;
- (void) uncollapse:(NSUInteger)index;
- (void) collapse:(NSUInteger)index;
- (CGFloat)positionOfDividerAtIndex:(NSInteger)dividerIndex;


- (NSUInteger)indexForView:(NSView*)view;
- (NSView*)viewForIndex:(NSUInteger)index;
@end
