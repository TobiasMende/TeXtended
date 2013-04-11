//
//  DockableView.h
//  DockableViewTest
//
//  Created by Tobias Mende on 06.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface DockableView : NSView
@property (strong) IBOutlet NSButton *dockButton;
@property (strong) IBOutlet NSView *contentView;
- (IBAction)showDebugOutput:(id)sender;
- (void) addContentView:(NSView*) view;
@end
