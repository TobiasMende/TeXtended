//
//  AppDelegate.m
//  TMTLatexTableExample
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import "AppDelegate.h"
#import <TMTLatexTableFramework/TMTLatexTableViewController.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _controller = [TMTLatexTableViewController new];
    self.window.contentView = self.controller.view;
}

@end
