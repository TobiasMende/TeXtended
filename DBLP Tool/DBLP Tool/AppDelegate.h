//
//  AppDelegate.h
//  DBLP Tool
//
//  Created by Tobias Mende on 14.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBLPSearchCompletionHandler.h"
@class DBLPInterface, DBLPSearchViewController, BibtexWindowController;
@interface AppDelegate : NSObject <NSApplicationDelegate, DBLPSearchCompletionHandler>
@property (unsafe_unretained) IBOutlet NSWindow *window;
@property BibtexWindowController *bibtexWindowController;

@property DBLPSearchViewController *controller;
@end
