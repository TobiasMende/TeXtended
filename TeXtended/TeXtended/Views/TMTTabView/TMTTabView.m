//
//  TMTTABViewViewController.m
//  TeXtended
//
//  Created by Max Bannach on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <MMTabBarView/MMTabBarView.h>
#import <MMTabBarView/MMTabStyle.h>
#import "MainWindowController.h"
#import "TMTTabViewWindow.h"
#import "TMTTabViewItem.h"
#import "TMTTabView.h"

@interface TMTTabView ()

@end

@implementation TMTTabView

- (id)init {
    self = [super initWithNibName:@"TMTTabView" bundle:nil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [tabBar setStyleNamed:@"Safari"];
    [tabBar setOnlyShowCloseOnHover:YES];
    [tabBar setCanCloseOnlyTab:NO];
    [tabBar setDisableTabClose:NO];
    [tabBar setAllowsBackgroundTabClosing:YES];
    [tabBar setHideForSingleTab:NO];
    [tabBar setShowAddTabButton:NO];
    [tabBar setButtonMinWidth:100];
    [tabBar setButtonMaxWidth:100];
    [tabBar setButtonOptimumWidth:100];
    [tabBar setSizeButtonsToFit:NO];
    [tabBar setUseOverflowMenu:YES];
    [tabBar setAutomaticallyAnimates:YES];
    [tabBar setAllowsScrubbing:YES];
    [tabBar setTearOffStyle:MMTabBarTearOffMiniwindow];
 
    // remove any tabs present in the nib
    for (NSTabViewItem *item in [tabView tabViewItems]) {
       [tabView removeTabViewItem:item];
    }
}

- (void) addTMTTabViewItem:(TMTTabViewItem*) item {
    NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:item];
    [newItem setView:[item view]];
	[tabView addTabViewItem:newItem];
    [tabView selectTabViewItem:newItem];
}

- (void)addNewTabWithTitle:(NSString *)aTitle {
	TMTTabViewItem *newModel = [[TMTTabViewItem alloc] init];
    [newModel setTitle:aTitle];
	NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:newModel];
    [newItem setView:[newModel view]];
	[tabView addTabViewItem:newItem];
    [tabView selectTabViewItem:newItem];
}

- (void)addDefaultTabs {
    [self addNewTabWithTitle:@"Tab"];
    [self addNewTabWithTitle:@"Bar"];
    [self addNewTabWithTitle:@"View"];
}

- (MMTabBarView *)tabBar {
	return tabBar;
}

#pragma mark -
#pragma mark ---- delegate ----

- (BOOL)tabView:(NSTabView *)aTabView shouldAllowTabViewItem:(NSTabViewItem *)tabViewItem toLeaveTabBarView:(MMTabBarView *)tabBarView {
    return YES;
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem inTabBarView:(MMTabBarView *)tabBarView {
	return YES;
}

- (NSDragOperation)tabView:(NSTabView*)aTabView validateDrop:(id<NSDraggingInfo>)sender proposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView {
    return NSDragOperationMove;
}

- (NSDragOperation)tabView:(NSTabView *)aTabView validateSlideOfProposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView {
    return NSDragOperationMove;
}

- (MMTabBarView *)tabView:(NSTabView *)aTabView newTabBarViewForDraggedTabViewItem:(NSTabViewItem *)tabViewItem atPoint:(NSPoint)point {
	NSLog(@"newTabBarViewForDraggedTabViewItem: %@ atPoint: %@", [tabViewItem label], NSStringFromPoint(point));

    
    //FIXME what to do?
    
	//create a new window controller with no tab items
	TMTTabViewWindow *tabWindow = [[TMTTabViewWindow alloc] init];
    [MainWindowController addTabViewWindow:tabWindow];
    
    MMTabBarView *tabBarView = (MMTabBarView *)[aTabView delegate];
    
	id <MMTabStyle> style = [tabBarView style];
    
	NSRect windowFrame = [[tabWindow window] frame];
    point.y += windowFrame.size.height - [[[tabWindow window] contentView] frame].size.height;
	point.x -= [style leftMarginForTabBarView:tabBarView];
    
	[[tabWindow window] setFrameTopLeftPoint:point];
	[[[tabWindow tabView] tabBar] setStyle:style];
    
	return [[tabWindow tabView] tabBar];
}

- (void)tabView:(NSTabView *)aTabView closeWindowForLastTabViewItem:(NSTabViewItem *)tabViewItem {
	NSLog(@"closeWindowForLastTabViewItem: %@", [tabViewItem label]);
	[MainWindowController removeTabViewWindow:(TMTTabViewWindow*)[[self view] window]];
}

- (NSString *)tabView:(NSTabView *)aTabView toolTipForTabViewItem:(NSTabViewItem *)tabViewItem {
	return [tabViewItem label];
}

- (NSString *)accessibilityStringForTabView:(NSTabView *)aTabView objectCount:(NSInteger)objectCount {
	return (objectCount == 1) ? @"item" : @"items";
}

@end
