//
//  DockableViewController.h
//  DockableViewTest
//
//  Created by Tobias Mende on 06.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DockableViewController : NSViewController {
    NSView *initialSuperView;
    NSWindow *secondWindow;
}
@property (assign, setter = setDocked:) BOOL isDocked;
- (IBAction)toggleDocking:(id)sender;
@end
