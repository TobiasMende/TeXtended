//
//  AppDelegate.m
//  DockableViewTest
//
//  Created by Tobias Mende on 06.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AppDelegate.h"
#import "DockableViewController.h"
#import "DockableView.h"
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    //_view = [[NSTextView alloc] initWithFrame:[[self.window contentView] frame]];
    dvc = [[DockableViewController alloc] init];
    DockableView *dv = (DockableView*)dvc.view;
    [dv addContentView:self.subview];
    [self.window setContentView:dvc.view];
}

@end
