//
//  AppDelegate.m
//  FolderOutlineTest
//
//  Created by Tobias Mende on 16.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self.browser setPath:@"~"];
    [self.browser setMaxVisibleColumns:1];
    NSLog(@"%@", self.browser);
}

@end
