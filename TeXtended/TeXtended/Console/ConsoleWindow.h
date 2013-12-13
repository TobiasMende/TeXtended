//
//  ConsoleWindow.h
//  TeXtended
//
//  Created by Tobias Mende on 13.12.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ConsoleWindowController;
@interface ConsoleWindow : NSWindow
- (void)liveCompile:(id)sender;

@property (weak) ConsoleWindowController* controller;
@end
