//
//  MainWindow.h
//  TeXtended
//
//  Created by Tobias Mende on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController;
@interface MainWindow : NSWindow
@property (unsafe_unretained) IBOutlet MainWindowController *controller;
- (IBAction)genericAction:(id)sender;
@end
