//
//  TMTTabViewWindow.m
//  TeXtended
//
//  Created by Max Bannach on 28.09.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "TMTTabView.h"
#import "TMTTabViewWindow.h"
#import "TMTTabViewItem.h"
#import "TMTTabViewDummy.h"

@interface TMTTabViewWindow ()

@end

@implementation TMTTabViewWindow

- (id) init {
    self = [super initWithWindowNibName:@"TMTTabViewWindow"];
    if (self) {
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    item1 = [[TMTTabViewItem alloc] init];
    [item1 setView:[[TMTTabViewDummy alloc] initWithColor:[NSColor redColor]]];
    [item1 setLabel:@"Item 1"];
    
    item2 = [[TMTTabViewItem alloc] init];
    [item2 setView:[[TMTTabViewDummy alloc] initWithColor:[NSColor blueColor]]];
    [item2 setLabel:@"Item 2"];
    
    item3 = [[TMTTabViewItem alloc] init];
    [item3 setView:[[TMTTabViewDummy alloc] initWithColor:[NSColor greenColor]]];
    [item3 setLabel:@"Item 3"];
    
    item4 = [[TMTTabViewItem alloc] init];
    [item4 setView:[[TMTTabViewDummy alloc] initWithColor:[NSColor orangeColor]]];
    [item4 setLabel:@"Item 4"];
    
    item5 = [[TMTTabViewItem alloc] init];
    [item5 setView:[[TMTTabViewDummy alloc] initWithColor:[NSColor yellowColor]]];
    [item5 setLabel:@"Item 5"];
    
    [self.tabView addTabViewItem:item1];
    [self.tabView addTabViewItem:item2];
    [self.tabView addTabViewItem:item3];
    [self.tabView addTabViewItem:item4];
    [self.tabView addTabViewItem:item5];
}

@end
