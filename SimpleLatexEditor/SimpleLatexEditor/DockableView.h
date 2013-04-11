//
//  DockableView.h
//  SimpleLatexEditor
//
//  Created by Tobias Mende on 06.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DockableView : NSViewController
@property (strong) IBOutlet NSView *innerView;
@property (assign) BOOL isDocked;
@property (strong) NSView *initialView;

- (IBAction)toggleDocking:(id)sender;

@end
