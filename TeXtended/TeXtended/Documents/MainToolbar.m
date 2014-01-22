//
//  MainToolbar.m
//  TeXtended
//
//  Created by Tobias Mende on 22.01.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import "MainToolbar.h"

@implementation MainToolbar


- (BOOL)shouldHideShareButton {
    return (NSAppKitVersionNumber < NSAppKitVersionNumber10_8);
}


- (void)validateVisibleItems {
    for(NSUInteger index = 0; index < self.items.count; index ++) {
        NSToolbarItem *item = self.items[index];
        if (![item.itemIdentifier isEqualToString:@"SharingButton"] || !self.shouldHideShareButton) {
            [item validate];
        } else {
            [self removeItemAtIndex:index];
        }
    }
}

@end
