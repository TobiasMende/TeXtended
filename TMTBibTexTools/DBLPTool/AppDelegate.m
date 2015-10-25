//
//  AppDelegate.m
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <TMTHelperCollection/TMTLog.h>
#import "AppDelegate.h"
#import "DBLPSearchViewController.h"
#import "BibtexWindowController.h"
LOGGING_DEFAULT

@implementation AppDelegate

    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification
    {
        // Insert code here to initialize your application
        [self.controller finishInitialization];
        self.controller.handler = self;

    }


    - (void)applicationWillFinishLaunching:(NSNotification *)notification
    {
        [TMTLog customizeLogger];
        TMT_TRACE
        self.controller = [DBLPSearchViewController new];
        [self.window setContentView:self.controller.view];
    }

    - (void)executeCitation:(TMTBibTexEntry *)citation forBibFile:(NSString *)path
    {
        if (!self.bibtexWindowController) {
            self.bibtexWindowController = [[BibtexWindowController alloc] initWithPublication:citation];
            [self.bibtexWindowController showWindow:nil];
        } else {
            [self.bibtexWindowController showPublication:citation];
        }
    }

@end
