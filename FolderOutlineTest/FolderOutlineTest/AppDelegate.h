//
//  AppDelegate.h
//  FolderOutlineTest
//
//  Created by Tobias Mende on 16.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSBrowser *browser;

@end
