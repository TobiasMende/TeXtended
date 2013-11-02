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
#import "TMTTabViewController.h"
#import "TMTLog.h"
#import "TMTTabViewWindowManager.h"

@interface TMTTabViewController ()

@end

@implementation TMTTabViewController

#pragma mark - Initialize and dealloc
- (id)init {
    self = [super initWithNibName:@"TMTTabViewController" bundle:nil];
    if (self) {
        self.closeWindowForLastTabDrag = YES;
    }
    return self;
}

- (void)awakeFromNib {
    //[tabBar setDelegate:self];
    [tabBar setStyleNamed:@"Safari"];
    [tabBar setOnlyShowCloseOnHover:YES];
    [tabBar setCanCloseOnlyTab:NO];
    [tabBar setDisableTabClose:NO];
    [tabBar setAllowsBackgroundTabClosing:YES];
    [tabBar setHideForSingleTab:NO];
    [tabBar setShowAddTabButton:NO];
    [tabBar setButtonMinWidth:100];
    [tabBar setButtonMaxWidth:200];
    [tabBar setButtonOptimumWidth:100];
    [tabBar setSizeButtonsToFit:YES];
    [tabBar setUseOverflowMenu:YES];
    [tabBar setAutomaticallyAnimates:YES];
    [tabBar setAllowsScrubbing:YES];
    [tabBar setTearOffStyle:MMTabBarTearOffAlphaWindow];
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
}


- (void) addTabViewItem:(TMTTabViewItem*) item {
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



- (MMTabBarView *)tabBar {
	return tabBar;
}

#pragma mark -
#pragma mark Delegate Methods

- (BOOL)tabView:(NSTabView *)aTabView shouldAllowTabViewItem:(NSTabViewItem *)tabViewItem toLeaveTabBarView:(MMTabBarView *)tabBarView {
    return YES;
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem inTabBarView:(MMTabBarView *)tabBarView {
	return YES;
}

- (BOOL)shouldCloseWindowForLastTabDrag {
    return self.closeWindowForLastTabDrag;
}

- (NSDragOperation)tabView:(NSTabView*)aTabView validateDrop:(id<NSDraggingInfo>)sender proposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView {
    return NSDragOperationMove;
}

- (NSDragOperation)tabView:(NSTabView *)aTabView validateSlideOfProposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView {
    return NSDragOperationMove;
}

- (NSImage *)tabView:(NSTabView *)aTabView imageForTabViewItem:(NSTabViewItem *)tabViewItem offset:(NSSize *)offset styleMask:(NSUInteger *)styleMask {
    NSView *aView = aTabView;
    NSRect originRect = [aView convertRect:[aView bounds] toView:[[aView window] contentView]];
    
    NSRect rect = originRect;
    rect.origin.y = 0;
    rect.origin.x += [aView window].frame.origin.x;
    rect.origin.y += [[aView window] screen].frame.size.height - [aView window].frame.origin.y - [aView window].frame.size.height;
    rect.origin.y += [aView window].frame.size.height - originRect.origin.y - originRect.size.height;
    
    CGImageRef cgimg = CGWindowListCreateImage(rect,
                                               kCGWindowListOptionIncludingWindow,
                                               (CGWindowID)[[aView window] windowNumber],
                                               kCGWindowImageDefault);
    NSImage *image = [[NSImage alloc] initWithCGImage:cgimg size:[aView bounds].size];
    NSSize imageSize = [image size];
    [image setScalesWhenResized:YES];
    
    if (imageSize.width > imageSize.height) {
        [image setSize:NSMakeSize(125, 125 * (imageSize.height / imageSize.width))];
    } else {
        [image setSize:NSMakeSize(125 * (imageSize.width / imageSize.height), 125)];
    }
    return image;
}

- (MMTabBarView *)tabView:(NSTabView *)aTabView newTabBarViewForDraggedTabViewItem:(NSTabViewItem *)tabViewItem atPoint:(NSPoint)point {

	//create a new window controller with no tab items
	TMTTabViewWindow *tabWindow = [[TMTTabViewWindow alloc] init];
    [[TMTTabViewWindowManager sharedTabViewWindowManager]addTabViewWindow:tabWindow];
    
    MMTabBarView *tabBarView = (MMTabBarView *)[aTabView delegate];
    
	id <MMTabStyle> style = [tabBarView style];
    
	NSRect windowFrame = [[tabWindow window] frame];
    point.y += windowFrame.size.height - [[[tabWindow window] contentView] frame].size.height;
	point.x -= [style leftMarginForTabBarView:tabBarView];
    
    [[tabWindow window] setFrameTopLeftPoint:point];
	[[[tabWindow tabView] tabBar] setStyle:style];
	return [[tabWindow tabView] tabBar];
}

- (NSString *)tabView:(NSTabView *)aTabView toolTipForTabViewItem:(NSTabViewItem *)tabViewItem {
	return [tabViewItem label];
}

- (NSString *)accessibilityStringForTabView:(NSTabView *)aTabView objectCount:(NSInteger)objectCount {
	return (objectCount == 1) ? @"item" : @"items";
}

- (void)tabView:(NSTabView *)aTabView closeWindowForLastTabViewItem:(NSTabViewItem *)tabViewItem {
    NSWindow *w = aTabView.window;
    if ([w isKindOfClass:[TMTTabViewWindow class]]) {
        [[TMTTabViewWindowManager sharedTabViewWindowManager] removeTabViewWindow:(TMTTabViewWindow*)w];
    }
    
}

@end
