//
//  TMTTabViewWindow.m
//  TeXtended
//
//  Created by Max Bannach on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.

#import <MMTabBarView/MMTabBarView.h>

#import "TMTTabViewController.h"
#import "TMTTabManager.h"
#import "TMTTabViewWindow.h"

@interface TMTTabViewWindow (PRIVATE)

@end

@interface TMTTabViewWindow ()

@end

@implementation TMTTabViewWindow

    - (id)init
    {
        self = [super initWithWindowNibName:@"TMTTabViewWindow"];
        if (self) {
        }
        return self;
    }

    - (void)awakeFromNib
    {
        self.window.delegate = self;
        [self setTabView:[[TMTTabViewController alloc] init]];
        [self.cview addSubview:[self.tabView view]];
        [[self.tabView view] setFrame:[self.cview bounds]];
        [[self.tabView view] setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    }


    - (void)windowWillClose:(NSNotification *)notification
    {
        [self.tabView closeAll];
        [[TMTTabManager sharedTabManager] removeTabViewWindow:self];
    }


@end
