//
//  AppDelegate.h
//  LayoutManagerTest
//
//  Created by Tobias Mende on 08.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MGSFragaria/MGSFragaria.h>
@class MGSFragaria;
@interface AppDelegate : NSObject <NSApplicationDelegate> {
    MGSFragaria *fragaria;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *editView;
@end
