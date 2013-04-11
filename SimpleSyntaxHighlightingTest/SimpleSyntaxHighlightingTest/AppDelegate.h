//
//  AppDelegate.h
//  SimpleSyntaxHighlightingTest
//
//  Created by Tobias Mende on 09.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Constants.h"
@class PreferencesController;
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    PreferencesController *preferencesController;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)showPreferences:(id)sender;
@end
