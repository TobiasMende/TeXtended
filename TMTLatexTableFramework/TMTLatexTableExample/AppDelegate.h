//
//  AppDelegate.h
//  TMTLatexTableExample
//
//  Created by Tobias Mende on 03.08.14.
//  Copyright (c) 2014 TeXtended. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMTLatexTableViewController;
@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property TMTLatexTableViewController *controller;

@end
