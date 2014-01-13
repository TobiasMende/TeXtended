//
//  TMTArrayController.m
//  TeXtended
//
//  Created by Tobias Mende on 12.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "TMTArrayController.h"
#import <TMTHelperCollection/TMTLog.h>

@implementation TMTArrayController

- (void)add:(id)sender {
    [self addObject:self.newObject];
    if (self.tableView) {
        [self.tableView reloadData];
        // [self.tableView scrollToEndOfDocument:self];
        self.selectionIndex = self.tableView.numberOfRows-1;
        [self.tableView editColumn:0 row:self.tableView.selectedRow withEvent:nil select:YES];
    }
}
@end
