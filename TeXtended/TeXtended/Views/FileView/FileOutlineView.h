//
//  FileOutlineView.h
//  TeXtended
//
//  Created by Tobias Mende on 03.05.14.
//  Copyright (c) 2014 Tobias Mende. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileOutlineView : NSOutlineView
    {
        __unsafe_unretained IBOutlet  NSViewController *viewController;
    }

    @property IBOutlet NSMenu *contextualMenu;

    @property IBOutlet NSMenu *backgroundMenu;

    - (NSArray *)expandedItems;

    - (void)restoreExpandedStateWithArray:(NSArray *)array;
- (void)setViewController:(NSViewController *)newController;
@end
