//
//  TMTTABViewViewController.m
//  TeXtended
//
//  Created by Max Bannach on 26.10.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <MMTabBarView/MMTabBarView.h>
#import <MMTabBarView/MMTabStyle.h>
#import <TMTHelperCollection/TMTLog.h>
#import "TMTTabViewWindow.h"
#import "TMTTabViewItem.h"
#import "TMTTabViewController.h"
#import "TMTTabManager.h"
#import "Constants.h"

@interface TMTTabViewController ()

    - (void)handleTabClose:(NSTabViewItem *)item;
@end

@implementation TMTTabViewController

#pragma mark - Initialize and dealloc
    - (id)init
    {
        self = [super initWithNibName:@"TMTTabView" bundle:nil];
        if (self) {
            self.closeWindowForLastTabDrag = YES;
        }
        return self;
    }

    - (void)awakeFromNib
    {
        [[TMTTabManager sharedTabManager] addTabViewController:self];
        //[tabBar setDelegate:self];
        //self.tabView.delegate = self;
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


    - (void)dealloc
    {
        for (NSTabViewItem *item in self.tabView.tabViewItems) {
            [self handleTabClose:item];
        }

        [tabBar setDelegate:nil];
        [[TMTTabManager sharedTabManager] removeTabViewController:self];
    }

    - (void)handleTabClose:(NSTabViewItem *)item
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:TMTTabViewDidCloseNotification object:[item.identifier identifier]];
    }


    - (void)addTabViewItem:(TMTTabViewItem *)item
    {
        if (!item.document) {
            item.document = ((NSWindowController *) self.tabView.window.windowController).document;
        }

        NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:item];
        [newItem setView:[item view]];
        [self.tabView addTabViewItem:newItem];
        [self.tabView selectTabViewItem:newItem];
        
    }

    - (void)addNewTabWithTitle:(NSString *)aTitle
    {
        TMTTabViewItem *newModel = [[TMTTabViewItem alloc] init];
        [newModel setTitle:aTitle];
        NSTabViewItem *newItem = [[NSTabViewItem alloc] initWithIdentifier:newModel];
        [newItem setView:[newModel view]];
        [self.tabView addTabViewItem:newItem];
        [self.tabView selectTabViewItem:newItem];
    }


    - (MMTabBarView *)tabBar
    {
        return tabBar;
    }

