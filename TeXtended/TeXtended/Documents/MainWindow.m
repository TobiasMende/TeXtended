//
//  MainWindow.m
//  TeXtended
//
//  Created by Tobias Mende on 09.06.13.
//  Copyright (c) 2013 Tobias Mende. All rights reserved.
//

#import "MainWindow.h"
#import "MainWindowController.h"
#import "TMTLog.h"

@implementation MainWindow


- (void)genericAction:(id)sender {
    [self.controller genericAction:sender];
}

- (void)draftCompile:(id)sender {
    [self.controller draftCompile:sender];
}

- (void)export:(id)sender {
    [self.controller finalCompile:sender];
}

- (void)dealloc {
    DDLogVerbose(@"dealloc");
}
@end
