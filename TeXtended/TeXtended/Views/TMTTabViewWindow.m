//
//  TMTTabViewWindow.m
//  TeXtended
//
//  Created by Max Bannach on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.

#import <MMTabBarView/MMTabBarView.h>
#import <MMTabBarView/MMTabStyle.h>

#import "TMTTabView.h"
#import "TMTTabViewWindow.h"
#import "TMTTabViewItem.h"

@interface TMTTabViewWindow (PRIVATE)
- (void)configureTabBarInitially;
@end

@interface TMTTabViewWindow ()

@end

@implementation TMTTabViewWindow

- (id) init {
    self = [super initWithWindowNibName:@"TMTTabViewWindow"];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    [self setTabView:[[TMTTabView alloc] init]];
    [self.tabView addDefaultTabs];
    [self.cview addSubview:[self.tabView view]];
    [[self.tabView view] setFrame:[self.cview bounds]];
    [[self.tabView view] setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
}



@end