#pragma mark -
#pragma mark Delegate Methods

    - (BOOL)tabView:(NSTabView *)aTabView shouldAllowTabViewItem:(NSTabViewItem *)tabViewItem toLeaveTabBarView:(MMTabBarView *)tabBarView
    {
        return YES;
    }

    - (BOOL)tabView:(NSTabView *)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem inTabBarView:(MMTabBarView *)tabBarView
    {
        return YES;
    }

    - (NSDragOperation)tabView:(NSTabView *)aTabView validateDrop:(id <NSDraggingInfo>)sender proposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView
    {
        return NSDragOperationMove;
    }

    - (NSDragOperation)tabView:(NSTabView *)aTabView validateSlideOfProposedItem:(NSTabViewItem *)tabViewItem proposedIndex:(NSUInteger)proposedIndex inTabBarView:(MMTabBarView *)tabBarView
    {
        return NSDragOperationMove;
    }

    - (NSImage *)tabView:(NSTabView *)aTabView imageForTabViewItem:(NSTabViewItem *)tabViewItem offset:(NSSize *)offset styleMask:(NSUInteger *)styleMask
    {

        NSView *aView = aTabView;
        NSRect originRect = [aView convertRect:[aView bounds] toView:[[aView window] contentView]];

        NSRect rect = originRect;
        rect.origin.y = 0;
        rect.origin.x += [aView window].frame.origin.x;
        rect.origin.y += [[aView window] screen].frame.size.height - [aView window].frame.origin.y - [aView window].frame.size.height;
        rect.origin.y += [aView window].frame.size.height - originRect.origin.y - originRect.size.height;

        CGImageRef cgimg = CGWindowListCreateImage(rect,
                kCGWindowListOptionIncludingWindow,
                (CGWindowID) [[aView window] windowNumber],
                kCGWindowImageDefault);
        NSImage *image = [[NSImage alloc] initWithCGImage:cgimg size:[aView bounds].size];
        NSSize imageSize = [image size];
        [image setScalesWhenResized:YES];
        CGImageRelease(cgimg);


        if (imageSize.width > imageSize.height) {
            [image setSize:NSMakeSize(125, 125 * (imageSize.height / imageSize.width))];
        } else {
            [image setSize:NSMakeSize(125 * (imageSize.width / imageSize.height), 125)];
        }
        return image;
    }

    - (MMTabBarView *)tabView:(NSTabView *)aTabView newTabBarViewForDraggedTabViewItem:(NSTabViewItem *)tabViewItem atPoint:(NSPoint)point
    {

        //create a new window controller with no tab items
        TMTTabViewWindow *tabWindow = [[TMTTabViewWindow alloc] init];
        [[TMTTabManager sharedTabManager] addTabViewWindow:tabWindow];

        MMTabBarView *tabBarView = (MMTabBarView *) [aTabView delegate];

        id <MMTabStyle> style = [tabBarView style];

        NSRect windowFrame = [[tabWindow window] frame];
        point.y += windowFrame.size.height - [[[tabWindow window] contentView] frame].size.height;
        point.x -= [style leftMarginForTabBarView:tabBarView];

        [[tabWindow window] setFrameTopLeftPoint:point];
        [[[tabWindow tabView] tabBar] setStyle:style];
        return [[tabWindow tabView] tabBar];
    }

    - (NSString *)tabView:(NSTabView *)aTabView toolTipForTabViewItem:(NSTabViewItem *)tabViewItem
    {
        return [tabViewItem label];
    }

    - (NSString *)accessibilityStringForTabView:(NSTabView *)aTabView objectCount:(NSInteger)objectCount
    {
        return (objectCount == 1) ? @"item" : @"items";
    }

    - (void)tabView:(NSTabView *)aTabView closeWindowForLastTabViewItem:(NSTabViewItem *)tabViewItem
    {
        NSWindow *w = aTabView.window;
        if ([w isKindOfClass:[TMTTabViewWindow class]]) {
            [[TMTTabManager sharedTabManager] removeTabViewWindow:(TMTTabViewWindow *) w];
        }
        if (self.closeWindowForLastTabDrag) {
            [w close];
        }

    }


    - (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
    {
        [[tabViewItem.view window] makeFirstResponder:tabViewItem.view];
    }


    - (BOOL)shouldHideWindowWhenDraggingFrom:(MMTabBarView *)tabBarController
    {
        return self.closeWindowForLastTabDrag;
    }


    - (void)tabView:(NSTabView *)aTabView didDropTabViewItem:(NSTabViewItem *)tabViewItem inTabBarView:(MMTabBarView *)tabBarView
    {
        if (!self.closeWindowForLastTabDrag) {
            [self.tabView.window orderWindow:NSWindowBelow relativeTo:tabBarView.window.windowNumber];
        }
    }

    - (void)tabViewDidChangeNumberOfTabViewItems:(NSTabView *)tabView
    {
        NSWindow *w = tabView.window;
        if (tabView.numberOfTabViewItems == 0) {
            if ([w isKindOfClass:[TMTTabViewWindow class]]) {
                [[TMTTabManager sharedTabManager] removeTabViewWindow:(TMTTabViewWindow *) w];
            }
            if (self.closeWindowForLastTabDrag) {
                [w close];
            }
        }
    }

    - (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem
    {
        [self handleTabClose:tabViewItem];
        DDLogWarn(@"Closing %@", tabViewItem);
    }

- (void)closeAll {
    for (NSTabViewItem *item in self.tabView.tabViewItems) {
        [self handleTabClose:item];
    }
}

@end
