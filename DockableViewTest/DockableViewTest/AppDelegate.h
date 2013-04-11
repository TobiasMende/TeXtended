//
//  AppDelegate.h
//  DockableViewTest
//
//  Created by Tobias Mende on 06.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class DockableViewController;
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    DockableViewController *dvc;
}
@property (weak) IBOutlet NSScrollView *subview;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

@property (assign) IBOutlet NSWindow *window;
@end
