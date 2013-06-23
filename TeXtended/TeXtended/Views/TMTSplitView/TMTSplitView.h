//
//  TMTSplitView.h
//  TeXtended
//
//  Created by Tobias Mende on 13.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 The TMTSplitView is an extension fo the default NSSplitView for handling the programatically collapsing and uncollapsing of subview
 
 @warning At the current state instances of this class might do random things if you add more than two subviews. Furthermore this view isn't able to detect direct manipulation of the dividers by the user at the moment.
 
 **Author:** Tobias Mende
 
 */
@interface TMTSplitView : NSSplitView {
    /** The collapse state of each subview */
    NSMutableArray *collapseState;
    
    /** The default devider position for each subview */
    NSMutableArray *defaultPosition;
    
    NSMutableArray *relativePosition;
}

/**
 Method for checking if the view at the current index is collapsed or not.
 
 @param index the views index
 
 @return `YES` if the view is collapsed, `NO` otherwise.
 */
- (BOOL) isCollapsed:(NSUInteger)index;

/**
 Method for toggling the collapse state for the view with the given index
 
 @param index the views index
 
 */
- (void) toggleCollapseFor:(NSUInteger)index;

/**
 Method for uncollapsing the view with the given index
 
 @param index the views index
 
 */
- (void) uncollapse:(NSUInteger)index;

/**
 Method for collapsing the view with the given index
 
 @param index the views index
 
 */
- (void) collapse:(NSUInteger)index;

/**
 Getter for the position of the divider with the given index
 
 @param dividerIndex the dividers index
 
 @return the position
 */
- (CGFloat)positionOfDividerAtIndex:(NSInteger)dividerIndex;

/**
 Getter for the index of a given subview
 
 @param view the subview
 
 @return the index of `NSNotFound` if the provided view is not a subview.
 */
- (NSUInteger)indexForView:(NSView*)view;

/**
 Method for getting a subview by its index.
 
 @param index the views index
 
 @return the view or `nil` if the index is out of the receivers bounds.
 */
- (NSView*)viewForIndex:(NSUInteger)index;
@end
