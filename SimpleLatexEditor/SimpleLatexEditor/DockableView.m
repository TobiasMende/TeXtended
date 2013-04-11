//
//  DockableView.m
//  SimpleLatexEditor
//
//  Created by Tobias Mende on 06.04.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "DockableView.h"

@implementation DockableView


- (IBAction)toggleDocking:(id)sender {
    if(self.isDocked) {
        [self setInitialView:[self.view superview]];
        NSWindow *window = [[NSWindow alloc] init];
        [window setContentView:self.view];
        [self setIsDocked:NO];
        [window display];
    } else {
        [[self.view window] close];
        [self.initialView addSubview:self.view];
        [self setIsDocked:YES];
    }
}
@end
