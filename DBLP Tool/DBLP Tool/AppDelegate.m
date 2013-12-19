//
//  AppDelegate.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AppDelegate.h"
#import "DBLPSearchViewController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.controller finishInitialization];
}


- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    self.controller = [DBLPSearchViewController new];
    [self.window setContentView:self.controller.view];
}

@end
